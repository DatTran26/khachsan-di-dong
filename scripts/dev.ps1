<#
.SYNOPSIS
  Chạy hằng ngày: bật backend (cửa sổ riêng, nếu chưa chạy), đợi backend sẵn sàng, rồi `flutter run`.
  Tắt backend = đóng cửa sổ "KhachSan backend".

.EXAMPLE
  .\dev.cmd                         # app chạy trên Chrome
  .\dev.cmd -Device edge            # trình duyệt khác
  .\dev.cmd -Device emulator-5554   # máy ảo Android (xem "flutter devices"; cần app hỗ trợ địa chỉ 10.0.2.2)
  .\dev.cmd -BackendOnly            # chỉ bật backend (vd để chạy app từ VS Code / Android Studio)
#>
param(
  [string]$Device = 'chrome',
  [switch]$BackendOnly
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$server = Join-Path $root 'server'
$app = Join-Path $root 'app'

function Fail($text) { Write-Host "[LỖI] $text" -ForegroundColor Red; exit 1 }

$envFile = Join-Path $server '.env'
if (-not (Test-Path $envFile)) { Fail 'Chưa có server/.env — chạy .\setup.cmd trước.' }
if (-not (Test-Path (Join-Path $server 'node_modules'))) { Fail 'Chưa cài thư viện backend — chạy .\setup.cmd trước.' }

$envText = Get-Content $envFile -Raw -Encoding UTF8
$port = if ($envText -match '(?m)^\s*PORT\s*=\s*"?(\d+)') { [int]$Matches[1] } else { 3000 }
$health = "http://localhost:$port/api/health"

function Test-Backend {
  try { return (Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200 } catch { return $false }
}

if (Test-Backend) {
  Write-Host "Backend đã chạy sẵn ở cổng $port." -ForegroundColor Green
} else {
  Write-Host "Bật backend ở cửa sổ riêng (cổng $port)..." -ForegroundColor Cyan
  $command = "`$Host.UI.RawUI.WindowTitle = 'KhachSan backend'; Set-Location '$server'; npm run dev"
  $powershell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  Start-Process $powershell -ArgumentList '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $command | Out-Null

  $ready = $false
  for ($i = 0; $i -lt 45; $i++) {
    Start-Sleep -Seconds 1
    if (Test-Backend) { $ready = $true; break }
  }
  if (-not $ready) {
    Fail "Backend chưa lên sau 45 giây — xem lỗi trong cửa sổ 'KhachSan backend' (thường do PostgreSQL chưa chạy hoặc sai DATABASE_URL)."
  }
  Write-Host "Backend sẵn sàng: $health" -ForegroundColor Green
}

if ($BackendOnly) { exit 0 }

Write-Host "Chạy app Flutter trên '$Device' (nhấn q trong cửa sổ này để thoát app)..." -ForegroundColor Cyan
Push-Location $app
try {
  flutter run -d $Device
} finally { Pop-Location }
