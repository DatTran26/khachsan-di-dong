# Use Case: Báo hỏng phòng

> Scope: maintenance · Level: sea · CAP-maintenance-01, CAP-maintenance-02

## Primary Actor

Mọi vai trò đã đăng nhập (người báo hỏng)

## Trigger

Người dùng mở form báo hỏng và gửi báo cáo hỏng hóc cho một phòng.

## Preconditions

- Người dùng đã đăng nhập (theo `auth-roles`).
- Phòng thuộc danh mục `room-catalog`.

## Guarantees

- **Minimal Guarantee:** Không tạo việc khi thiếu mô tả hoặc mất mạng; form giữ dữ liệu đã nhập khi lỗi validation.
- **Success Guarantee:** Việc bảo trì mới ở trạng thái "chờ nhận"; trục bảo trì phòng là "ngừng phục vụ" nếu đây là việc mở đầu tiên; nhật ký ghi nhận; sự kiện realtime được phát (qua `realtime-sync`).

## Main Success Scenario

1) Người báo mở form báo hỏng.
2) Người báo chọn phòng (bắt buộc), nhập mô tả (bắt buộc, ≤500 ký tự), có thể nhập vị trí/hạng mục (tùy chọn, ≤100 ký tự).
3) Hệ thống kiểm tra quyền và dữ liệu bắt buộc.
4) Hệ thống tạo việc bảo trì ở "chờ nhận", gắn người báo.
5) Nếu phòng chưa có việc mở → hệ thống đặt trục bảo trì thành "ngừng phục vụ" (BR-maintenance-01, FR-maintenance-002).
6) Hệ thống ghi nhật ký và phát cập nhật realtime (FR-maintenance-011).
7) Hệ thống xác nhận đã tạo việc cho người báo.

## Extensions

**2a. Phòng đã có việc bảo trì đang mở (FR-maintenance-008):**
- 2a1. Hệ thống vẫn cho tạo việc mới kèm cảnh báo nhẹ "đang có việc mở".
- 2a2. Tiếp tục bước 3.

**3a. Thiếu mô tả (E-maintenance-003):**
- 3a1. Hệ thống giữ form, báo "Vui lòng nhập mô tả hỏng hóc."
- 3a2. Use case kết thúc với Minimal Guarantee.

**3b. Sai quyền (E-maintenance-006):**
- 3b1. Hệ thống từ chối + ghi nhật ký.
- 3b2. Use case kết thúc.

**4a. Mất mạng khi ghi (E-maintenance-002):**
- 4a1. Hệ thống khóa ghi, báo chưa lưu; cho thử lại khi có mạng.
- 4a2. Use case kết thúc với Minimal Guarantee.

## Related Requirements

- FR-maintenance-001, FR-maintenance-002, FR-maintenance-008, FR-maintenance-011
- BR-maintenance-01, BR-maintenance-06, BR-maintenance-07
- CAP-maintenance-01, CAP-maintenance-02
