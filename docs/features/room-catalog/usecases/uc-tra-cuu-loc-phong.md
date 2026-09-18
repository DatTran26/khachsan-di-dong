# Use Case: Tra cứu / lọc danh mục phòng

> Scope: Room Catalog · Level: sea

## Primary Actor

Mọi vai trò (Quản lý, Lễ tân, Nhân viên buồng–bảo trì)

## Trigger

Actor mở màn danh mục phòng để xem hoặc lọc theo tầng, loại, trạng thái từng trục.

## Preconditions

- Actor đã đăng nhập.
- Danh mục phòng đã có dữ liệu (hoặc rỗng hợp lệ).

## Guarantees

- __Minimal Guarantee:__ Nếu lọc không khớp, hiển thị trạng thái rỗng — không bịa dữ liệu.
- __Success Guarantee:__ Mỗi phòng hiển thị 3 trục riêng; "sẵn sàng" là giá trị suy ra (trống + sạch + bình thường), không lưu riêng.

## Main Success Scenario

1) Actor mở danh mục phòng.
2) Hệ thống tải danh sách phòng kèm 3 trục trạng thái.
3) Actor chọn bộ lọc tầng / loại phòng / trạng thái từng trục (có thể kết hợp).
4) Hệ thống hiển thị kết quả khớp; nếu không có phòng → trạng thái rỗng rõ ràng.
5) Actor đọc trạng thái từng phòng (lưu trú, vệ sinh, bảo trì) và nhận biết phòng "sẵn sàng" khi đủ 3 điều kiện.

## Extensions

__2a. Danh mục rỗng:__
- 2a1. Hệ thống hiển thị trạng thái rỗng (không lỗi).

__4a. Bộ lọc không khớp phòng nào:__
- 4a1. Hệ thống giữ bộ lọc và hiển thị trạng thái rỗng theo FR-room-catalog-006.

## Related Requirements

- FR-room-catalog-005 — 3 trục + sẵn sàng composite
- FR-room-catalog-006 — tra cứu/lọc + trạng thái rỗng
