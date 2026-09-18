# Use Case: Quản lý tài khoản nhân viên

> Scope: Hệ thống vận hành khách sạn · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở màn danh sách tài khoản và thực hiện tạo / sửa / khóa / mở / đặt lại MK.

## Preconditions

- Quản lý đã đăng nhập với phiên hợp lệ (BR-auth-roles-001).

## Guarantees

- **Minimal Guarantee:** Thao tác vượt quyền hoặc vi phạm QL cuối cùng bị từ chối; không xóa cứng TK; MK tạm chỉ hiện một lần.
- **Success Guarantee:** Thay đổi TK được lưu; khóa hủy ngay phiên đang mở; mở khóa/reset đặt Chờ kích hoạt + MK tạm; nhật ký ghi đủ trường.

## Main Success Scenario

1. Quản lý mở danh sách tài khoản.
2. Quản lý tạo mới: họ tên, SĐT, vai trò → sinh MK tạm, Chờ kích hoạt, hiện MK tạm một lần (FR-auth-roles-005).
3. (Hoặc) Đặt lại MK → MK tạm mới, Chờ kích hoạt (FR-auth-roles-008).
4. (Hoặc) Khóa TK không phải QL cuối → Bị khóa + hủy phiên ngay (FR-auth-roles-009).
5. (Hoặc) Mở khóa → MK tạm mới, Chờ kích hoạt, đếm sai = 0 (FR-auth-roles-010).
6. Hệ thống ghi nhật ký và cập nhật danh sách.

## Extensions

**2a. SĐT đã tồn tại (E-auth-roles-006):**
- 2a1. Từ chối, giữ form.

**4a. Khóa/đổi vai trò QL cuối cùng (E-auth-roles-010):**
- 4a1. Từ chối + giải thích (FR-auth-roles-016).

**4b. Nhân viên đang dùng bị khóa (E-auth-roles-009):**
- 4b1. Hủy phiên thiết bị trong ≤3 giây (SC-auth-roles-05).

**1a. Không đủ quyền (E-auth-roles-007):**
- 1a1. Từ chối phía máy chủ.

**2b. Mất kết nối (E-auth-roles-008):**
- 2b1. Không lưu, báo offline.

## Related Requirements

FR-auth-roles-005,008,009,010,016,017 · BR-auth-roles-001,005,006 · CAP-auth-roles-04
