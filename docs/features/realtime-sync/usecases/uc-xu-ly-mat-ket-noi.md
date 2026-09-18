# Use Case: Xử lý mất kết nối và kết nối lại

> Scope: realtime-sync · Level: sea · CAP-realtime-sync-04, CAP-realtime-sync-05

## Primary Actor

Thiết bị người dùng

## Trigger

Thiết bị phát hiện mất liên lạc máy chủ; sau đó có mạng trở lại.

## Preconditions

- Người dùng đã đăng nhập (phiên có thể còn hạn hoặc hết hạn khi reconnect).

## Guarantees

- **Minimal Guarantee:** Khi mất kết nối — cảnh báo + khóa ghi; vẫn xem dữ liệu cuối (BR-realtime-sync-03).
- **Success Guarantee:** Khi reconnect — tải trạng thái mới trước khi mở khóa ghi (BR-realtime-sync-04); nếu phiên hết hạn → chuyển đăng nhập lại (FR-realtime-sync-010, E-realtime-sync-003).

## Main Success Scenario — Mất kết nối

1) Thiết bị phát hiện mất liên lạc máy chủ (ngưỡng thời gian: OQ-1 — chỉ ref).
2) Thiết bị hiển thị cảnh báo "mất kết nối" (banner thống nhất — FR-realtime-sync-007).
3) Thiết bị khóa mọi thao tác ghi; vẫn cho xem dữ liệu cuối.
4) Nếu user cố ghi → E-realtime-sync-001.

## Main Success Scenario — Kết nối lại

1) Có mạng trở lại; thiết bị tự kết nối lại.
2) Nếu phiên còn hạn → không yêu cầu đăng nhập lại.
3) Thiết bị tải trạng thái mới từ máy chủ (phạm vi tải: OQ-3 — chỉ ref).
4) Thiết bị mở khóa ghi; cập nhật banner "đã kết nối lại" nếu có.

## Extensions

**2a. Phiên hết hạn khi reconnect (E-realtime-sync-003):**
- 2a1. Hiển thị "Phiên đăng nhập đã hết — vui lòng đăng nhập lại."
- 2a2. Chuyển luồng đăng nhập (`auth-roles`); không tự ghi.

## Related Requirements

- FR-realtime-sync-005, FR-realtime-sync-006, FR-realtime-sync-007, FR-realtime-sync-010
- BR-realtime-sync-03, BR-realtime-sync-04
- CAP-realtime-sync-04, CAP-realtime-sync-05, CAP-realtime-sync-06
- E-realtime-sync-001, E-realtime-sync-003
