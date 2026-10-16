# Use Case: Nộp ảnh nghiệm thu sau dọn phòng

> Scope: housekeeping · Level: sea · FR-housekeeping-005, FR-housekeeping-006, FR-housekeeping-007

## Primary Actor

Nhân viên buồng phòng.

## Trigger

Nhân viên đã dọn xong phòng và chọn **Báo hoàn tất**.

## Preconditions

- Việc ở trạng thái `đang làm` và thuộc nhân viên hiện tại.
- Nhân viên đang ở sau thời điểm trả phòng; giao diện nhắc không chụp đồ cá nhân của khách.

## Main Success Scenario

1. Nhân viên mở chi tiết việc và chọn thêm ảnh nghiệm thu.
2. Ứng dụng hướng dẫn ba nhóm bắt buộc: tổng quan phòng, khu ngủ/giường và nhà vệ sinh.
3. Ứng dụng hiển thị tiến trình tải từng ảnh; nhân viên có thể mở lại ảnh để kiểm tra chi tiết.
4. Khi cả ba nhóm tải thành công, ứng dụng cho phép bấm **Báo hoàn tất**.
5. Hệ thống ghi lần nộp ảnh vào nhật ký; quản lý nhận việc chờ xác nhận có gallery ảnh theo đúng thứ tự nhóm.

## Extensions

- 3a. Ảnh mờ hoặc không đúng khu vực: nhân viên chụp lại/thay ảnh trước khi báo hoàn tất.
- 4a. Thiếu nhóm ảnh hoặc tệp chưa tải xong: hiển thị E-housekeeping-007 và giữ việc ở `đang làm`.
- 5a. Quản lý phát hiện bất thường: trả lại việc với ghi chú; ảnh lần nộp cũ vẫn giữ để truy vết.

## Guarantees

- **Minimal Guarantee:** không thay đổi trạng thái việc/phòng khi bộ ảnh thiếu hoặc lỗi.
- **Success Guarantee:** bộ ảnh thuộc đúng công việc dọn, quản lý xem được trước quyết định xác nhận.
