# Use Case: Lọc lưới phòng trên dashboard

## Primary Actor

Quản lý, Lễ tân

## Trigger

Người xem chọn tầng và/hoặc nhóm trạng thái hiển thị.

## Preconditions

- Dashboard đã tải thành công.

## Guarantees

- **Success Guarantee:** Lưới chỉ còn phòng khớp; 0 kết quả → "Không có phòng nào khớp bộ lọc." (E-005, FR-007).

## Main Success Scenario

1) Người xem chọn lọc tầng và/hoặc nhóm: đang ở / sẵn sàng / cần dọn / ngừng phục vụ / quá hạn.
2) Hệ thống lọc lưới theo tiêu chí (phần giao nếu nhiều lọc).
3) Chỉ số có thể giữ toàn cục hoặc phản ánh phạm vi lọc — không chốt lại ngoài FR (FR chỉ yêu cầu lọc lưới).

## Extensions

**2a. Định nghĩa "cần dọn" trong lọc/chỉ số:** OQ-2 — chỉ trạng thái "cần dọn" hay mọi phòng chưa "sạch".

## Related Requirements

- FR-room-dashboard-007
- E-room-dashboard-005
- OQ: `spec.md#OQ-2`
