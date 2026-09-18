# Use Case: Theo dõi realtime và cờ quá hạn trên dashboard

## Primary Actor

Hệ thống (hiển thị); Người xem (quan sát)

## Trigger

Feature nghiệp vụ ghi thành công thay đổi trạng thái / đánh hoặc gỡ cờ quá hạn; sự kiện tới qua `realtime-sync`.

## Preconditions

- Dashboard đang mở và đang kết nối.
- Cờ quá hạn do `housekeeping` / `maintenance` đánh theo quy tắc — dashboard không tự tính ngưỡng (BR-004). Ngưỡng bảo trì — OQ-1.

## Guarantees

- **Success Guarantee:** ≥95% cập nhật phản ánh ≤3 giây (FR-005, NFR-001); cờ quá hạn tô trên ô phòng + đếm chỉ số; cờ mất khi việc hoàn tất (FR-006).

## Main Success Scenario

1) Máy chủ lưu thay đổi từ feature nguồn và phát sự kiện.
2) Dashboard nhận sự kiện trong ≤3 giây.
3) Hệ thống cập nhật ô phòng (3 trục) và tính lại chỉ số tại chỗ, giữ ngữ cảnh lọc (NFR-005).
4) Nếu sự kiện mang cờ quá hạn → tô cờ + tăng chỉ số việc quá hạn; nếu gỡ cờ → bỏ tô + giảm đếm.

## Related Requirements

- FR-room-dashboard-005, FR-room-dashboard-006
- OQ: `spec.md#OQ-1`
