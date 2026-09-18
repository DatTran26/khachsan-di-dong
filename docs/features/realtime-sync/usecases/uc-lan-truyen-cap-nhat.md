# Use Case: Lan truyền cập nhật realtime

> Scope: realtime-sync · Level: sea · CAP-realtime-sync-01, CAP-realtime-sync-02

## Primary Actor

Máy chủ (phối hợp thiết bị nhận)

## Trigger

Một thay đổi trạng thái nghiệp vụ được máy chủ lưu thành công.

## Preconditions

- Có ít nhất một thiết bị đang kết nối.
- Thao tác ghi đã vượt kiểm quyền (`auth-roles`).

## Guarantees

- **Minimal Guarantee:** Không phát sự kiện nếu chưa lưu thành công (BR-realtime-sync-01).
- **Success Guarantee:** Sự kiện mang trạng thái + phiên bản mới; thiết bị nhận áp dụng và hiển thị trong ≤3 giây (FR-realtime-sync-002); đối tượng không đang hiển thị được cập nhật nền (FR-realtime-sync-009).

## Main Success Scenario

1) Feature nghiệp vụ gửi thay đổi trạng thái tới máy chủ kèm phiên bản.
2) Máy chủ lưu thành công và tăng phiên bản đối tượng.
3) Máy chủ phát sự kiện cập nhật tới các thiết bị đang kết nối.
4) Thiết bị nhận áp dụng trạng thái mới.
5) Nếu đối tượng đang hiển thị → UI cập nhật; nếu không → cập nhật nền, không làm phiền màn hiện tại.
6) (P1) Hệ thống ghi nhận độ trễ lượt phát (FR-realtime-sync-008).

## Extensions

**2a. Lưu thất bại:**
- 2a1. Không phát sự kiện; báo lỗi về thiết bị ghi theo feature nghiệp vụ.
- 2a2. Use case kết thúc với Minimal Guarantee.

**4a. Áp dụng sự kiện thất bại trên thiết bị (E-realtime-sync-004):**
- 4a1. Không hiển thị lỗi cho user; thiết bị tải lại trạng thái mới từ máy chủ.

## Related Requirements

- FR-realtime-sync-001, FR-realtime-sync-002, FR-realtime-sync-008, FR-realtime-sync-009
- BR-realtime-sync-01, BR-realtime-sync-05
- CAP-realtime-sync-01, CAP-realtime-sync-02
