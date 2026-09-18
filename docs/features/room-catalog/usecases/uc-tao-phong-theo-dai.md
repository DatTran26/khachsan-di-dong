# Use Case: Tạo nhanh phòng theo dải

> Scope: Room Catalog · Level: sea

## Primary Actor

Quản lý

## Trigger

Quản lý chọn "Tạo theo dải" để nhập nhiều phòng cùng tầng/loại trong một lần.

## Preconditions

- Actor đã đăng nhập với quyền quản lý.
- Có loại phòng đang dùng để chọn.

## Guarantees

- __Minimal Guarantee:__ Nếu lưu thất bại toàn bộ, không tạo phòng nào; form giữ nguyên.
- __Success Guarantee:__ Các số chưa tồn tại được tạo với trạng thái mặc định; số đã tồn tại bị bỏ qua và báo rõ; nhật ký + realtime.

## Main Success Scenario

1) Quản lý mở "Tạo theo dải".
2) Hệ thống yêu cầu tầng, khoảng số phòng, loại phòng.
3) Quản lý nhập và xác nhận.
4) Hệ thống tạo từng số trong khoảng; bỏ qua số đã tồn tại.
5) Hệ thống báo kết quả: số đã tạo / số bị bỏ vì trùng.
6) Phòng mới nhận mặc định trống + sạch + bình thường; nhật ký + realtime.

## Extensions

__4a. Toàn bộ số trong dải đã tồn tại:__
- 4a1. Không tạo phòng mới; báo rõ mọi số bị bỏ.

__4b. Mất mạng / sai quyền (E-room-catalog-005, E-room-catalog-007):__
- 4b1. Từ chối theo Error Matrix.

__OQ:__ Cách nạp 50 phòng ban đầu và quy ước đánh số — xem `spec.md#OQ-2`, `spec.md#OQ-3`.

## Related Requirements

- FR-room-catalog-009 — tạo theo dải, bỏ qua trùng
- FR-room-catalog-002 — mặc định trạng thái phòng mới
