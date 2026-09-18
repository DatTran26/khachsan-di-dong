# Use Case: Tạo và giao việc sau trả phòng

> Scope: housekeeping · Level: sea · FR-housekeeping-001..003

## Primary Actor

Hệ thống (sau sự kiện trả phòng từ feature nhận/trả phòng)

## Trigger

Phòng được trả thành công — sự kiện trả phòng tới feature housekeeping.

## Preconditions

- Sự kiện trả phòng hợp lệ cho một phòng thuộc danh mục.
- Trục lưu trú đã về trống (do feature nhận/trả phòng).

## Guarantees

- **Minimal Guarantee:** Không tạo việc trùng cho cùng một sự kiện trả phòng; nếu không có ai đang trực thì việc ở "chờ giao" và cảnh báo quản lý (E-housekeeping-002).
- **Success Guarantee:** Đúng 1 công việc dọn ở trạng thái phù hợp; trục vệ sinh phòng = "cần dọn"; đã giao cho NV đang trực ít việc mở nhất (BR-housekeeping-004) hoặc giữ "chờ giao"; nhật ký đã ghi (FR-housekeeping-013).

## Main Success Scenario

1) Hệ thống nhận sự kiện trả phòng cho phòng P.
2) Hệ thống tạo đúng 1 công việc dọn cho P; mốc tạo = giờ trả phòng; cờ quá hạn = chưa.
3) Hệ thống chuyển trục vệ sinh của P sang "cần dọn" (FR-housekeeping-001).
4) Hệ thống lấy danh sách nhân viên buồng phòng đang trực (nguồn — OQ-1).
5) Hệ thống chọn người có ít việc đang mở nhất; hòa → ưu tiên người lâu nhất chưa được giao (BR-housekeeping-004, FR-housekeeping-002).
6) Hệ thống gán việc cho người đó; trạng thái việc = "đã giao".
7) Hệ thống ghi nhật ký và phát cập nhật realtime.
8) Nhân viên được giao thấy việc trong danh sách việc của mình.

## Extensions

**4a. Không có nhân viên buồng phòng đang trực (FR-housekeeping-003, E-housekeeping-002):**
- 4a1. Hệ thống giữ việc ở "chờ giao".
- 4a2. Hệ thống cảnh báo quản lý: "Chưa có nhân viên buồng phòng đang trực — công việc đang chờ giao."
- 4a3. Khi có người vào trực → hệ thống tự giao theo bước 5–8.

**2a. Sự kiện trùng / việc đã tồn tại cho cùng lượt trả:**
- 2a1. Hệ thống không tạo việc thứ hai.
- 2a2. Use case kết thúc với Minimal Guarantee.

## Related Requirements

- FR-housekeeping-001, FR-housekeeping-002, FR-housekeeping-003, FR-housekeeping-013
- BR-housekeeping-004
- E-housekeeping-002
- OQ: `spec.md#OQ-1`
