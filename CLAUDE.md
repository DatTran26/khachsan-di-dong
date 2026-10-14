# CLAUDE.md — Khách Sạn Di Động

@AGENTS.md

## Giao tiếp
- Luôn trả lời bằng tiếng Việt, ngắn gọn, đi thẳng vào kết quả.
- Yêu cầu mơ hồ có nhiều cách hiểu → hỏi lại 1 câu trước khi sửa code.
- Với yêu cầu "tạo/viết nội dung rồi tôi duyệt": xuất nội dung ra chat trước, chỉ ghi file khi được duyệt.
- Báo cáo trung thực: đã chạy kiểm tra gì, chưa chạy gì, chưa test thực tế thì nói rõ.

## Dự án
- App vận hành khách sạn nội bộ, 3 role: MANAGER (quản lý), RECEPTIONIST (lễ tân), STAFF (buồng phòng–bảo trì).
- `app/` — Flutter (Riverpod, go_router, socket_io_client). Code theo feature: `lib/features/<feature>/{screens,widgets,providers}`, dùng chung ở `lib/core`, `lib/shared`.
- `server/` — Node ≥20, Express 5, TypeScript, Prisma + PostgreSQL, Socket.IO, zod. Module ở `src/modules/<feature>`.
- `docs/features/<feature>/` — BRD/PRD/URD/SRS là nguồn yêu cầu. Khi sửa hành vi nghiệp vụ, đối chiếu spec tương ứng; nếu code lệch spec thì báo ra.
- Stack đã chốt: Node/Express/Prisma/Socket.IO. Không đề xuất đổi sang Supabase/Firebase.
- Chạy dev: `dev.cmd` (backend + flutter), `dev.cmd -BackendOnly`.

## Quy tắc nghiệp vụ không được phá
- Realtime: mất kết nối socket thật → hiện banner "Mất kết nối" và khóa mọi nút ghi; có kết nối lại → tự mở và tải lại. Không bỏ cơ chế khóa này (dùng `isOnlineProvider`).
- Mọi thao tác ghi đi qua REST; socket chỉ để đồng bộ. Ghi có `version` để chống ghi đè.
- Thao tác ghi quan trọng phải ghi audit log; không bao giờ ghi giá trị mật khẩu vào log.
- Phân quyền kiểm tra ở server, không chỉ ẩn nút ở app.

## Code
- Viết theo phong cách code xung quanh: tên biến, mật độ comment, comment tiếng Việt.
- Sửa tối thiểu, đúng phạm vi yêu cầu; không refactor lan rộng khi không được nhờ.
- Không hardcode bí mật; không commit `.env`.

## Kiểm tra sau khi sửa
- App: `cd app && flutter analyze lib` (và `flutter test` nếu đụng logic có test).
- Server: `cd server && npm run typecheck && npm test`.
- Đổi schema Prisma → tạo migration (`npm run db:migrate`), không sửa migration cũ.

## Git
- Làm việc trên `develop-kim`; PR vào `develop`, không bao giờ PR thẳng vào `main`.
- Tự commit sau MỖI chức năng / MỖI lần sửa (không cần chờ nhắc): một commit = một thay đổi trọn vẹn, đã qua
  bước "Kiểm tra sau khi sửa"; không gộp nhiều chức năng vào một commit, không commit dở dang.
  Commit theo Conventional Commits (`feat(app): ...`, `fix(server): ...`). Chỉ add đúng file của thay đổi đó —
  không kéo theo thay đổi chưa liên quan đang có trong working tree.
- Commit phải mang danh tính HoangKim72 (giảng viên chấm qua lịch sử GitHub) — không đổi git user.
- Pull `develop` khi có thay đổi chưa commit: stash → merge → stash pop, báo file bị chồng.
- Nhịp PR: khi `develop-kim` có 4–5 commit chưa vào `develop` (linh hoạt theo tính năng — gom cho trọn
  một tính năng, không cắt ngang giữa chừng), tự push `develop-kim` và tạo PR vào `develop`:
  - Kiểm tra trước: `git log origin/develop..develop-kim`; nếu đã có PR mở từ `develop-kim` thì chỉ push thêm, không tạo PR mới.
  - Chạy kiểm tra (analyze/typecheck/test) trước khi tạo PR; lỗi thì sửa trước, không tạo PR.
  - Tiêu đề PR theo Conventional Commits, mô tả liệt kê các commit/tính năng và cách test.
  - Không tự merge PR; báo link PR cho tôi.
