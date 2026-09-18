# Use Case: Đặt / gỡ ngừng phục vụ

> Scope: Room Catalog · Level: sea

## Primary Actor

Quản lý, Lễ tân

## Trigger

Actor chọn một phòng trên danh mục và đặt hoặc gỡ "ngừng phục vụ".

## Preconditions

- Actor đã đăng nhập với quyền đặt/gỡ ngừng phục vụ.
- Phòng tồn tại trong danh mục.

## Guarantees

- __Minimal Guarantee:__ Thiếu lý do hoặc lưu thất bại → không đổi trục bảo trì.
- __Success Guarantee:__ Đặt ngừng → bảo trì = ngừng phục vụ + lý do; gỡ → bảo trì = bình thường; nhật ký + realtime; phòng đang ở vẫn đặt được sau cảnh báo (khách ở hết kỳ, chặn nhận mới).

## Main Success Scenario

1) Actor chọn phòng và chọn "Ngừng phục vụ" hoặc "Gỡ ngừng phục vụ".
2) Đặt: hệ thống yêu cầu nhập lý do bắt buộc; nếu phòng đang ở → cảnh báo + xác nhận lại.
3) Actor nhập lý do (khi đặt) và xác nhận.
4) Hệ thống kiểm tra quyền và điều kiện tại thời điểm ghi.
5) Đặt: cập nhật bảo trì = ngừng phục vụ; Gỡ: bảo trì = bình thường (phòng "sẵn sàng" nếu trống + sạch).
6) Hệ thống ghi nhật ký và phát realtime.
7) Hệ thống cập nhật danh mục trên thiết bị đang mở.

## Extensions

__3a. Thiếu lý do ngừng phục vụ (E-room-catalog-004):__
- 3a1. Từ chối lưu, giữ form, báo nhập lý do.

__3b. Actor hủy khi cảnh báo phòng đang ở:__
- 3b1. Không đổi trạng thái; use case kết thúc.

__4a. Mất mạng (E-room-catalog-005) / trạng thái đã đổi (E-room-catalog-006) / sai quyền (E-room-catalog-007):__
- 4a1. Từ chối theo Error Matrix tương ứng.

## Related Requirements

- FR-room-catalog-007 — đặt ngừng phục vụ + lý do + cảnh báo đang ở
- FR-room-catalog-008 — gỡ ngừng phục vụ
- FR-room-catalog-012 — kiểm quyền + nhật ký
