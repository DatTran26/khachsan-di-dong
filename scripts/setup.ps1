<#
.SYNOPSIS
  Chuẩn bị môi trường lần đầu sau khi clone: kiểm tra công cụ, tạo server/.env, cài thư viện backend + app,
  tạo bảng trong CSDL, nạp dữ liệu mẫu. Chạy lại nhiều lần vẫn an toàn (không ghi đè .env, seed không tạo trùng).

.EXAMPLE
  .\setup.cmd                      # cách dễ nhất (tự bỏ qua chặn ExecutionPolicy)
  .\setup.cmd -DbPort 5433         # PostgreSQL cài ở cổng khác 5432
  .\setup.cmd -SkipDemo            # không nạp tình huống demo
  .\setup.cmd -Docker              # dùng PostgreSQL trong Docker thay vì cài trên máy
#>
param(
  [int]$DbPort = 0,
  [switch]$SkipDemo,
  [switch]$Docker
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$server = Join-Path $root 'server'
$app = Join-Path $root 'app'

function Step($text) { Write-Host ''; Write-Host "==> $text" -ForegroundColor Cyan }
function Ok($text) { Write-Host "    [OK] $text" -ForegroundColor Green }
function Warn($text) { Write-Host "    [!] $text" -ForegroundColor Yellow }
function Fail($text) { Write-Host ''; Write-Host "[LỖI] $text" -ForegroundColor Red; exit 1 }

function Test-Port([int]$port) {
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    $async = $client.BeginConnect('127.0.0.1', $port, $null, $null)
    $ok = $async.AsyncWaitHandle.WaitOne(500) -and $client.Connected
    $client.Close()
    return $ok
  } catch { return $false }
}

# Chạy lệnh ngoài trong thư mục chỉ định; lỗi → dừng kèm thông báo tiếng Việt.
function Invoke-In([string]$dir, [string]$command, [string]$errorMessage) {
  Push-Location $dir
  try {
    cmd /c $command
    if ($LASTEXITCODE -ne 0) { Fail $errorMessage }
  } finally { Pop-Location }
}

# ---------------------------------------------------------------------------------------------
Step '1/6 Kiểm tra công cụ'

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { Fail 'Chưa có Node.js. Cài bản LTS (>= 20) tại https://nodejs.org rồi mở lại PowerShell.' }
$nodeMajor = [int]((node -v).TrimStart('v').Split('.')[0])
if ($nodeMajor -lt 20) { Fail "Node.js $(node -v) quá cũ — cần >= 20." }
Ok "Node.js $(node -v)"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Fail 'Chưa có Flutter. Cài theo https://docs.flutter.dev/get-started/install/windows rồi mở lại PowerShell.'
}
Ok ((flutter --version 2>$null | Select-Object -First 1) -replace '\s+•.*$', '')

if ($Docker) {
  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Fail 'Chọn -Docker nhưng máy chưa có Docker Desktop.' }
  Ok 'Docker'
}

# ---------------------------------------------------------------------------------------------
Step '2/6 PostgreSQL'

if ($Docker) {
  Invoke-In $server 'docker compose up -d db' 'Không bật được PostgreSQL bằng Docker.'
  $DbPort = 5432
  Write-Host '    Đợi PostgreSQL khởi động...'
  for ($i = 0; $i -lt 30 -and -not (Test-Port $DbPort); $i++) { Start-Sleep -Seconds 1 }
}

if ($DbPort -eq 0) {
  foreach ($candidate in 5432, 5433, 5434) { if (Test-Port $candidate) { $DbPort = $candidate; break } }
}
if ($DbPort -eq 0 -or -not (Test-Port $DbPort)) {
  Fail @'
Không thấy PostgreSQL đang chạy (đã thử cổng 5432, 5433, 5434).
  - Cài PostgreSQL 16+ (https://www.postgresql.org/download/windows/) rồi chạy lại, hoặc
  - Có Docker: chạy lại với  .\setup.cmd -Docker
  - PostgreSQL ở cổng khác:  .\setup.cmd -DbPort <cổng>
'@
}
Ok "PostgreSQL đang chạy ở cổng $DbPort"

# ---------------------------------------------------------------------------------------------
Step '3/6 File cấu hình server/.env'

$envFile = Join-Path $server '.env'
if (Test-Path $envFile) {
  Ok 'Đã có server/.env — giữ nguyên (không ghi đè).'
} else {
  $content = Get-Content (Join-Path $server '.env.example') -Raw -Encoding UTF8
  $content = $content -replace 'localhost:5432/', "localhost:$DbPort/"
  [System.IO.File]::WriteAllText($envFile, $content, (New-Object System.Text.UTF8Encoding $false))
  Ok "Đã tạo server/.env từ .env.example (cổng $DbPort)."
}
$envText = Get-Content $envFile -Raw -Encoding UTF8
if ($envText -notmatch "localhost:$DbPort/") {
  Warn "DATABASE_URL trong server/.env không dùng cổng $DbPort — kiểm tra lại nếu bước 5 lỗi kết nối."
}

# ---------------------------------------------------------------------------------------------
Step '4/6 Cài thư viện backend (npm install — tự sinh Prisma Client)'
Invoke-In $server 'npm install --no-fund --no-audit' 'npm install thất bại — xem lỗi phía trên.'
Ok 'Thư viện backend'

# ---------------------------------------------------------------------------------------------
Step '5/6 Tạo bảng + nạp dữ liệu mẫu'

Push-Location $server
try {
  $migrate = cmd /c 'npx prisma migrate deploy 2>&1'
  $migrateCode = $LASTEXITCODE
} finally { Pop-Location }
if ($migrateCode -ne 0) {
  $migrate | Select-Object -Last 5 | ForEach-Object { Write-Host "    $_" }
  Fail @"
Chưa kết nối được CSDL "khachsan". Nếu cài PostgreSQL trên máy, tạo user + database MỘT lần bằng user postgres:

  & "C:\Program Files\PostgreSQL\<phiên bản>\bin\psql.exe" -U postgres -h localhost -p $DbPort

  CREATE ROLE khachsan WITH LOGIN PASSWORD 'khachsan' CREATEDB;
  CREATE DATABASE khachsan OWNER khachsan ENCODING 'UTF8' TEMPLATE template0;
  \q

rồi chạy lại .\setup.cmd  (hoặc dùng .\setup.cmd -Docker)
"@
}
Ok 'Đã tạo / cập nhật bảng (prisma migrate deploy)'

Invoke-In $server 'npm run db:seed --silent' 'Nạp dữ liệu mẫu thất bại.'
Ok '50 phòng + 8 tài khoản mẫu'
if (-not $SkipDemo) {
  Invoke-In $server 'npm run db:seed:demo --silent' 'Nạp tình huống demo thất bại.'
  Ok 'Tình huống demo (bỏ qua nếu CSDL đã có dữ liệu vận hành)'
}

# ---------------------------------------------------------------------------------------------
Step '6/6 Cài thư viện app Flutter (flutter pub get)'
Push-Location $app
try {
  $pub = cmd /c 'flutter pub get 2>&1'
  $pubCode = $LASTEXITCODE
} finally { Pop-Location }
$pubText = $pub -join "`n"
if ($pubCode -eq 0) {
  Ok 'Thư viện app'
} elseif ($pubText -match 'Got dependencies' -and $pubText -match 'symlink support') {
  # Lỗi quen thuộc trên Windows: thư viện đã tải đủ, chỉ thiếu symlink cho plugin của bản Windows desktop.
  # App chạy trên web + Android (tôn chỉ) nên không ảnh hưởng.
  Ok 'Thư viện app'
  Warn 'Chưa bật Developer Mode của Windows → chưa chạy được app dạng Windows desktop (web + Android vẫn chạy bình thường).'
  Warn 'Cần chạy bản Windows desktop thì bật: Settings → System → For developers → Developer Mode (hoặc: start ms-settings:developers).'
} else {
  $pub | Select-Object -Last 10 | ForEach-Object { Write-Host "    $_" }
  Fail 'flutter pub get thất bại — xem lỗi phía trên.'
}

$seedPassword = if ($envText -match 'SEED_PASSWORD="?([^"\r\n]+)') { $Matches[1] } else { '(xem SEED_PASSWORD trong server/.env)' }
Write-Host ''
Write-Host '==========================================================' -ForegroundColor Green
Write-Host ' XONG. Chạy app hằng ngày bằng:   .\dev.cmd' -ForegroundColor Green
Write-Host '==========================================================' -ForegroundColor Green
Write-Host " Tài khoản demo (mật khẩu: $seedPassword):"
Write-Host '   0900000001 quản lý · 0900000002 lễ tân · 0900000004 nhân viên buồng phòng–bảo trì'
