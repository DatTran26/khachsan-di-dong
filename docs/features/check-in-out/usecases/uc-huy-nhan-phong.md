# Use Case: Hủy nhận phòng

> Scope: Check-in-out · Level: sea

## Primary Actor

Lễ tân

## Trigger

Lễ tân hủy nhận phòng nhầm trong cửa sổ ngắn sau nhận.

## Preconditions

- Có lượt lưu trú mở vừa nhận.
- Chưa phát sinh hoạt động khác (điều kiện cụ thể — OQ-2).

## Guarantees

- __Minimal Guarantee:__ Ngoài cửa sổ / đã phát sinh → không hủy; hướng dẫn trả phòng.
- __Success Guarantee:__ Lượt đánh dấu hủy; lưu trú = trống; vệ sinh giữ trạng thái trước nhận; KHÔNG phát sự kiện trả phòng; nhật ký rõ hủy.

## Main Success Scenario

1) Lễ tân chọn lượt vừa nhận và chọn hủy nhận.
2) Hệ thống kiểm tra cửa sổ ngắn + chưa phát sinh hoạt động khác.
3) Hệ thống đánh dấu hủy, đưa lưu trú về trống, giữ vệ sinh trước nhận.
4) Nhật ký ghi hủy; realtime; không tạo việc dọn.

## Extensions

__2a. Quá cửa sổ / đã phát sinh (E-check-in-out-006):__ từ chối, hướng dẫn dùng Trả phòng.
__OQ:__ `spec.md#OQ-2`

## Related Requirements

- FR-check-in-out-006, FR-check-in-out-009, FR-check-in-out-010
