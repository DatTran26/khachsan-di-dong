# S1-DAT-021 — Bộ Câu hỏi Phỏng vấn Nhân viên Buồng phòng (STAFF)

- **WBS ID:** S1-DAT-021
- **Issue liên kết:** #58
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Hoàng Kim (HoangKim72)
- **Mốc tham chiếu:** 2026-09-08
- **Đầu ra bắt buộc:** Questionnaire buồng phòng

---

## 1. Mục đích Khảo sát

Thu thập yêu cầu thực tế của nhân viên buồng phòng khi làm việc di động giữa 5 tầng lầu với điện thoại **Android**: cách nhận phiếu dọn phòng, thứ tự ưu tiên, thời gian hoàn thành tiêu chuẩn, cách báo hỏng phát sinh khi đang dọn, và giới hạn số thao tác chạm trên màn hình.

---

## 2. Danh mục Câu hỏi Phỏng vấn

### Phần A — Nhận việc và Thứ tự Ưu tiên
1. **Q-HK-01:** Hiện tại chị/anh biết phòng nào khách vừa trả để lên dọn bằng cách nào (Zalo, bộ đàm, giấy ghi tay), và việc đó gây trễ hoặc sót phòng ra sao?
2. **Q-HK-02:** Khi mở ứng dụng trên điện thoại Android, thông tin nào cần hiện to, rõ nhất trong danh sách việc được giao (số phòng, tầng, hạn hoàn thành dueAt, mức ưu tiên)?
3. **Q-HK-03:** Trong trường hợp nhân viên đang bận dọn phòng khác hoặc không thể nhận việc vừa gán, quy trình từ chối/chuyển việc cần diễn ra như thế nào?

### Phần B — Quá trình Dọn phòng và Nghiệm thu
4. **Q-HK-04:** Thời gian trung bình để dọn xong một phòng tiêu chuẩn/gia đình là bao nhiêu phút? Mốc bao nhiêu phút kể từ lúc giao việc thì nên bật cảnh báo sắp trễ/quá hạn?
5. **Q-HK-05:** Khi hoàn tất dọn phòng, việc đính kèm ảnh nghiệm thu hoặc ghi chú kiểm tra có thuận tiện không?
6. **Q-HK-06:** Nếu trong lúc dọn phòng phát hiện thiết bị hỏng (vòi nước rò, điều hòa không lạnh, bóng đèn cháy), nhân viên buồng phòng cần thao tác báo hỏng ngay trên app như thế nào?

### Phần C — Trải nghiệm Điện thoại Android tại Hiện trường
7. **Q-HK-07:** Khi một tay đang cầm dụng cụ vệ sinh ở hành lang thiếu sáng hoặc sóng Wi-Fi yếu, kích thước nút bấm và số bước chạm tối đa từ lúc mở app tới lúc bấm "Bắt đầu dọn" / "Hoàn tất" là bao nhiêu?
8. **Q-HK-08:** Nếu đi vào góc khuất thang bộ bị rớt mạng tạm thời, ứng dụng cần hiển thị trạng thái gì để nhân viên biết thao tác chưa gửi đi và không bấm lặp nhiều lần?

---

## 3. Ánh xạ sang Yêu cầu Thiết kế & Kỹ thuật

| Câu hỏi | Feature / Module | Yêu cầu dẫn xuất |
|---|---|---|
| Q-HK-01 .. Q-HK-03 | housekeeping | Auto-assign theo nhân viên đang trực ít việc mở nhất; hỗ trợ claim / decline |
| Q-HK-04 .. Q-HK-05 | housekeeping | Hạn mặc định 30 phút; luồng PENDING -> IN_PROGRESS -> COMPLETED -> VERIFIED |
| Q-HK-06 | maintenance | Cho phép vai trò STAFF tạo báo hỏng trực tiếp gắn với phòng |
| Q-HK-07 .. Q-HK-08 | pp (Android UX), ealtime-sync | Touch target >= 48x48dp, tối đa 3 chạm, khóa nút ghi khi mất kết nối |

## 4. Trạng thái Nghiệm thu

- [x] Đã hoàn thiện bộ 8 câu hỏi phỏng vấn Nhân viên buồng phòng.
- [x] Đã gắn liên kết bằng chứng vào Issue #58.
- [ ] Chờ Reviewer (Hoàng) phê duyệt chính thức để đóng Issue.