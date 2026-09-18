# Use Case: Nhận phòng

> Scope: Check-in-out · Level: sea

## Primary Actor

Lễ tân

## Trigger

Lễ tân chọn phòng sẵn sàng và mở form nhận phòng.

## Preconditions

- Lễ tân đã đăng nhập.
- Phòng tồn tại trong `room-catalog`.

## Guarantees

- __Minimal Guarantee:__ Không đủ điều kiện hoặc thiếu thông tin khách → không tạo lượt, không đổi trục.
- __Success Guarantee:__ Lượt lưu trú mở được tạo; lưu trú = đang ở; nhật ký + realtime; tối đa 1 lượt mở/phòng.

## Main Success Scenario

1) Lễ tân chọn phòng sẵn sàng (từ tra cứu room-catalog).
2) Hệ thống mở form: tên khách + số người (bắt buộc — giả định OQ-1); ghi chú ≤500 và ngày dự kiến trả tùy chọn (P1).
3) Lễ tân nhập và xác nhận.
4) Hệ thống kiểm tra LẠI 3 điều kiện tại thời điểm ghi: trống + sạch + bình thường.
5) Hệ thống tạo lượt mở, đặt lưu trú = đang ở, ghi nhật ký, phát realtime.
6) Hệ thống cập nhật danh sách đang ở.

## Extensions

__4a. Phòng đang ở (E-check-in-out-001):__ chặn + "Phòng đang có khách — không thể nhận."
__4b. Chưa sạch (E-check-in-out-002):__ chặn + trạng thái vệ sinh cụ thể.
__4c. Ngừng phục vụ (E-check-in-out-003):__ chặn.
__3a. Thiếu tên khách / số người (E-check-in-out-004):__ từ chối, chỉ rõ trường, giữ form.
__5a. Mất mạng / sai quyền (E-check-in-out-007 / E-check-in-out-008):__ từ chối theo Error Matrix.

## Related Requirements

- FR-check-in-out-001..003, FR-check-in-out-007, FR-check-in-out-008, FR-check-in-out-009, FR-check-in-out-010
- OQ: `spec.md#OQ-1`
