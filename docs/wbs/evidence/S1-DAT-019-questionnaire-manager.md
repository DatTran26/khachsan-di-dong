# S1-DAT-019 — Bộ Câu hỏi Phỏng vấn Quản lý Khách sạn (MANAGER)

- **WBS ID:** S1-DAT-019
- **Issue liên kết:** #56
- **Sprint:** Sprint 1 — Khảo sát, phỏng vấn và phân tích yêu cầu
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Hoàng Kim (HoangKim72)
- **Mốc tham chiếu:** 2026-09-08
- **Đầu ra bắt buộc:** Questionnaire quản lý

---

## 1. Mục đích Khảo sát

Thu thập yêu cầu từ góc nhìn điều hành của **Quản lý khách sạn** đối với 4 nhóm chức năng chính:
1. Giám sát toàn cảnh 50 phòng trên Dashboard Web (oom-dashboard).
2. Công thức tính KPI công suất và cách xử lý phòng ngừng phục vụ (OUT_OF_SERVICE).
3. Phân quyền thao tác giữa Quản lý, Lễ tân và Nhân viên hiện trường (uth-roles, udit-log).
4. Quy tắc cảnh báo quá hạn (housekeeping, maintenance) và tóm tắt giao ca (i-ops-summary).

---

## 2. Danh mục Câu hỏi Phỏng vấn

### Phần A — Bảng điều khiển 50 phòng & KPI (15 phút)
1. **Q-MGR-01:** Khi mở màn hình quản lý đầu ca, anh/chị cần nhìn thấy những con số tổng hợp (KPI) nào đầu tiên trong vòng 5 giây?
2. **Q-MGR-02:** Khi một phòng đang bảo trì nặng (OUT_OF_SERVICE), phòng đó có được tính vào mẫu số công suất khai thác hay tách riêng? Nếu toàn bộ phòng trong bộ lọc đều ngừng phục vụ (mẫu số = 0) thì hiển thị thế nào?
3. **Q-MGR-03:** Trên mỗi ô phòng trong lưới 50 phòng, thông tin nào là bắt buộc phải hiện ngay (số phòng, loại phòng, khách đang ở, trạng thái vệ sinh, trạng thái kỹ thuật) mà không cần bấm vào từng phòng?
4. **Q-MGR-04:** Quản lý thường lọc phòng theo tiêu chí nào nhiều nhất (theo tầng 1–5, theo phòng cần dọn, phòng đang hỏng, hay phòng sẵn sàng)?

### Phần B — Điều phối việc dọn phòng, bảo trì & Escalation (15 phút)
5. **Q-MGR-05:** Sau khi khách check-out, bao lâu chưa bắt đầu/hoàn tất dọn thì bị coi là **quá hạn (overdue)**? Tương tự với sự cố bảo trì là bao lâu?
6. **Q-MGR-06:** Khi nhân viên buồng phòng báo đã dọn xong (COMPLETED), quản lý có cần bước nghiệm thu/xác nhận hoặc yêu cầu dọn lại không, hay lễ tân được xếp khách ngay?
7. **Q-MGR-07:** Khi có nhiều nhân viên đang trực, quy tắc phân công tự động ưu tiên theo tiêu chí nào (người ít việc mở nhất, thứ tự định danh)?

### Phần C — Phân quyền, Truy vết & Báo cáo Giao ca (15 phút)
8. **Q-MGR-08:** Những thao tác nào chỉ Quản lý mới được phép thực hiện (tạo/sửa danh mục phòng, tạo tài khoản, khóa tài khoản, đặt/gỡ OUT_OF_SERVICE, xem toàn bộ audit log)?
9. **Q-MGR-09:** Khi kiểm tra nhật ký thay đổi (udit-log), quản lý cần tra cứu theo phòng hay theo nhân viên thao tác, và cần thấy giá trị trước/sau (efore/fter) của những trường nào?
10. **Q-MGR-10:** Cuối ca làm việc, một bản tóm tắt vận hành tự động (AI Summary) cần nêu những mục nào, và giới hạn ngân sách/quyền riêng tư nào bắt buộc phải tuân thủ?

---

## 3. Ánh xạ Câu hỏi sang Feature MVP

| Câu hỏi | Feature đích | Tài liệu đặc tả liên quan |
|---|---|---|
| Q-MGR-01 .. Q-MGR-04 | oom-dashboard, oom-catalog | docs/features/room-dashboard/room-dashboard-prd.md |
| Q-MGR-05 .. Q-MGR-07 | housekeeping, maintenance | docs/features/housekeeping/housekeeping-prd.md |
| Q-MGR-08 .. Q-MGR-09 | uth-roles, udit-log | docs/features/auth-roles/auth-roles-prd.md |
| Q-MGR-10 | i-ops-summary | docs/features/ai-ops-summary/ai-ops-summary-prd.md |

## 4. Trạng thái Nghiệm thu

- [x] Đã hoàn thiện bộ 10 câu hỏi phỏng vấn Quản lý theo 3 nhóm chủ đề.
- [x] Đã gắn liên kết bằng chứng vào Issue #56.
- [ ] Chờ Reviewer (Hoàng) phê duyệt chính thức để đóng Issue.