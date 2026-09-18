# Use Case: Đặt hoặc gỡ ngừng phục vụ thủ công

> Scope: maintenance · Level: sea · CAP-maintenance-07

## Primary Actor

Lễ tân hoặc Quản lý

## Trigger

Lễ tân/quản lý đặt hoặc gỡ cờ "ngừng phục vụ" tay trên một phòng.

## Preconditions

- Người dùng đã đăng nhập với vai trò lễ tân hoặc quản lý.
- Phòng thuộc danh mục.

## Guarantees

- **Minimal Guarantee:** Không gỡ tay khi còn việc bảo trì đang mở; không đặt tay thiếu lý do; không ghi khi mất mạng.
- **Success Guarantee:** Cờ ngừng tay được đặt/gỡ đúng; trục bảo trì phản ánh đúng nguồn độc lập với việc mở (BR-maintenance-07); nhật ký + realtime; chặn/mở nhận khách theo quy tắc `check-in-out`.

## Main Success Scenario — Đặt ngừng tay

1) Lễ tân/quản lý mở màn đặt/gỡ ngừng phục vụ cho phòng.
2) Người dùng nhập lý do bắt buộc (≤200 ký tự) và xác nhận đặt.
3) Hệ thống kiểm tra quyền (BR-maintenance-04).
4) Hệ thống đặt cờ ngừng tay; trục bảo trì "ngừng phục vụ".
5) Hệ thống ghi nhật ký và phát realtime.
6) Hệ thống xác nhận đã đặt ngừng.

## Main Success Scenario — Gỡ ngừng tay

1) Lễ tân/quản lý chọn gỡ ngừng tay trên phòng đang có cờ tay.
2) Hệ thống kiểm tra không còn việc bảo trì đang mở (FR-maintenance-007).
3) Hệ thống gỡ cờ tay; nếu không còn nguồn ngừng khác → trục về "bình thường".
4) Hệ thống ghi nhật ký và phát realtime.
5) Hệ thống xác nhận đã gỡ.

## Extensions

**Đặt 2a. Thiếu lý do:**
- 2a1. Giữ form, yêu cầu nhập lý do (theo BR-maintenance-04).

**Gỡ 2a. Còn việc mở (E-maintenance-005):**
- 2a1. Từ chối, báo "Phòng còn việc bảo trì đang xử lý — hãy hoàn tất hoặc hủy việc trước."
- 2a2. Giữ trạng thái hiện tại.

**Chung. Sai quyền (E-maintenance-006) / mất mạng (E-maintenance-002):**
- Từ chối hoặc khóa ghi theo Error Matrix.

## Related Requirements

- FR-maintenance-007, FR-maintenance-011
- BR-maintenance-04, BR-maintenance-06, BR-maintenance-07
- CAP-maintenance-07
