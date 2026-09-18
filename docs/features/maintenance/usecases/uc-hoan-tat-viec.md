# Use Case: Báo hoàn tất việc bảo trì

> Scope: maintenance · Level: sea · CAP-maintenance-03, CAP-maintenance-04

## Primary Actor

Nhân viên bảo trì (người đang xử lý việc)

## Trigger

Nhân viên báo hoàn tất việc do chính mình đang sửa.

## Preconditions

- Việc ở trạng thái "đang sửa" và người xử lý là nhân viên hiện tại.
- Nhân viên đã đăng nhập đúng vai trò.

## Guarantees

- **Minimal Guarantee:** Việc không đóng nếu sai người/sai trạng thái/mất mạng.
- **Success Guarantee:** Việc chuyển "hoàn tất" (đóng, không mở lại — BR-maintenance-05); nếu phòng hết việc mở và không cờ ngừng tay → trục bảo trì về "bình thường" (FR-maintenance-003); nhật ký + realtime.

## Main Success Scenario

1) Nhân viên mở chi tiết việc "đang sửa" của mình.
2) Nhân viên chọn báo hoàn tất.
3) Hệ thống kiểm tra quyền và đúng người xử lý (BR-maintenance-03).
4) Hệ thống chuyển việc sang "hoàn tất".
5) Hệ thống đánh giá lại trục bảo trì phòng: hết việc mở + không cờ ngừng tay → "bình thường" (BR-maintenance-01, BR-maintenance-07).
6) Hệ thống ghi nhật ký và phát realtime.
7) Hệ thống xác nhận hoàn tất.

## Extensions

**3a. Sai quyền / không phải việc của mình (E-maintenance-006):**
- 3a1. Từ chối + ghi nhật ký.

**3b. Sai trạng thái (E-maintenance-004):**
- 3b1. Từ chối + gợi ý tải lại.

**4a. Mất mạng (E-maintenance-002):**
- 4a1. Khóa ghi, báo chưa lưu.

## Related Requirements

- FR-maintenance-003, FR-maintenance-005, FR-maintenance-011
- BR-maintenance-01, BR-maintenance-03, BR-maintenance-05, BR-maintenance-07
- CAP-maintenance-03, CAP-maintenance-04
