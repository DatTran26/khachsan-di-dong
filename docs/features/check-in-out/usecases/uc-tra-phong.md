# Use Case: Trả phòng

> Scope: Check-in-out · Level: sea

## Primary Actor

Lễ tân

## Trigger

Lễ tân chọn phòng đang ở và xác nhận trả phòng.

## Preconditions

- Phòng đang ở có lượt lưu trú mở.
- Lễ tân đã đăng nhập.

## Guarantees

- __Minimal Guarantee:__ Trả thất bại → lượt vẫn mở, trục không đổi.
- __Success Guarantee:__ Lượt đóng; lưu trú = trống; vệ sinh = cần dọn; phát sự kiện trả phòng cho housekeeping; nhật ký + realtime. Luôn cần dọn bất kể tình trạng thực tế.

## Main Success Scenario

1) Lễ tân chọn phòng trên danh sách đang ở.
2) Hệ thống hiển thị xác nhận trả phòng.
3) Lễ tân xác nhận.
4) Hệ thống đóng lượt (mốc trả), đặt trống + cần dọn, phát sự kiện housekeeping, nhật ký + realtime.
5) Phòng biến mất khỏi danh sách đang ở.

## Extensions

__4a. Không còn đang ở (E-check-in-out-005):__ từ chối + yêu cầu tải lại.
__4b. Mất mạng / sai quyền (E-check-in-out-007 / E-check-in-out-008).__
__Edge:__ Phòng ngừng phục vụ nhưng đang có khách — trả bình thường; sau trả vẫn ngừng phục vụ.
__OQ:__ `spec.md#OQ-3` — ghi chú tình trạng phòng khi trả?

## Related Requirements

- FR-check-in-out-004, FR-check-in-out-008, FR-check-in-out-009, FR-check-in-out-010
