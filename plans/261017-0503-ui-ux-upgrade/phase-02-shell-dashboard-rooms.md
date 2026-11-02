---
phase: 2
title: "Shell, Tổng quan, Danh sách phòng"
owner: Dat
status: completed
effort: 9h
dependsOn: [1]
---

# Phase 02 — Shell, Tổng quan, Danh sách phòng

## Bối cảnh

`AppShell` (515 dòng, 14 chỗ màu/cỡ chữ cứng) chỉ có hai kiểu bố cục: thanh bên ≥900px, còn lại là
thanh dưới/ngăn kéo — tablet dùng giao diện điện thoại kéo giãn. Dashboard và Phòng tải lần đầu bằng
spinner giữa màn; Phòng chưa có kéo-làm-mới.

## File sở hữu

- Sửa: `app/lib/features/shell/screens/app_shell.dart`, `app/lib/features/dashboard/screens/dashboard_screen.dart`,
  `app/lib/features/dashboard/widgets/offline_banner.dart`, `app/lib/features/rooms/screens/rooms_screen.dart`
- Tạo: `app/test/features/shell_dashboard_rooms_test.dart`
- Không sửa: `room_detail_panel.dart`, `room_form_screen.dart` (thuộc phase 03), `core/router/*`.

## Yêu cầu

1. **Shell responsive 3 mức**
   - compact: giữ thanh dưới/ngăn kéo.
   - medium: `NavigationRail` kèm badge quá hạn.
   - expanded: giữ thanh bên.
   - Trạng thái online/"Cập nhật lúc" hiển thị nhất quán ở cả ba mức.
2. **Trợ năng shell**
   - Mục điều hướng có nhãn semantics kèm số việc quá hạn ("Dọn phòng, 3 việc quá hạn").
   - Menu người dùng có tooltip.
   - Banner offline dùng `liveRegion` để trình đọc màn hình báo khi mất/có lại kết nối.
3. **Tổng quan**
   - Thay spinner bằng skeleton (lưới ô + thẻ số liệu) qua `AsyncBody`.
   - Thẻ số liệu bấm được để lọc lưới theo trạng thái tương ứng (ví dụ bấm "Cần dọn" thì lọc phòng cần dọn), tận dụng state `_group` hiện có. Đây là cải tiến giảm thao tác.
   - Lưới phòng tự tính số cột theo bề rộng; ở 360px ô không nhỏ hơn 48dp.
4. **Danh sách phòng**
   - Skeleton và kéo-làm-mới.
   - Bảng (web) và lưới (mobile) dùng token.
   - Ô tìm/lọc giữ nguyên giá trị khi quay lại màn.
   - Hiện tổng số kết quả sau khi lọc.
5. Bỏ hết `Color(0x`/`fontSize:` viết cứng trong các file sở hữu.

## Các bước

1. Kéo `develop` (đã có phase 01) về `develop-dat`.
2. Làm shell trước vì các màn khác hiển thị bên trong nó.
3. Chuyển Dashboard, rồi Rooms.
4. Viết test, chạy app ở 3 kích thước, rồi mở PR vào `develop`.

## Kiểm tra

- Test: shell render rail ở 768px, thanh bên ở 1280px, thanh dưới ở 360px; dashboard hiện skeleton khi provider đang tải; bấm thẻ "Cần dọn" lọc lưới.
- Thủ công: `flutter run -d chrome` và thiết bị/emulator Android, đăng nhập bằng tài khoản quản lý và lễ tân, bật/tắt mạng để xem banner.
- `grep -c "Color(0x\|fontSize:"` trên 4 file sở hữu = 0.

## Rủi ro và rollback

- Rail ở tablet đổi thói quen người dùng mobile → chỉ áp dụng từ 600px, điện thoại không đổi.
- Rollback: revert PR; phase 03/04 không phụ thuộc file của phase này.
