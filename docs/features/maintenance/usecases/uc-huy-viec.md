# Use Case: Hủy việc bảo trì chờ nhận

> Scope: maintenance · Level: sea · CAP-maintenance-08

## Primary Actor

Người báo hoặc Quản lý

## Trigger

Người báo/quản lý hủy một việc đang "chờ nhận".

## Preconditions

- Việc ở trạng thái "chờ nhận".
- Người thao tác là người báo của việc hoặc quản lý.

## Guarantees

- **Minimal Guarantee:** Việc không hủy nếu sai trạng thái/mất mạng/sai quyền.
- **Success Guarantee:** Việc chuyển "đã hủy" (đóng); lý do hủy tùy chọn ≤200 ký tự; nếu hết việc mở + không cờ ngừng tay → phòng về "bình thường"; nhật ký + realtime.

## Main Success Scenario

1) Người báo/quản lý mở chi tiết việc "chờ nhận".
2) Người dùng chọn hủy, có thể nhập lý do (≤200 ký tự).
3) Hệ thống kiểm tra quyền và trạng thái "chờ nhận" (FR-maintenance-006).
4) Hệ thống chuyển việc sang "đã hủy".
5) Hệ thống đánh giá lại trục bảo trì phòng (FR-maintenance-003).
6) Hệ thống ghi nhật ký và phát realtime.
7) Hệ thống xác nhận đã hủy.

## Extensions

**3a. Việc đã "đang sửa" — người báo thường (E-maintenance-004):**
- 3a1. Từ chối thao tác; gợi ý tải lại / nhờ quản lý xử lý theo spec.

**3b. Sai quyền (E-maintenance-006):**
- 3b1. Từ chối + ghi nhật ký.

**4a. Mất mạng (E-maintenance-002):**
- 4a1. Khóa ghi, báo chưa lưu.

## Related Requirements

- FR-maintenance-003, FR-maintenance-006, FR-maintenance-011
- BR-maintenance-05
- CAP-maintenance-08
