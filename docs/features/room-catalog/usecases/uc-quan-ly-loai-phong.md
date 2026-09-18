# Use Case: Quản lý loại phòng

> Scope: Room Catalog · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý mở danh mục loại phòng để thêm, sửa tên, hoặc tắt loại.

## Preconditions

- Actor đã đăng nhập với quyền quản lý.

## Guarantees

- __Minimal Guarantee:__ Lưu thất bại → danh mục loại không đổi.
- __Success Guarantee:__ Loại mới/sửa/tắt được lưu; phòng chỉ chọn được loại đang hiện có (đang dùng); nhật ký thay đổi.

## Main Success Scenario

1) Quản lý mở danh sách loại phòng.
2) Quản lý thêm loại mới, sửa tên, hoặc tắt loại.
3) Hệ thống kiểm tra quyền và lưu.
4) Hệ thống ghi nhật ký và cập nhật danh sách; form thêm/sửa phòng chỉ liệt kê loại đang dùng.

## Extensions

__3a. Mất mạng / sai quyền (E-room-catalog-005, E-room-catalog-007):__
- 3a1. Từ chối theo Error Matrix.

## Related Requirements

- FR-room-catalog-010 — quản lý loại phòng
- FR-room-catalog-012 — kiểm quyền + nhật ký
