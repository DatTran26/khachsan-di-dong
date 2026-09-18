# Use Case: Xem nhật ký hoạt động

> Scope: Hệ thống vận hành khách sạn · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở màn nhật ký và áp dụng bộ lọc.

## Preconditions

- Quản lý đã đăng nhập.
- Nhật ký được ghi phía máy chủ (FR-auth-roles-013). Màn xem là P1 (CAP-auth-roles-08).

## Guarantees

- **Minimal Guarantee:** Không lộ giá trị MK; người không đủ quyền bị từ chối.
- **Success Guarantee:** Quản lý xem được danh sách nhật ký theo lọc người / ngày / loại hành động (FR-auth-roles-014).

## Main Success Scenario

1. Quản lý mở màn nhật ký.
2. Quản lý chọn bộ lọc và áp dụng.
3. Hệ thống trả danh sách dòng nhật ký khớp.
4. Quản lý xem chi tiết một dòng nếu cần.

## Extensions

**1a. Không đủ quyền (E-auth-roles-007):**
- 1a1. Từ chối truy cập màn.

**2a. Không có kết quả:**
- 2a1. Hiển thị trạng thái trống tiếng Việt.

## Related Requirements

FR-auth-roles-013, FR-auth-roles-014 · CAP-auth-roles-08 · NFR-auth-roles-007
