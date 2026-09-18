# Use Case: Xử lý mất kết nối trên dashboard

## Primary Actor

Người xem dashboard

## Trigger

Mất liên lạc kênh realtime / mạng khi đang xem.

## Guarantees

- **Success Guarantee:** Banner mất kết nối + đánh dấu dữ liệu có thể lỗi thời; khi có mạng → tải trạng thái mới nhất + thông báo đã cập nhật (FR-009, E-001). Không im lặng giữ dữ liệu cũ như còn mới (NFR-003).

## Main Success Scenario

1) Hệ thống phát hiện mất kết nối.
2) Hiển thị banner E-001; đánh dấu dữ liệu có thể lỗi thời; không cung cấp thao tác ghi (dashboard vốn chỉ đọc).
3) Khi kết nối lại → tải trạng thái mới nhất (không ghép dữ liệu cũ) → gỡ banner / "Đã kết nối lại — dữ liệu đã cập nhật."

## Related Requirements

- FR-room-dashboard-009
- E-room-dashboard-001
