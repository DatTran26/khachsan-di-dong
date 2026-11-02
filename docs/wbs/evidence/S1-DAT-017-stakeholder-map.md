# S1-DAT-017 — Bản đồ Stakeholder và Thẩm quyền Phê duyệt Phạm vi

- **WBS ID:** S1-DAT-017
- **Issue liên kết:** #54
- **Sprint:** Sprint 1 — Khảo sát, phân tích yêu cầu và nền tảng kiến trúc
- **Owner:** Trần Tấn Đạt (DatTran26)
- **Reviewer / Acceptance Owner:** Team (WPCTeam & Giảng viên hướng dẫn)
- **Mốc tham chiếu:** 2026-09-08
- **Đầu ra bắt buộc:** Stakeholder map có người duyệt phạm vi

---

## 1. Mục tiêu

Xác định đầy đủ các bên liên quan (stakeholders) của hệ thống **Khách Sạn Di Động** (quy mô 50 phòng, 5 tầng), phân định rõ ai là Sponsor, ai có quyền chốt phạm vi (Scope Sign-off), ai là người dùng vận hành trực tiếp trên **Flutter Web** và **Android**, và cơ chế xử lý xung đột yêu cầu.

---

## 2. Danh sách Stakeholder và Vai trò

| Nhóm | Vai trò / Đại diện | Kênh làm việc chính | Mối quan tâm cốt lõi | Quyền quyết định |
|---|---|---|---|---|
| **Sponsor / Giảng viên** | Giảng viên hướng dẫn học phần QLDA CNTT | Buổi review định kỳ, báo cáo chương 1–9, buổi bảo vệ | Tuân thủ chuẩn PMBOK/Scrum, tiến độ 4 sprint, tính thực chất của MVP 9 feature và bằng chứng kiểm thử | Chấm điểm & nghiệm thu học thuật cuối kỳ |
| **Product Owner / Trưởng nhóm** | Trần Tấn Đạt (DatTran26) | GitHub Issues/PR, docs/, họp nhóm | Chốt phạm vi MVP, kiểm soát non-goal (không làm OTA/POS/iOS), bảo đảm hạn bàn giao 27/10/2026 | **Người duyệt phạm vi (Scope Approver)** cùng đại diện khách hàng |
| **Đại diện Khách hàng / Quản lý khách sạn** | Quản lý vận hành ca (MANAGER) | Flutter Web (desktop/tablet), phỏng vấn nghiệp vụ | Nhìn toàn cảnh 50 phòng trong 1 màn hình, phát hiện việc quá hạn >30p/>120p, xem tóm tắt ca AI không lộ PII | Duyệt quy trình TO-BE, KPI dashboard và kịch bản UAT |
| **Người dùng vận hành quầy** | Lễ tân (RECEPTIONIST) | Flutter Web tại quầy lễ tân | Check-in chỉ khi phòng đủ 3 điều kiện (VACANT + CLEAN + OPERATIONAL), check-out tạo việc dọn tự động | Xác nhận luồng nhận/trả phòng và thông báo lỗi tiếng Việt |
| **Người dùng hiện trường — Vệ sinh** | Nhân viên buồng phòng (STAFF) | Ứng dụng Android khi di chuyển giữa các tầng | Nhận việc dọn phòng tự động, cập nhật trạng thái nhanh (tối đa 2–3 chạm), chụp ảnh nghiệm thu | Xác nhận thao tác một tay và touch target >= 48dp |
| **Người dùng hiện trường — Kỹ thuật** | Nhân viên bảo trì (STAFF) | Ứng dụng Android tại phòng hỏng | Nhận phiếu báo hỏng, chuyển phòng sang OUT_OF_SERVICE, hoàn tất sửa chữa và mở lại phòng | Xác nhận điều kiện khóa phòng và mở lại phòng |
| **Đội phát triển kỹ thuật** | Ngô Quốc Bảo (NgoQuocBao24405), Hoàng Kim (HoangKim72) | GitHub (develop-bao, develop-kim), CI/CD | Rõ contract API, schema Prisma, Design Token, test tự động và quy trình GitFlow | Phản biện khả thi kỹ thuật (Socket.IO, PostgreSQL transaction) |

---

## 3. Ma trận RACI theo Đầu ra Dự án

| Hạng mục đầu ra | Quản lý KS / Khách hàng | PO (Đạt) | Dev Backend (Bảo) | Dev App/QA (Hoàng) | Giảng viên |
|---|---|---|---|---|---|
| Chốt phạm vi 9 feature MVP & Non-goals | **A** | **R** | C | C | I |
| Đặc tả BRD / PRD / URD / SRS | C | **R/A** | C | C | I |
| Thiết kế kiến trúc API, DB, Realtime | I | **A** | **R** | C | I |
| Thiết kế UI/UX, Design Token, Accessibility | C | **A** | I | **R** | I |
| Nghiệm thu UAT (AC-01 .. AC-09) | **A** | **R** | C | **R** | I |

*(R = Responsible, A = Accountable, C = Consulted, I = Informed)*

---

## 4. Quy tắc Phê duyệt Phạm vi (Scope Sign-off Rules)

1. **Mọi yêu cầu thêm/bớt feature** phải đối chiếu với 9 feature trong docs/project-charter.md và docs/_product/prd.md.
2. **Người có thẩm quyền ký duyệt baseline:** Trần Tấn Đạt (PO) và Đại diện Quản lý khách sạn.
3. **Các hạng mục ngoài phạm vi (Non-goals) đã khóa:** thanh toán/hóa đơn VAT, kết nối kênh OTA, quản lý kho/minibar, ứng dụng iOS, tự động ra quyết định bằng AI.

---

## 5. Đối chiếu Nguồn trong Repository

- Tôn chỉ dự án: [docs/project-charter.md](../../project-charter.md)
- PRD sản phẩm: [docs/_product/prd.md](../../_product/prd.md)
- Hồ sơ dự án: [docs/_shared/project-profile.md](../../_shared/project-profile.md)

## 6. Trạng thái Nghiệm thu

- [x] Đã lập bản đồ stakeholder và ma trận thẩm quyền phê duyệt phạm vi.
- [x] Đã gắn liên kết bằng chứng vào Issue #54.
- [ ] Chờ Reviewer (Team) phê duyệt chính thức để đóng Issue.