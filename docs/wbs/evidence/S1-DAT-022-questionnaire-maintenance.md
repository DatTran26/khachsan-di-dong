# S1-DAT-022 — Bộ Câu hỏi Phỏng vấn Nhân viên Bảo trì (STAFF)

- **WBS ID:** S1-DAT-022
- **Issue liên kết:** #59
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Hoàng Kim (HoangKim72)
- **Mốc tham chiếu:** 2026-09-08
- **Đầu ra bắt buộc:** Questionnaire bảo trì

---

## 1. Mục đích Khảo sát

Thu thập thông tin thực tế từ nhân viên kỹ thuật bảo trì về vòng đời xử lý sự cố kỹ thuật tại khách sạn 50 phòng: cách tiếp nhận báo hỏng, khi nào sự cố buộc phải khóa phòng (OUT_OF_SERVICE) để chặn lễ tân check-in, thời gian xử lý định mức, và điều kiện mở lại phòng (OPERATIONAL).

---

## 2. Danh mục Câu hỏi Phỏng vấn

### Phần A — Tiếp nhận Báo hỏng và Phân loại Mức độ
1. **Q-MNT-01:** Những loại sự cố kỹ thuật nào xảy ra thường xuyên nhất tại khách sạn (điều hòa, điện chiếu sáng, cấp thoát nước, khóa cửa từ, thiết bị vệ sinh)?
2. **Q-MNT-02:** Ai là người thường phát hiện và gửi báo hỏng đầu tiên (nhân viên buồng phòng khi đang dọn, lễ tân nghe khách phản ánh, hay quản lý đi kiểm tra)?
3. **Q-MNT-03:** Thông tin tối thiểu cần có trong một phiếu báo hỏng là gì để kỹ thuật viên mang đúng dụng cụ lên phòng ngay lần đầu (số phòng, mô tả lỗi, mức độ ưu tiên)?

### Phần B — Điều kiện Ngừng phục vụ Phòng (OUT_OF_SERVICE)
4. **Q-MNT-04:** Khi có phiếu báo hỏng, phòng đó có cần chuyển ngay sang trạng thái **Ngừng phục vụ (OUT_OF_SERVICE)** để lễ tân không vô tình xếp khách vào không?
5. **Q-MNT-05:** Nếu một phòng vừa sửa xong phần kỹ thuật nhưng quá trình sửa làm bẩn sàn/phòng tắm, phòng đó có được đón khách ngay hay phải giữ trạng thái vệ sinh DIRTY để buồng phòng dọn lại?

### Phần C — Xử lý, Mở lại việc và SLA Bảo trì
6. **Q-MNT-06:** Thời gian mục tiêu (SLA) để xử lý một sự cố bảo trì thông thường là bao lâu trước khi cần cảnh báo quá hạn cho quản lý (ví dụ: 120 phút)?
7. **Q-MNT-07:** Trong trường hợp đã bấm hoàn tất nhưng kiểm tra lại thấy lỗi tái phát, hệ thống cần hỗ trợ thao tác **Mở lại việc (eopen)** và khóa lại phòng như thế nào?
8. **Q-MNT-08:** Khi thao tác trên điện thoại Android tại khu kỹ thuật hoặc phòng kín sóng yếu, kỹ thuật viên cần phản hồi giao diện ra sao để tránh gửi trùng lệnh?

---

## 3. Ánh xạ sang Quy tắc Nghiệp vụ & State Machine

| Câu hỏi | Feature / State Machine | Quy tắc nghiệp vụ |
|---|---|---|
| Q-MNT-01 .. Q-MNT-03 | maintenance | Cho phép MANAGER, RECEPTIONIST, STAFF tạo báo hỏng kèm mô tả bắt buộc |
| Q-MNT-04 .. Q-MNT-05 | maintenance, check-in-out | Tạo báo hỏng chuyển maintenanceStatus = OUT_OF_SERVICE; mở lại phòng giữ nguyên trục cleaningStatus độc lập |
| Q-MNT-06 .. Q-MNT-07 | maintenance | Ngưỡng quá hạn bảo trì 120 phút; hỗ trợ OPEN -> IN_PROGRESS -> COMPLETED và eopen |
| Q-MNT-08 | ealtime-sync | Khóa nút ghi khi offline, kiểm tra ersion chống ghi đè |

## 4. Trạng thái Nghiệm thu

- [x] Đã hoàn thiện bộ 8 câu hỏi phỏng vấn Nhân viên bảo trì.
- [x] Đã gắn liên kết bằng chứng vào Issue #59.
- [ ] Chờ Reviewer (Hoàng) phê duyệt chính thức để đóng Issue.