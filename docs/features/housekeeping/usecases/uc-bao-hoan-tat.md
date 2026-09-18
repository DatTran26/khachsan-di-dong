# Use Case: Báo hoàn tất việc dọn

> Scope: housekeeping · Level: sea · FR-housekeeping-005

## Primary Actor

Nhân viên buồng phòng

## Trigger

Nhân viên đang làm việc dọn bấm báo hoàn tất.

## Preconditions

- Việc đang ở "đang làm" và gắn nhân viên hiện tại.
- Có kết nối mạng để ghi.

## Guarantees

- **Minimal Guarantee:** Không chuyển trạng thái khi lỗi mạng/quyền/xung đột.
- **Success Guarantee:** Việc = "chờ xác nhận"; phòng = "chờ kiểm tra"; quản lý được thông báo; nhật ký + realtime.

## Main Success Scenario

1) Nhân viên mở chi tiết việc "đang làm".
2) Nhân viên bấm báo hoàn tất.
3) Hệ thống kiểm tra quyền và phiên bản.
4) Hệ thống chuyển việc sang "chờ xác nhận"; phòng sang "chờ kiểm tra" (FR-housekeeping-005).
5) Hệ thống thông báo quản lý (hàng chờ xác nhận / realtime).
6) Hệ thống ghi nhật ký và phát realtime.

## Extensions

**3a. Sai trạng thái / xung đột (E-housekeeping-004):** tải lại.
**3b. Sai quyền (E-housekeeping-006):** từ chối.
**3c. Mất mạng (E-housekeeping-003):** khóa ghi, báo chưa lưu.

## Related Requirements

- FR-housekeeping-005, FR-housekeeping-011, FR-housekeeping-012, FR-housekeeping-013
