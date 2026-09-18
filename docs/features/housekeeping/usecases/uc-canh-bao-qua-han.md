# Use Case: Cảnh báo việc dọn quá hạn

> Scope: housekeeping · Level: sea · FR-housekeeping-008

## Primary Actor

Hệ thống

## Trigger

Chu kỳ quét / đánh giá ngưỡng: công việc chưa "hoàn tất" và đã vượt 60 phút kể từ mốc tạo (giờ trả phòng).

## Preconditions

- Việc đang mở (chưa "hoàn tất").
- Mốc tạo đã xác định.

## Guarantees

- **Minimal Guarantee:** Không đánh cờ sai việc đã hoàn tất.
- **Success Guarantee:** Cờ "quá hạn" bật; cảnh báo quản lý (dashboard) và NV phụ trách (trong app); cờ tự gỡ khi việc hoàn tất (FR-housekeeping-008). Đo tới mốc NV báo hoàn tất — không gồm thời gian chờ quản lý xác nhận (BR-housekeeping-002).

## Main Success Scenario

1) Hệ thống phát hiện việc vượt 60 phút chưa hoàn tất (BR-housekeeping-002).
2) Hệ thống đánh cờ "quá hạn" trên việc.
3) Hệ thống cảnh báo quản lý và nhân viên phụ trách.
4) Khi việc chuyển "hoàn tất" → hệ thống gỡ cờ.

## Extensions

**1a. Tần suất cảnh báo lặp lại:** phụ thuộc OQ-2 — không chốt trong UC; chỉ đảm bảo đánh cờ khi vượt ngưỡng trong chu kỳ quét kế tiếp (SC-housekeeping-04 ≤1 phút sau ngưỡng).
**1b. Việc "chờ xác nhận" quá lâu:** ngưỡng nhắc riêng cho QL — OQ-3; ngoài phạm vi chốt hiện tại.

## Related Requirements

- FR-housekeeping-008
- BR-housekeeping-002
- OQ: `spec.md#OQ-2`, `spec.md#OQ-3`
