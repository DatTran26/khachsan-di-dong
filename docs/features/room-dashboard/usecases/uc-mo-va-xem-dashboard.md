# Use Case: Mở và xem dashboard tổng quan

> Scope: room-dashboard · Level: sea

## Primary Actor

Quản lý hoặc Lễ tân

## Trigger

Người dùng đủ quyền mở màn dashboard.

## Preconditions

- Đã đăng nhập; vai trò quản lý hoặc lễ tân (FR-room-dashboard-008).
- Danh mục phòng sẵn có từ `room-catalog`.

## Guarantees

- **Minimal Guarantee:** Tải thất bại → lỗi rõ + thử lại (E-room-dashboard-002); sai quyền → từ chối (E-room-dashboard-003); không hiện lưới trống như "không có phòng".
- **Success Guarantee:** Lưới toàn bộ phòng với 3 trục riêng; chỉ số tổng hợp tại thời điểm xem; mốc cập nhật cuối (Should).

## Main Success Scenario

1) Người dùng mở dashboard.
2) Hệ thống kiểm tra quyền xem ở máy chủ.
3) Hệ thống tải trạng thái 3 trục mọi phòng + cờ quá hạn từ feature nguồn.
4) Hệ thống hiển thị lưới không gộp 3 trục (BR-room-dashboard-001, FR-room-dashboard-001).
5) Hệ thống tính và hiển thị chỉ số: đang ở, sẵn sàng, cần dọn, ngừng phục vụ, việc quá hạn, tỷ lệ lấp đầy (FR-room-dashboard-002, FR-room-dashboard-003, FR-room-dashboard-004).
6) Hệ thống hiển thị mốc dữ liệu/cập nhật cuối (FR-room-dashboard-011).

## Extensions

**2a. Sai quyền (E-room-dashboard-003):** "Bạn không có quyền xem màn hình này."
**2b. Phiên hết hạn (E-room-dashboard-004):** chuyển đăng nhập lại (`auth-roles`).
**3a. Tải thất bại (E-room-dashboard-002):** "Không tải được dữ liệu dashboard. Thử lại." + nút tải lại.
**5a. Mẫu số lấp đầy = 0:** hiển thị "không áp dụng" (FR-004).
**OQ-4:** chạm ô phòng mở chi tiết — chưa chốt; v1 có thể chỉ lưới.

## Related Requirements

- FR-room-dashboard-001..004, 008, 010, 011
- BR-room-dashboard-001..003, 005, 006
