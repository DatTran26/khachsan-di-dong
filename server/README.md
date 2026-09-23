# Backend — KhachSanDiDong

Node.js + Express 5 + TypeScript + Prisma 6 + PostgreSQL 16 + Socket.IO 4 (REST và realtime chung một cổng).

## Chạy lần đầu

Yêu cầu: Node.js ≥ 20 và PostgreSQL 16 (khuyến nghị chạy bằng Docker).

```bash
cd server
npm install
cp .env.example .env          # rồi sửa giá trị nếu cần
docker compose up -d          # bật PostgreSQL (bỏ qua nếu đã cài PostgreSQL trên máy)
npm run db:migrate            # tạo bảng
npm run db:seed               # 50 phòng + 8 tài khoản mẫu
npm run dev                   # http://localhost:3000/api/health
```

> CSDL phải dùng bảng mã **UTF-8** (Docker mặc định đã là UTF-8), nếu không tiếng Việt sẽ lỗi.

### Không dùng Docker: cài PostgreSQL trên Windows

1. Cài PostgreSQL 16+ bằng bộ cài của EDB (có kèm pgAdmin). Ghi nhớ **mật khẩu user `postgres`** và **cổng** đã chọn.
2. Mở PowerShell, đăng nhập bằng user `postgres` (đổi `18`/`5432` cho đúng bản & cổng đã cài):

   ```powershell
   & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -p 5432
   ```

3. Trong `psql`, tạo user + database cho dự án (`CREATEDB` cần cho `prisma migrate dev`):

   ```sql
   CREATE ROLE khachsan WITH LOGIN PASSWORD 'khachsan' CREATEDB;
   CREATE DATABASE khachsan OWNER khachsan ENCODING 'UTF8' TEMPLATE template0;
   \q
   ```

4. Trong `.env`, sửa cổng trong `DATABASE_URL` cho khớp (vd `localhost:5433` nếu lúc cài chọn 5433).

Tài khoản mẫu (mật khẩu = `SEED_PASSWORD` trong `.env`):

| SĐT | Vai trò |
|---|---|
| 0900000001 | Quản lý |
| 0900000002, 0900000003 | Lễ tân |
| 0900000004 → 0900000007 | Buồng phòng–bảo trì (đang trực) |
| 0900000008 | Buồng phòng–bảo trì (nghỉ ca) |

## Lệnh

| Lệnh | Việc |
|---|---|
| `npm run dev` | Chạy dev, tự khởi động lại khi sửa code |
| `npm test` | Chạy test trên CSDL riêng `<tên DB>_test` (tự tạo, tự dọn — không đụng dữ liệu dev) |
| `npm run bench:realtime` | Đo tiêu chí nghiệm thu realtime (30 thiết bị đã đăng nhập, 100 lượt, ≤3s) trên CSDL test |
| `npm run typecheck` | Kiểm tra kiểu TypeScript |
| `npm run build` / `npm start` | Build ra `dist/` và chạy bản build |
| `npm run db:migrate` | Tạo migration mới khi sửa `prisma/schema.prisma` |
| `npm run db:studio` | Xem dữ liệu bằng giao diện web |

## Cấu trúc

```
server/
├── prisma/
│   ├── schema.prisma         # 12 bảng — thiết kế: docs/_shared/database-design.md
│   ├── migrations/           # SQL tạo bảng + ràng buộc viết tay (trigger, partial index)
│   └── seed.ts
├── src/
│   ├── server.ts             # khởi động HTTP server
│   ├── app.ts                # Express: gắn route + xử lý lỗi
│   ├── config/env.ts         # đọc & kiểm tra .env
│   ├── realtime/
│   │   ├── socket.ts         # gắn Socket.IO, kênh, publish()
│   │   └── events.ts         # tên sự kiện + kiểu dữ liệu gửi cho client
│   ├── lib/
│   │   ├── prisma.ts         # PrismaClient dùng chung
│   │   ├── transaction.ts    # withTransaction(): lưu xong mới phát sự kiện
│   │   ├── optimistic-lock.ts# chống ghi đè — updateWithVersion()
│   │   ├── audit.ts          # ghi nhật ký — writeAudit()
│   │   ├── messages.ts       # câu chữ tiếng Việt (nguyên văn docs)
│   │   └── errors.ts         # AppError, Unauthorized/Forbidden/NotFound, VersionConflictError
│   ├── middleware/error-handler.ts
│   └── modules/              # mỗi tính năng: *.routes.ts (HTTP) + *.service.ts (nghiệp vụ)
│       ├── auth/             # đăng nhập, phiên, middleware requireAuth/requireRole
│       ├── users/            # quản lý tài khoản
│       ├── health/
│       └── rooms/
├── scripts/realtime-benchmark.ts
└── tests/
```

## Chống ghi đè — quy tắc bắt buộc khi viết API ghi dữ liệu

Bảng `rooms`, `stays`, `housekeeping_tasks`, `maintenance_tasks`, `users` có cột `version`.

1. **API đọc** luôn trả `version` cho client.
2. **API ghi** bắt client gửi lại `version` đã đọc, và cập nhật bằng `updateWithVersion()` bên trong `withTransaction()`:

   ```ts
   await withTransaction(async (tx, enqueue) => {
     const room = await updateWithVersion(tx, 'room', roomId, body.version, { cleaning: 'DIRTY' });
     await writeAudit(tx, { /* ai, hành động, từ → sang */ });
     enqueue({ channel: CHANNELS.hotel, event: 'room:updated', payload: { /* ... */ } });
     // tạo việc dọn... — mọi thứ cùng transaction
   });
   // withTransaction chỉ phát các sự kiện đã enqueue SAU khi COMMIT; lỗi → rollback, không phát gì
   // Ví dụ đầy đủ: changeRoomStatus() trong src/modules/rooms/rooms.service.ts
   ```

3. `version` không khớp → API trả **409** `VERSION_CONFLICT` kèm `details.current` (bản mới nhất); client hiển thị
   "Phòng vừa được người khác cập nhật" và tải lại. Transaction rollback nên không có gì được ghi dở.
4. Lưới an toàn ở CSDL: trigger `bump_version` tăng `version` cho **mọi** lệnh UPDATE, nên kể cả khi quên dùng
   `updateWithVersion()` thì client cầm version cũ vẫn bị từ chối.

Test chứng minh: `tests/optimistic-lock.test.ts` (10 request cùng lúc cùng version → đúng 1 thành công).

## API hiện có

Mọi route trừ `/api/health` và `/api/auth/login` cần header `Authorization: Bearer <token>`.
Lỗi luôn có dạng `{ error: { code, message, details? } }` — `message` là câu tiếng Việt hiển thị thẳng cho người dùng
(lấy nguyên văn từ docs, xem `src/lib/messages.ts`).

| Method | Đường dẫn | Ai dùng | Mô tả |
|---|---|---|---|
| GET | `/api/health` | — | Server + CSDL còn sống |
| POST | `/api/auth/login` | — | `{ phone, password, deviceInfo? }` → `{ token, expiresAt, user }`. Phiên 12 giờ, 1 TK 1 thiết bị |
| POST | `/api/auth/logout` | đã đăng nhập | Hủy phiên |
| GET | `/api/auth/me` | đã đăng nhập | Tài khoản hiện tại + hạn phiên |
| POST | `/api/auth/change-password` | đã đăng nhập | `{ currentPassword, newPassword }` — MK ≥8 ký tự, có chữ và số |
| GET | `/api/users` | quản lý, lễ tân | Danh sách tài khoản |
| POST | `/api/users` | quản lý, lễ tân | `{ fullName, phone, role }` → trả `tempPassword` **một lần** |
| PATCH | `/api/users/:id` | quản lý, lễ tân | `{ version, fullName?, phone?, role?, onDuty? }` |
| POST | `/api/users/:id/lock` · `/unlock` · `/reset-password` | quản lý, lễ tân | `{ version }` — mở khóa / đặt lại trả `tempPassword` mới |
| GET | `/api/rooms?floor=&roomTypeId=&occupancy=&cleaning=&service=` | mọi vai trò | Danh sách phòng, kèm `isReady` và `version` |
| GET | `/api/rooms/:id` | mọi vai trò | Chi tiết một phòng |

Quy tắc phân quyền tài khoản (BR-auth-roles-001, chốt 23/09/2026): **lễ tân** quản lý được TK không phải quản lý và không
gán vai trò quản lý; không ai tự khóa mình; không khóa / đổi vai trò **quản lý cuối cùng**; không có xóa tài khoản.

Mã lỗi client cần xử lý riêng:

| `code` | HTTP | Client làm gì |
|---|---|---|
| `UNAUTHENTICATED`, `SESSION_INVALID`, `SESSION_EXPIRED` | 401 | Xóa token, về màn đăng nhập |
| `PASSWORD_CHANGE_REQUIRED` | 403 | Chuyển màn đổi MK bắt buộc |
| `FORBIDDEN` | 403 | Báo không đủ quyền |
| `VERSION_CONFLICT` | 409 | Hiện `details.current` (bản mới nhất), báo "dữ liệu vừa được người khác cập nhật" |

## Realtime (Socket.IO)

Client kết nối tới cùng địa chỉ backend, **kèm token**: `io(url, { auth: { token } })`.
Token sai / hết hạn / đang dùng MK tạm → `connect_error` với `err.data.code` (bảng mã lỗi ở trên).

| Sự kiện | Kênh | Dữ liệu |
|---|---|---|
| `room:updated` | `hotel` (mọi người) | `{ room: <như GET /api/rooms/:id>, emittedAt }` |
| `session:revoked` | riêng phiên đó | `{ reason, message }` — `reason`: `LOGGED_IN_ELSEWHERE` · `LOCKED` · `EXPIRED` · `LOGGED_OUT` · `PASSWORD_RESET`. Server ngắt kết nối ngay sau đó → client hiện `message`, về màn đăng nhập |

Quy tắc phía client (Flutter):

1. Mở màn hình → gọi REST lấy dữ liệu, rồi nghe sự kiện để cập nhật từng phần.
2. Nhận `room:updated` → chỉ áp dụng nếu `room.version` **lớn hơn** bản đang giữ (bỏ qua bản cũ đến muộn).
3. Mất kết nối → hiện "Mất kết nối", khóa nút ghi. Kết nối lại → **gọi REST tải lại toàn bộ** (không đoán các sự kiện đã lỡ).
   Server ping mỗi 5s, chờ 5s → phát hiện mất kết nối trong khoảng ≤10s.

Kết quả đo (23/09/2026, máy dev, `npm run bench:realtime`): 30 thiết bị × 100 lượt → 100% ≤3s, p95 27 ms, max 43 ms,
0 sự kiện mất. Thử 100 thiết bị × 200 lượt liên tục → vẫn 100%, max 78 ms.
Đo trên cùng một máy nên chưa tính độ trễ mạng thật — cần đo lại trên VPS ở Sprint 4.
