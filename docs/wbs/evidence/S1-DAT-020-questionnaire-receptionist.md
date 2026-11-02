# S1-DAT-020 — Bộ Câu hỏi Phỏng vấn Lễ tân (RECEPTIONIST)

- **WBS ID:** S1-DAT-020
- **Issue liên kết:** #57
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Hoàng Kim (HoangKim72)
- **Mốc tham chiếu:** 2026-09-08
- **Đầu ra bắt buộc:** Questionnaire lễ tân

---

## 1. Mục đích Khảo sát

Làm rõ quy trình tác nghiệp tại quầy lễ tân trên **Flutter Web**: cách lễ tân tra cứu phòng trống, kiểm tra điều kiện phòng sẵn sàng đón khách, thông tin khách cần nhập lúc check-in, quy trình check-out tự động kích hoạt việc dọn phòng, và các tình huống xung đột khi hai người cùng thao tác.

---

## 2. Danh mục Câu hỏi Phỏng vấn

### Phần A — Tra cứu phòng và Điều kiện Nhận phòng (Check-in)
1. **Q-REC-01:** Khi khách đến nhận phòng trực tiếp (walk-in), lễ tân cần lọc theo những tiêu chí nào (loại phòng, số người tối đa, tầng) để chọn phòng nhanh nhất?
2. **Q-REC-02:** Những trường hợp nào đã từng khiến lễ tân giao nhầm phòng chưa sẵn sàng cho khách (phòng khách trước vừa trả nhưng chưa dọn, hoặc phòng đang chờ thợ sửa máy lạnh/ống nước)?
3. **Q-REC-03:** Khi hệ thống chặn không cho check-in vào một phòng không đủ điều kiện, lễ tân cần thông báo lỗi hiển thị rõ nguyên nhân cụ thể nào (ví dụ: đang có khách, chưa sạch, hay ngừng phục vụ)?
4. **Q-REC-04:** Thông tin khách tối thiểu bắt buộc phải lưu khi nhận phòng là gì (họ tên, số điện thoại, số khách, giờ dự kiến trả)? Có cần lưu số CCCD/hộ chiếu thật trong hệ thống thử nghiệm không?

### Phần B — Trả phòng (Check-out) và Phối hợp Buồng phòng
5. **Q-REC-05:** Ngay sau khi lễ tân bấm trả phòng (Check-out), trạng thái phòng và việc dọn phòng cần thay đổi như thế nào để bộ phận buồng phòng biết ngay mà không cần gọi bộ đàm/Zalo?
6. **Q-REC-06:** Nếu mạng tại quầy chập chờn khiến lễ tân bấm nút trả phòng 2 lần liên tiếp, hệ thống cần xử lý thế nào để không sinh ra 2 phiếu dọn phòng trùng nhau?

### Phần C — Báo hỏng từ quầy và Xử lý Mất kết nối / Xung đột
7. **Q-REC-07:** Khi khách đang ở hoặc vừa trả phòng báo hỏng thiết bị cho quầy lễ tân, lễ tân có được tạo phiếu báo hỏng trực tiếp trên Web không?
8. **Q-REC-08:** Nếu hai màn hình tại quầy cùng chọn check-in vào một phòng gần như đồng thời, hoặc khi mất kết nối mạng, giao diện cần khóa nút ghi và thông báo ra sao để lễ tân không thao tác nhầm trên dữ liệu cũ?

---

## 3. Ánh xạ sang Quy tắc Nghiệp vụ & Feature

| Câu hỏi | Feature liên quan | Quy tắc nghiệp vụ cốt lõi |
|---|---|---|
| Q-REC-01 .. Q-REC-03 | check-in-out, oom-catalog | Chỉ cho phép check-in khi occupancy=VACANT, cleaning=CLEAN, maintenance=OPERATIONAL |
| Q-REC-04 | check-in-out | Chỉ lưu tên khách, SĐT, số người; không lưu ảnh/số giấy tờ tùy thân thật |
| Q-REC-05 .. Q-REC-06 | check-in-out, housekeeping | Check-out atomic: đóng Stay, chuyển DIRTY, tạo 1 HousekeepingTask idempotent |
| Q-REC-07 .. Q-REC-08 | maintenance, ealtime-sync | Optimistic lock theo ersion, khóa nút ghi khi mất kết nối Socket.IO |

## 4. Trạng thái Nghiệm thu

- [x] Đã hoàn thiện bộ câu hỏi phỏng vấn Lễ tân gồm 8 câu hỏi trọng tâm.
- [x] Đã gắn liên kết bằng chứng vào Issue #57.
- [ ] Chờ Reviewer (Hoàng) phê duyệt chính thức để đóng Issue.