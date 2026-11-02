# Changelog

Những thay đổi đáng ghi nhận của Khách Sạn Di Động. Phiên bản app và server nằm ở `app/pubspec.yaml` và `server/package.json`.

## [Unreleased]

### Fixed

- Hết phiên hoặc bị thu hồi phiên khi socket đang nối lại không còn kẹt banner "Mất kết nối" và khóa nút ghi trong khi mạng vẫn bình thường: app bắt lỗi handshake (`SESSION_EXPIRED`, `SESSION_INVALID`, `ACCOUNT_LOCKED`) và đưa về màn đăng nhập.
- Socket nối theo `API_URL` như REST, không còn cố định `localhost:3000`.
- Đăng xuất chủ động không chạy hai lần và không hiện nhầm câu "phiên đã kết thúc" ở màn đăng nhập.
- Đổi tài khoản không còn thấy dữ liệu và trạng thái kết nối của phiên trước.
- Không còn gửi request thiếu token (chắc chắn 401) từ màn cũ ngay sau khi đăng xuất.

## [0.2.0] - 2026-10-14

Bản cắt từ `develop` (`082f810`) sau tag `v0.1.0`. App `0.2.0+2`, server `0.2.0`. Gồm tính năng và sửa lỗi đã có trên `develop`, cộng ghi chú mã nguồn.

### Added

- Backend: tóm tắt vận hành bằng AI kèm báo cáo dự phòng, việc quá hạn theo phòng trên dashboard, ảnh nghiệm thu buồng phòng, ngưỡng quá hạn bảo trì mặc định 4 giờ.
- App: màn tóm tắt AI cho quản lý (kèm mức dùng ngân sách), ảnh nghiệm thu cho nhân viên và quản lý, quản lý loại phòng (thêm, đổi tên, tắt), thẻ thống kê lọc lưới phòng, deep link cảnh báo quá hạn tới phòng, danh sách việc và nhật ký kiểm toán.
- Kiểm thử ma trận RBAC, benchmark độ trễ dashboard/AI, và kiểm tra bộ lọc dashboard cùng trạng thái màn AI.
- Ghi chú dartdoc/TSDoc cho app và server.

### Fixed

- Health check trả 503 khi cơ sở dữ liệu không lên.
- Seed demo và kịch bản ca cao điểm.
- Cờ và số quá hạn trên dashboard theo spec; phiên nhân viên không còn gọi API tóm tắt dashboard.
- Phiếu việc buồng phòng bám theo việc; realtime nối lại sau lần đổi mật khẩu đầu.
- Màn Sprint 3 qua kiểm tra responsive và accessibility.
- Ô phòng ngừng phục vụ chỉ hiện "Ngừng phục vụ".

### Changed

- Biome lint chạy trong CI; cấu hình Biome dùng trường preset.
- CI backend chạy seed demo và ca cao điểm.
- Hình dạng dữ liệu tóm tắt AI được đánh phiên bản.

## [0.1.0] - 2026-10-06

Bản gắn tag đầu tiên. App `0.1.0+1`, server `0.1.0`. Nội dung là toàn bộ `develop` kể từ scaffold trên `main`.

### Added

- Backend: đăng nhập và phân quyền, danh mục phòng, nhận/trả phòng, chu trình buồng phòng, báo hỏng và bảo trì, tóm tắt dashboard, nhật ký kiểm toán, Socket.IO và khóa lạc quan.
- App Flutter: giao diện Champagne Gold, điều hướng theo vai trò, lưới phòng, chi tiết phòng và nhận phòng, danh sách lưu trú và trả phòng, bảng buồng phòng, bảo trì, quản lý tài khoản, nhật ký kiểm toán, đăng nhập và đổi mật khẩu.
- Script cài một lần (`setup.cmd`) và chạy hằng ngày (`dev.cmd`), Docker Compose, seed demo, CI typecheck/test/build cho backend.

### Fixed

- Đăng xuất trả 204 cả khi phiên không còn hợp lệ.
- Prisma Client được sinh khi cài đặt backend.
- Trạng thái buồng phòng trên app khớp API.
- Flutter Web gọi được API nhờ CORS.

### Changed

- Lễ tân quản lý được tài khoản không phải quản lý.
- Mục tiêu phiên đồng thời trong tài liệu nâng từ 10 lên 30.

[0.2.0]: https://github.com/DatTran26/khachsan-di-dong/releases/tag/v0.2.0
[0.1.0]: https://github.com/DatTran26/khachsan-di-dong/releases/tag/v0.1.0
