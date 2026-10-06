# Changelog

Những thay đổi đáng ghi nhận của Khách Sạn Di Động. Phiên bản app và server nằm ở `app/pubspec.yaml` và `server/package.json`.

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

[0.1.0]: https://github.com/DatTran26/khachsan-di-dong/releases/tag/v0.1.0
