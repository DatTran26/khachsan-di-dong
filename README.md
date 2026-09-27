# Khách Sạn Di Động

Phần mềm theo dõi trạng thái phòng khách sạn theo thời gian thực, kèm dashboard dữ liệu — web (quản lý, lễ tân) và
Android (nhân viên buồng phòng–bảo trì). Đồ án môn Quản lý dự án CNTT — WPCTeam.

| Thư mục | Nội dung | Người phụ trách |
|---|---|---|
| [`app/`](app/) | Flutter (Web + Android) | Dat (web), Bao (mobile) |
| [`server/`](server/) | Backend Node.js + Express + TypeScript + Prisma + PostgreSQL + Socket.IO | Kim |
| [`docs/`](docs/) | PRD, spec từng tính năng, thiết kế CSDL, nhật ký làm việc | Cả nhóm |

## Bắt đầu nhanh (Windows)

### 1. Cài công cụ (một lần cho mỗi máy)

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| [Node.js](https://nodejs.org) | LTS ≥ 20 | Chạy backend |
| [Flutter](https://docs.flutter.dev/get-started/install/windows) | stable 3.x | `flutter doctor` phải có dấu ✓ ở Flutter, Chrome (và Android toolchain nếu chạy Android) |
| PostgreSQL ≥ 16 **hoặc** Docker Desktop | | Cài trên máy: [postgresql.org](https://www.postgresql.org/download/windows/) — nhớ mật khẩu user `postgres` và **cổng** |
| Google Chrome | | Chạy app bản web |

Cài PostgreSQL trên máy (không dùng Docker) → tạo user + database cho dự án **một lần** (thay `18`, `5432` đúng bản và cổng đã cài):

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -p 5432
```

```sql
CREATE ROLE khachsan WITH LOGIN PASSWORD 'khachsan' CREATEDB;
CREATE DATABASE khachsan OWNER khachsan ENCODING 'UTF8' TEMPLATE template0;
\q
```

### 2. Chuẩn bị project (một lần sau khi clone)

Mở PowerShell ở thư mục gốc repo:

```powershell
.\setup.cmd
```

Script tự làm: kiểm tra công cụ → tìm PostgreSQL (cổng 5432/5433/5434) → tạo `server/.env` → cài thư viện backend →
tạo bảng → nạp 50 phòng + 8 tài khoản + tình huống demo → cài thư viện app. Chạy lại nhiều lần vẫn an toàn.

| Tham số | Khi nào dùng |
|---|---|
| `.\setup.cmd -DbPort 5433` | PostgreSQL ở cổng khác mà không tự tìm được |
| `.\setup.cmd -Docker` | Dùng PostgreSQL trong Docker (không cần cài PostgreSQL, không cần tạo user) |
| `.\setup.cmd -SkipDemo` | Không nạp tình huống demo |

### 3. Chạy hằng ngày

```powershell
.\dev.cmd
```

Tự bật backend ở cửa sổ **"KhachSan backend"** (nếu chưa chạy), đợi backend sẵn sàng, rồi `flutter run` app trên Chrome.
Thoát app: nhấn `q`. Tắt backend: đóng cửa sổ "KhachSan backend".

| Lệnh | Việc |
|---|---|
| `.\dev.cmd -Device edge` | Chạy trên trình duyệt khác |
| `.\dev.cmd -BackendOnly` | Chỉ bật backend — rồi bấm Run trong VS Code / Android Studio |
| `.\dev.cmd -Device <id>` | Thiết bị khác (xem `flutter devices`) |

> **Vì sao không chỉ `flutter run`?** `flutter run` chỉ build và mở app, không bật backend. `dev.cmd` bật backend rồi
> gọi `flutter run` hộ. Khi backend đã lên VPS (Sprint 3), app trỏ vào server VPS và chỉ cần `flutter run`.

### Tài khoản demo

Mật khẩu chung = `SEED_PASSWORD` trong `server/.env` (mặc định `Demo@12345`).

| SĐT | Vai trò |
|---|---|
| 0900000001 | Quản lý |
| 0900000002, 0900000003 | Lễ tân |
| 0900000004 → 0900000007 | Nhân viên buồng phòng–bảo trì (đang trực) |

## Lỗi thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| `setup.cmd` báo *Không thấy PostgreSQL đang chạy* | Bật service PostgreSQL (Services → `postgresql-x64-…` → Start), hoặc `.\setup.cmd -Docker` |
| *Chưa kết nối được CSDL "khachsan"* | Chưa tạo user/database (mục 1), hoặc sai cổng → `.\setup.cmd -DbPort <cổng>` |
| Tiếng Việt lỗi, báo encoding `WIN1252` | Database tạo thiếu `ENCODING 'UTF8'` — tạo lại đúng lệnh ở mục 1 |
| Cảnh báo *chưa bật Developer Mode* | Chỉ cần khi chạy bản **Windows desktop**. Web + Android không ảnh hưởng. Bật: `start ms-settings:developers` |
| App báo *Không thể kết nối đến máy chủ* | Backend chưa chạy → `.\dev.cmd` (hoặc `-BackendOnly`); xem lỗi trong cửa sổ "KhachSan backend" |
| `dev.cmd` báo *Backend chưa lên sau 45 giây* | PostgreSQL chưa chạy hoặc sai `DATABASE_URL` trong `server/.env` |
| Máy ảo Android không kết nối được backend | App chưa hỗ trợ địa chỉ `10.0.2.2` — đang làm (phần app) |

## Tài liệu

- Backend — API, sự kiện realtime, mã lỗi, test: [`server/README.md`](server/README.md)
- Sản phẩm: [`docs/_product/prd.md`](docs/_product/prd.md) · spec từng tính năng: [`docs/features/`](docs/features/)
- Thiết kế CSDL: [`docs/_shared/database-design.md`](docs/_shared/database-design.md)
- Tiến độ & nhật ký làm việc: [`docs/_shared/worklog.md`](docs/_shared/worklog.md)

## Quy trình làm việc (gitflow)

- Mỗi người làm trên nhánh riêng `develop-<tên>` → mở PR vào **`develop`**, có người review mới merge.
- **Không** PR / push vào `main` — chỉ Dat (PM) đưa bản phát hành từ `develop` lên `main`.
- Không commit `.env` hay bí mật. Chi tiết: [`CONTRIBUTING.md`](CONTRIBUTING.md), [`AGENTS.md`](AGENTS.md).
