# Backend — KhachSanDiDong

Node.js + Express 5 + TypeScript + Prisma 6 + PostgreSQL 16 + Socket.IO 4 (REST và realtime chung một cổng).

## Chạy lần đầu

> **Cách nhanh nhất:** chạy `.\setup.cmd` rồi `.\dev.cmd` ở thư mục gốc repo — xem [README gốc](../README.md). Phần dưới là các bước làm tay.

Yêu cầu: Node.js ≥ 20 và PostgreSQL 16 (khuyến nghị chạy bằng Docker).

```bash
cd server
npm install                   # tự chạy `prisma generate` (postinstall)
cp .env.example .env          # rồi sửa giá trị nếu cần
docker compose up -d          # bật PostgreSQL (bỏ qua nếu đã cài PostgreSQL trên máy)
npm run db:migrate            # tạo bảng
npm run db:seed               # 50 phòng + 8 tài khoản mẫu
npm run db:seed:demo          # (tuỳ chọn) tình huống demo: phòng có khách, đang dọn, chờ xác nhận, đang sửa…
npm run dev                   # http://localhost:3000/api/health
```

> CSDL phải dùng bảng mã **UTF-8** (Docker mặc định đã là UTF-8), nếu không tiếng Việt sẽ lỗi.

### Chạy cả backend bằng Docker (giống VPS)

```bash
docker compose --profile full up -d --build   # PostgreSQL + backend, tự chạy migration khi khởi động
```

Image backend được build thử trên GitHub Actions mỗi lần push (job "Docker image").

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
| `npm run lint` | Lint bằng Biome (cảnh báo cũng tính là lỗi) |
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
│       ├── rooms/            # đọc, danh mục, ngừng phục vụ
│       ├── room-types/
│       ├── stays/            # nhận/trả phòng
│       ├── housekeeping/     # việc dọn + tự giao việc
│       ├── maintenance/      # báo hỏng, sửa, trục bảo trì tự tính
│       ├── dashboard/
│       └── audit/            # xem nhật ký + nhãn tiếng Việt
│   ├── jobs/overdue.ts       # quét quá hạn 30 giây/lần
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

Mọi route trừ `/api/health`, `/api/auth/login`, `/api/auth/logout` cần header `Authorization: Bearer <token>`.
`/api/auth/logout` luôn trả 204 (kể cả phiên đã hết) — client **không** được coi 401 của logout là lý do để gọi logout lại.
Flutter Web gọi từ cổng khác: backend cho mọi `http://localhost:*` khi dev; khi triển khai khai báo `CORS_ORIGINS` trong `.env`.
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
| GET | `/api/rooms?floor=&roomTypeId=&occupancy=&cleaning=&service=&ready=true` | mọi vai trò | Danh sách phòng, kèm `isReady` và `version`. `ready=true` = chỉ phòng sẵn sàng |
| GET | `/api/rooms/:id` | mọi vai trò | Chi tiết một phòng |
| POST | `/api/rooms` | quản lý | `{ number, floor, roomTypeId }` — phòng mới trống + sạch + bình thường |
| POST | `/api/rooms/bulk` | quản lý | `{ floor, from, to, roomTypeId }` — tạo theo dải (≤100), trả `created`, `skipped` |
| PATCH | `/api/rooms/:id` | quản lý | `{ version, number?, floor?, roomTypeId? }` — không sửa 3 trục trạng thái ở đây |
| DELETE | `/api/rooms/:id` | quản lý | `{ version }` — chỉ khi trống, không việc mở, chưa có lịch sử hoạt động |
| POST | `/api/rooms/:id/out-of-service` | quản lý, lễ tân | `{ version, reason, confirmOccupied? }` — phòng có khách phải gửi `confirmOccupied: true` |
| POST | `/api/rooms/:id/back-in-service` | quản lý, lễ tân | `{ version }` — không được khi còn việc bảo trì mở |
| POST | `/api/rooms/:id/check-in` | **chỉ lễ tân** | `{ version, guestName, guestCount, note?, expectedCheckout? }` |
| POST | `/api/rooms/:id/check-out` | **chỉ lễ tân** | `{ version }` — phòng về trống + cần dọn, hệ thống tự tạo việc dọn (hạn 60 phút) |
| GET | `/api/stays` | lễ tân, quản lý | Phòng đang ở: phòng + khách + mốc nhận |
| GET | `/api/room-types` | mọi vai trò | Loại phòng |
| POST · PATCH | `/api/room-types` · `/api/room-types/:id` | quản lý | `{ name }` · `{ name?, isActive? }` — tắt thay vì xóa |
| GET | `/api/housekeeping/tasks?status=&assigneeId=&roomId=&mine=true&overdue=true` | quản lý, nhân viên | Việc dọn phòng |
| POST | `/api/housekeeping/tasks/:id/accept` · `/reject` | nhân viên được giao | `{ version }` — nhận (phòng → đang dọn) · từ chối (giao người kế tiếp) |
| POST | `/api/housekeeping/tasks/:id/complete` | nhân viên được giao | `{ version, hasIssue? }` — báo xong (phòng → chờ kiểm tra). Cần đủ ảnh `OVERVIEW` + `BED` + `BATHROOM` của lượt hiện tại (400 `PHOTOS_REQUIRED`); `hasIssue: true` cần thêm `CLOSEUP` (400 `CLOSEUP_REQUIRED`) |
| POST | `/api/housekeeping/tasks/:id/photos?category=OVERVIEW\|BED\|BATHROOM\|CLOSEUP` | nhân viên được giao, việc đang làm | Body = byte ảnh, `Content-Type: image/jpeg\|png\|webp`, ≤ `PHOTO_MAX_MB` (mặc định 5 MB, 413 nếu vượt). Nhóm bắt buộc: tải lại = thay ảnh cũ; cận cảnh tối đa 5 |
| GET | `/api/housekeeping/tasks/:id/photos` | nhân viên phụ trách, quản lý | `{ currentRound, photos[] }` — mọi lượt, lượt mới nhất trước, theo thứ tự nhóm. `photos[].url` tải bằng token |
| GET | `/api/housekeeping/photos/:id/file` | nhân viên phụ trách, quản lý | Byte ảnh (gửi kèm `Authorization`; Flutter: `Image.network(url, headers: ...)`) |
| DELETE | `/api/housekeeping/photos/:id` | nhân viên được giao | Xóa ảnh lượt hiện tại để chụp lại (ảnh lượt cũ khóa — 409 `PHOTO_LOCKED`) |
| POST | `/api/housekeeping/tasks/:id/confirm` | **chỉ quản lý** | `{ version }` — việc hoàn tất, phòng → sạch |
| POST | `/api/housekeeping/tasks/:id/return` | **chỉ quản lý** | `{ version, note }` — ghi chú bắt buộc ≤500, phòng → đang dọn |
| POST | `/api/housekeeping/tasks/:id/reassign` | **chỉ quản lý** | `{ version, assigneeId }` — người nhận phải là nhân viên đang trực |
| GET | `/api/maintenance/tasks?status=&roomId=&assigneeId=` | mọi vai trò | Việc bảo trì |
| POST | `/api/maintenance/tasks` | mọi vai trò | `{ roomId, description, location? }` — báo hỏng, phòng → ngừng phục vụ. Có thể trả `warning` |
| POST | `/api/maintenance/tasks/:id/claim` · `/complete` | nhân viên | `{ version }` — nhận (→ đang sửa) · hoàn tất (việc của mình) |
| POST | `/api/maintenance/tasks/:id/cancel` | người báo (việc chờ nhận), quản lý | `{ version, reason? }` |
| POST | `/api/maintenance/tasks/:id/assign` | quản lý, lễ tân | `{ version, assigneeId }` — chỉ định người xử lý |
| GET | `/api/dashboard/summary` | quản lý, lễ tân | Đang ở, sẵn sàng, ngừng phục vụ, số phòng theo từng trạng thái vệ sinh, việc quá hạn, lấp đầy (`rate: null` = không áp dụng). `overdue.tasks[]` = từng việc quá hạn `{ type, taskId, roomId, roomNumber }` để tô cờ ô phòng |
| POST | `/api/ai-summaries` | **chỉ quản lý** | `{ period: CURRENT_SHIFT\|PREVIOUS_SHIFT\|TODAY }` → `{ data, notice }`. `data.source`: `AI` (đã kiểm số liệu) · `FALLBACK` (báo cáo mẫu) · `EMPTY` (kỳ rỗng, không gọi AI). Luôn có `dataAsOfText` + `label` để hiển thị; `notice` = câu báo khi không dùng được AI. Đang có lượt chạy → 409 `SUMMARY_IN_PROGRESS` |
| GET | `/api/ai-summaries/latest` | **chỉ quản lý** | Bản gần nhất của từng kỳ `{ CURRENT_SHIFT, PREVIOUS_SHIFT, TODAY }` — không gọi AI |
| GET | `/api/ai-summaries/budget` | **chỉ quản lý** | `{ aiConfigured, model, budgetVnd, spentVnd, remainingVnd, exhausted }` |
| GET | `/api/audit-logs?roomId=&from=&to=&actorId=&actorRole=&action=&entityType=&field=&limit=&cursor=` | **chỉ quản lý** | Nhật ký, mới nhất trước, tải theo phần (`nextCursor`). Mỗi dòng có `line` theo mẫu *"14:32 05/10 · Trần B (lễ tân) · Trả phòng · Phòng 305 · lưu trú: đang ở → trống"*. `actorRole=SYSTEM` = việc hệ thống tự làm. Mặc định 50 dòng/lần (audit-log OQ-1 chưa chốt) |

**Việc dọn phòng tự động** (housekeeping): trả phòng → hệ thống tạo đúng 1 việc (hạn 60 phút) và giao ngay cho nhân viên
**đang trực** (`onDuty`, quản lý/lễ tân bật qua `PATCH /api/users/:id`) có ít việc mở nhất; không ai trực → "chờ giao" +
cảnh báo quản lý, có người vào trực thì tự giao. Job quét 30 giây/lần gắn cờ quá hạn **một lần**.
**Ảnh nghiệm thu** theo từng lần dọn: mỗi lần quản lý trả lại, việc sang lượt ảnh mới (`photoRound` + 1) — ảnh lượt cũ giữ
để truy vết, nhân viên nộp lại đủ bộ. Tệp lưu ở `UPLOAD_DIR` (mặc định `server/uploads/`, Docker: volume `uploads`).
**Trục bảo trì của phòng tự tính**: "ngừng phục vụ" khi còn việc bảo trì mở hoặc đang ngừng tay.
Ngưỡng quá hạn bảo trì: **4 giờ** từ lúc báo hỏng (maintenance OQ-1 chốt 10/10/2026); đổi bằng `MAINTENANCE_DUE_MINUTES`, `0` = tắt.

**Tóm tắt vận hành bằng AI** (ai-ops-summary): kỳ theo ca giờ VN 06–14 / 14–22 / 22–06 hoặc "hôm nay". Chỉ gửi số
đếm/tỷ lệ + số phòng cần chú ý cho OpenAI Responses API (Structured Outputs), chờ tối đa 15 giây. Mọi con số trong
bản AI phải có trong dữ liệu gốc, nếu không → báo cáo mẫu. Hạn mức theo **chi phí thực tế**: trước mỗi lượt kiểm
`đã tiêu + chi phí tối đa 1 lượt ≤ AI_BUDGET_VND` (mặc định 300.000). Không có `OPENAI_API_KEY` → luôn báo cáo mẫu.
Đơn giá `AI_PRICE_*_VND_PER_1M` phải khớp model đang dùng (`OPENAI_MODEL`). Mọi lượt tạo đều ghi nhật ký.

Quy tắc phân quyền tài khoản (BR-auth-roles-001, chốt 23/09/2026): **lễ tân** quản lý được TK không phải quản lý và không
gán vai trò quản lý; không ai tự khóa mình; không khóa / đổi vai trò **quản lý cuối cùng**; không có xóa tài khoản.

Mã lỗi client cần xử lý riêng:

| `code` | HTTP | Client làm gì |
|---|---|---|
| `UNAUTHENTICATED`, `SESSION_INVALID`, `SESSION_EXPIRED` | 401 | Xóa token, về màn đăng nhập |
| `PASSWORD_CHANGE_REQUIRED` | 403 | Chuyển màn đổi MK bắt buộc |
| `FORBIDDEN` | 403 | Báo không đủ quyền |
| `VERSION_CONFLICT` | 409 | Hiện `details.current` (bản mới nhất), báo "dữ liệu vừa được người khác cập nhật" |
| `INVALID_STATE` | 409 | Tải lại dữ liệu (thao tác không hợp lệ với trạng thái hiện tại) |
| `OCCUPIED_CONFIRM_REQUIRED` | 409 | Hỏi lại người dùng rồi gửi lại với `confirmOccupied: true` |

## Realtime (Socket.IO)

Client kết nối tới cùng địa chỉ backend, **kèm token**: `io(url, { auth: { token } })`.
Token sai / hết hạn / đang dùng MK tạm → `connect_error` với `err.data.code` (bảng mã lỗi ở trên).

| Sự kiện | Kênh | Dữ liệu |
|---|---|---|
| `room:updated` | `hotel` (mọi người) | `{ room: <như GET /api/rooms/:id>, emittedAt }` |
| `room:created` | `hotel` | `{ room, emittedAt }` — thêm ô phòng mới |
| `room:deleted` | `hotel` | `{ roomId, emittedAt }` — bỏ ô phòng |
| `housekeeping:task_updated` | `hotel` | `{ task, emittedAt }` — việc dọn đổi trạng thái / người |
| `maintenance:task_updated` | `hotel` | `{ task, emittedAt }` — việc bảo trì đổi trạng thái |
| `notification` | riêng người / vai trò | `{ kind, message, taskId?, roomId? }` — hiện `message` cho người dùng. `kind`: `HOUSEKEEPING_ASSIGNED` · `HOUSEKEEPING_UNASSIGNED` · `HOUSEKEEPING_PENDING_CONFIRM` · `HOUSEKEEPING_RETURNED` · `HOUSEKEEPING_OVERDUE` · `MAINTENANCE_REPORTED` · `MAINTENANCE_OVERDUE` |
| `session:revoked` | riêng phiên đó | `{ reason, message }` — `reason`: `LOGGED_IN_ELSEWHERE` · `LOCKED` · `EXPIRED` · `LOGGED_OUT` · `PASSWORD_RESET`. Server ngắt kết nối ngay sau đó → client hiện `message`, về màn đăng nhập |

Quy tắc phía client (Flutter):

1. Mở màn hình → gọi REST lấy dữ liệu, rồi nghe sự kiện để cập nhật từng phần.
2. Nhận `room:updated` → chỉ áp dụng nếu `room.version` **lớn hơn** bản đang giữ (bỏ qua bản cũ đến muộn).
3. Mất kết nối → hiện "Mất kết nối", khóa nút ghi. Kết nối lại → **gọi REST tải lại toàn bộ** (không đoán các sự kiện đã lỡ).
   Server ping mỗi 5s, chờ 5s → phát hiện mất kết nối trong khoảng ≤10s.

Kết quả đo (23/09/2026, máy dev, `npm run bench:realtime`): 30 thiết bị × 100 lượt → 100% ≤3s, p95 27 ms, max 43 ms,
0 sự kiện mất. Thử 100 thiết bị × 200 lượt liên tục → vẫn 100%, max 78 ms.
Đo trên cùng một máy nên chưa tính độ trễ mạng thật — cần đo lại trên VPS ở Sprint 4.
