# Use Case: Xử lý xung đột phiên bản khi ghi

> Scope: realtime-sync · Level: sea · CAP-realtime-sync-03

## Primary Actor

Thiết bị người dùng (đang ghi)

## Trigger

Thiết bị gửi thao tác ghi kèm phiên bản không khớp máy chủ.

## Preconditions

- Thiết bị đang kết nối.
- Đối tượng đã có phiên bản mới hơn trên máy chủ (người khác đã cập nhật).

## Guarantees

- **Minimal Guarantee:** Không ghi đè dữ liệu máy chủ (BR-realtime-sync-02); 0 ca ghi đè.
- **Success Guarantee:** Ghi bị từ chối; thiết bị nhận thông báo và tải trạng thái mới (FR-realtime-sync-004, E-realtime-sync-002).

## Main Success Scenario

1) Người dùng thực hiện ghi trên đối tượng (kèm phiên bản hiện có trên thiết bị).
2) Máy chủ so khớp phiên bản.
3) Phiên bản không khớp → máy chủ từ chối ghi, không ghi đè.
4) Máy chủ/thiết bị báo "Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất."
5) Thiết bị tải và hiển thị trạng thái mới nhất.

## Extensions

**OQ-2 (ref only):** Có giữ nội dung vừa nhập để nhập lại hay không — xem `spec.md#OQ-2`. Không chốt trong UC này.

## Related Requirements

- FR-realtime-sync-003, FR-realtime-sync-004
- BR-realtime-sync-02
- CAP-realtime-sync-03
- E-realtime-sync-002
