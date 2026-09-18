# Use Case: Đăng nhập / đăng xuất

> Scope: Hệ thống vận hành khách sạn · Level: sea

## Primary Actor

Nhân viên khách sạn (Quản lý / Lễ tân / Buồng phòng–bảo trì)

## Trigger

Nhân viên mở ứng dụng và gửi SĐT + mật khẩu, hoặc chọn đăng xuất khi đã có phiên.

## Preconditions

- Tài khoản đã được quản lý tạo sẵn.
- Nhân viên biết SĐT và mật khẩu (hoặc MK tạm vừa nhận ngoài app).

## Guarantees

- **Minimal Guarantee:** Sai thông tin không tạo phiên; đếm sai MK tăng đúng; không lộ giá trị MK; sự kiện auth được ghi nhật ký khi có thay đổi trạng thái TK/phiên.
- **Success Guarantee:** Phiên 12 giờ được tạo (hoặc hủy khi đăng xuất); đúng 1 phiên/TK; nhân viên vào đúng màn theo vai trò (hoặc màn đổi MK bắt buộc nếu MK tạm).

## Main Success Scenario

1. Nhân viên nhập SĐT + mật khẩu trên màn đăng nhập và gửi.
2. Hệ thống kiểm tra định dạng SĐT (FR-auth-roles-015) và xác thực.
3. Hệ thống xác nhận TK ở trạng thái Hoạt động, tạo phiên 12 giờ, hủy mọi phiên cũ của TK (FR-auth-roles-012).
4. Hệ thống ghi nhật ký đăng nhập (FR-auth-roles-013).
5. Hệ thống đưa nhân viên vào màn chính đúng vai trò.
6. (Đăng xuất) Nhân viên chọn đăng xuất → hệ thống hủy phiên, ghi nhật ký, về màn đăng nhập (FR-auth-roles-002).

## Extensions

**2a. Sai SĐT hoặc MK (E-auth-roles-001):**
- 2a1. Hệ thống từ chối, tăng đếm sai; đến 5 lần → khóa TK (FR-auth-roles-011).
- 2a2. Use case kết thúc với Minimal Guarantee.

**2b. TK đang Bị khóa (E-auth-roles-002):**
- 2b1. Hệ thống từ chối đăng nhập, hướng dẫn liên hệ quản lý.
- 2b2. Kết thúc.

**3a. Đăng nhập bằng MK tạm (E-auth-roles-004):**
- 3a1. Hệ thống tạo phiên nhưng chuyển màn đổi MK bắt buộc.
- 3a2. Sau đổi thành công → TK Hoạt động, vào màn chính.

**3b. Phiên hết hạn khi thao tác sau này (E-auth-roles-003):**
- 3b1. Hệ thống từ chối thao tác, về màn đăng nhập.

**5a. Phiên bị đá do đăng nhập nơi khác (E-auth-roles-011):**
- 5a1. Thiết bị cũ nhận thông báo, về màn đăng nhập.

## Related Requirements

FR-auth-roles-001, FR-auth-roles-002, FR-auth-roles-003, FR-auth-roles-011, FR-auth-roles-012, FR-auth-roles-015 · BR-auth-roles-004, BR-auth-roles-007 · NFR-auth-roles-004 (OQ-1)
