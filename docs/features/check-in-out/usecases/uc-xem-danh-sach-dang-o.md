# Use Case: Xem danh sách phòng đang ở

> Scope: Check-in-out · Level: sea

## Primary Actor

Lễ tân, Quản lý

## Trigger

Actor mở màn danh sách phòng đang ở.

## Preconditions

- Actor đã đăng nhập.

## Guarantees

- __Minimal Guarantee:__ Danh sách rỗng hiển thị trạng thái rỗng.
- __Success Guarantee:__ Mỗi dòng có phòng + khách + mốc nhận; cập nhật realtime.

## Main Success Scenario

1) Actor mở danh sách đang ở.
2) Hệ thống tải các lượt lưu trú mở.
3) Hệ thống hiển thị phòng, tên khách, số người, mốc nhận (và ghi chú/ngày dự kiến trả nếu có).
4) Khi có nhận/trả/hủy realtime, danh sách cập nhật.

## Extensions

__2a. Không có phòng đang ở:__ trạng thái rỗng.
__OQ:__ `spec.md#OQ-4` — lễ tân xem lịch sử lượt đã đóng?

## Related Requirements

- FR-check-in-out-005
