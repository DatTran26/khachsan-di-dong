---
phase: 4
title: "Dọn phòng, Tài khoản, Nhật ký, Đăng nhập"
owner: Kim
status: completed
effort: 10h
dependsOn: [1]
---

# Phase 04 — Dọn phòng, Tài khoản, Nhật ký, Đăng nhập

## Bối cảnh

Kim vừa thiết kế lại các màn này ở PR #8. Phase này **không đổi bố cục**, chỉ chuyển sang token,
thêm skeleton, kéo-làm-mới và trợ năng. Nhân viên buồng phòng dùng Android ngoài hiện trường nên
vùng chạm và cỡ chữ lớn là ưu tiên.

## File sở hữu

- Sửa:
  - `app/lib/features/housekeeping/screens/housekeeping_screen.dart`
  - `app/lib/features/users/screens/users_screen.dart`
  - `app/lib/features/users/widgets/user_form_dialog.dart`
  - `app/lib/features/users/widgets/temp_password_dialog.dart`
  - `app/lib/features/audit/screens/audit_screen.dart`
  - `app/lib/features/auth/screens/login_screen.dart`
  - `app/lib/features/auth/screens/change_password_screen.dart`
- Tạo: `app/test/features/housekeeping_users_audit_auth_test.dart`
- Không sửa: `shared/widgets/*`, `core/theme/*`.

## Yêu cầu

1. **Dọn phòng (vai trò nhân viên)**
   - Nút "Bắt đầu dọn"/"Đã dọn xong" cao ≥48 và nằm trong vùng ngón cái.
   - Thẻ việc đọc được ở `textScaler` 2.0.
   - Semantics cho trạng thái và hạn ("Phòng 305, quá hạn 20 phút").
   - Skeleton khi tải.
2. **Tài khoản**
   - Skeleton và kéo-làm-mới.
   - Form tạo/sửa có kiểm tra lỗi ngay khi rời ô và `autofillHints`.
   - Hộp mật khẩu tạm có nút sao chép kèm tooltip và báo "Đã sao chép".
3. **Nhật ký**
   - Skeleton; kéo-làm-mới; nút "tải thêm" có semantics.
   - Bộ lọc thời gian/vai trò dùng `FilterPill`/`SegmentedPills` chung.
4. **Đăng nhập / Đổi mật khẩu**
   - `AutofillGroup` + `autofillHints` (username/password/newPassword).
   - Nút hiện/ẩn mật khẩu có tooltip.
   - Enter để gửi; lỗi đăng nhập được trình đọc màn hình đọc lên.
   - Bố cục cuộn được khi bàn phím mở ở 360px.
5. Bỏ hết `Color(0x`/`fontSize:` viết cứng trong file sở hữu (login đang có 12 chỗ). Gradient đăng nhập dùng màu `AppColors` do phase 01 thêm.

## Các bước

1. Kéo `develop` về `develop-kim`.
2. Làm Dọn phòng trước (người dùng hiện trường), sau đó Đăng nhập/Đổi mật khẩu, rồi Tài khoản và Nhật ký.
3. Viết test, kiểm thủ công, rồi mở PR `develop-kim` → `develop`.

## Kiểm tra

- Test:
  - Đăng nhập: trường có `autofillHints`; nhấn Enter gọi đăng nhập.
  - Dọn phòng: thẻ việc có semantics chứa số phòng, không tràn ở `textScaler` 2.0 với khung 360px.
  - Tài khoản/Nhật ký: hiện skeleton khi đang tải.
- Thủ công: đăng nhập bằng tài khoản nhân viên trên Android, bật TalkBack, đi hết luồng nhận việc → dọn xong.
- So sánh ảnh chụp trước/sau để chắc bố cục PR #8 không đổi.

## Rủi ro và rollback

- Chuyển token có thể làm lệch màu nhẹ so với bản PR #8 → so ảnh chụp trước/sau.
- Rollback: revert PR của phase.
