# S1-DAT-026 — Biên bản Phỏng vấn Nhân viên Buồng phòng

- **WBS ID:** S1-DAT-026
- **Issue liên kết:** #63
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Khách hàng
- **Mốc tham chiếu:** 2026-09-10
- **Đầu ra bắt buộc:** Interview notes buồng phòng

---

## 1. Tóm tắt Phiên Phỏng vấn

- **Người được phỏng vấn:** Tổ trưởng và nhân viên buồng phòng (STAFF)
- **Người thực hiện:** Trần Tấn Đạt, Hoàng Kim
- **Bộ câu hỏi sử dụng:** S1-DAT-021 (#58)

---

## 2. Ghi nhận Thực tế tại Hiện trường các Tầng

1. **Điều kiện thao tác:** Nhân viên di chuyển liên tục giữa 5 tầng, đẩy xe đồ vải và cầm dụng cụ vệ sinh nên thường chỉ rảnh **một tay** để xem điện thoại Android.
2. **Ánh sáng và kết nối:** Hành lang và góc cầu thang có độ sáng thay đổi, đôi khi sóng Wi-Fi chuyển vùng giữa các tầng bị ngắt quãng 2–5 giây.
3. **Thao tác mong muốn:** Không muốn gõ chữ dài trên điện thoại; ưu tiên các nút trạng thái lớn, rõ màu sắc và hoàn thành cập nhật trong **tối đa 3 chạm**.

---

## 3. Các Quyết định Nghiệp vụ và UX Đã Chốt

| Hạng mục | Nội dung thống nhất | Ánh xạ thiết kế / code |
|---|---|---|
| **Vòng đời việc dọn phòng** | PENDING (chờ nhận/bắt đầu) -> IN_PROGRESS (đang dọn) -> COMPLETED (đã dọn xong, phòng sang INSPECTING hoặc CLEAN theo cấu hình xác nhận) -> VERIFIED (quản lý xác nhận). | docs/features/housekeeping/srs/housekeeping-states.md |
| **Tự động phân công (Auto-assign)** | Khi check-out sinh việc dọn mới, hệ thống tự gán cho nhân viên STAFF đang active có ít việc mở nhất; nếu bằng nhau thì chọn theo id tăng dần. | server/src/services/housekeeping.service.ts |
| **Định mức thời gian (SLA)** | Mặc định dueAt = createdAt + 30 phút. Quá mốc này mà chưa hoàn tất thì đánh dấu quá hạn (isOverdue). | docs/features/housekeeping/srs/housekeeping-spec.md |
| **Giới hạn thao tác Android** | Nút hành động chính cao tối thiểu 48dp, khoảng cách >= 8dp, cập nhật trạng thái từ danh sách trong <= 3 chạm; hỗ trợ đính kèm ảnh nghiệm thu (proofPhotoUrl). | pp/lib/features/housekeeping/screens/housekeeping_screen.dart |

---

## 4. Liên kết Tài liệu trong Repo

- BRD Buồng phòng: [docs/features/housekeeping/housekeeping-brd.md](../../features/housekeeping/housekeeping-brd.md)
- URD Buồng phòng: [docs/features/housekeeping/housekeeping-urd.md](../../features/housekeeping/housekeeping-urd.md)

## 5. Trạng thái Nghiệm thu

- [x] Đã ghi nhận đầy đủ interview notes Buồng phòng và các ràng buộc thao tác Android.
- [x] Đã gắn liên kết bằng chứng vào Issue #63.
- [ ] Chờ Reviewer (Khách hàng) phê duyệt chính thức để đóng Issue.