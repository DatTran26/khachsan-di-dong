# Use Case: Đổi mật khẩu

> Scope: Hệ thống vận hành khách sạn · Level: sea

## Primary Actor

Nhân viên khách sạn

## Trigger

Nhân viên chọn đổi mật khẩu, hoặc hệ thống bắt buộc đổi sau MK tạm / mở khóa / reset.

## Preconditions

- Có phiên hợp lệ (hoặc phiên tạm sau xác thực MK tạm).

## Guarantees

- **Minimal Guarantee:** MK mới không đạt rule thì không cập nhật; không lộ MK.
- **Success Guarantee:** MK đã cập nhật; nếu từ MK tạm thì TK chuyển Hoạt động; phiên hiện tại được giữ (FR-auth-roles-007); nhật ký ghi sự kiện đổi MK.

## Main Success Scenario

1. Hệ thống hiển thị form đổi MK.
2. Nhân viên nhập và gửi.
3. Hệ thống kiểm tra MK cũ (nếu cần) và MK mới đạt rule (FR-auth-roles-015).
4. Hệ thống cập nhật MK, tắt cờ MK tạm, chuyển TK Hoạt động nếu đang Chờ kích hoạt (FR-auth-roles-006).
5. Hệ thống giữ phiên, ghi nhật ký, đưa về màn chính.

## Extensions

**3a. MK mới không đạt rule (E-auth-roles-005):**
- 3a1. Từ chối, giữ form (trừ giá trị MK).
- 3a2. Resume bước 2.

**2a. Mất kết nối (E-auth-roles-008):**
- 2a1. Báo mất kết nối, không lưu.

## Related Requirements

FR-auth-roles-006, FR-auth-roles-007, FR-auth-roles-015 · NFR-auth-roles-001
