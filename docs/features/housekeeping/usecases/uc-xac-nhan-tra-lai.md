# Use Case: Quản lý xác nhận hoặc trả lại việc dọn

> Scope: housekeeping · Level: sea · FR-housekeeping-006, FR-housekeeping-007

## Primary Actor

Quản lý

## Trigger

Quản lý mở việc "chờ xác nhận" và chọn xác nhận hoặc trả lại.

## Preconditions

- Quản lý đã đăng nhập.
- Việc đang ở "chờ xác nhận".

## Guarantees

- **Minimal Guarantee:** Trả lại không thành công nếu thiếu ghi chú; không đổi khi mất mạng/sai quyền.
- **Success Guarantee (xác nhận):** Việc = "hoàn tất"; phòng = "sạch"; "sẵn sàng" chỉ khi trống + sạch + đang phục vụ (BR-housekeeping-003); cờ quá hạn gỡ nếu có (FR-housekeeping-008).
- **Success Guarantee (trả lại):** Việc = "đang làm"; phòng = "đang dọn"; ghi chú không rỗng ≤500 ký tự hiển thị cho NV.

## Main Success Scenario (Xác nhận)

1) Quản lý mở hàng chờ xác nhận / chi tiết việc.
2) Quản lý bấm xác nhận sẵn sàng (BR-housekeeping-001).
3) Hệ thống kiểm tra quyền quản lý và phiên bản.
4) Hệ thống chuyển việc "hoàn tất", phòng "sạch" (FR-housekeeping-006).
5) Hệ thống đánh giá composite "sẵn sàng" = trống + sạch + đang phục vụ (FR-housekeeping-007) — không lưu state riêng.
6) Hệ thống gỡ cờ quá hạn nếu đang bật; ghi nhật ký + realtime.

## Extensions

**2a. Trả lại việc (FR-housekeeping-006, BR-housekeeping-005):**
- 2a1. Quản lý chọn trả lại và nhập ghi chú (bắt buộc, ≤500).
- 2a2. Thiếu ghi chú → E-housekeeping-005, giữ form.
- 2a3. Hợp lệ → việc "đang làm", phòng "đang dọn", kèm ghi chú cho NV; nhật ký + realtime.

**3a–3c:** E-housekeeping-003 / 004 / 006 như các UC ghi khác.

## Related Requirements

- FR-housekeeping-006, FR-housekeeping-007, FR-housekeeping-011, FR-housekeeping-013
- BR-housekeeping-001, BR-housekeeping-003, BR-housekeeping-005
- E-housekeeping-003, E-housekeeping-004, E-housekeeping-005, E-housekeeping-006
