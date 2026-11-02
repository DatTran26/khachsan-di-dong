# S2-BAO-003 — Migration MaintenanceTask: trạng thái, người báo, người nhận, dueAt, mô tả hỏng

- **WBS ID:** `S2-BAO-003`
- **Issue liên kết:** Refs #147
- **Sprint:** Sprint 2 — Nghiệp vụ vận hành cốt lõi (Check-in/out, Dọn phòng, Bảo trì, Audit)
- **Owner:** Bảo
- **Reviewer / Acceptance Owner:** Đạt
- **Workstream:** Check-in, check-out, housekeeping, maintenance, audit log và Socket.IO
- **Mốc tham chiếu:** `2026-09-24 đến 2026-09-24`
- **Đầu ra bắt buộc:** Migration maintenance
- **Tiêu chuẩn nghiệm thu:** Evidence kỹ thuật và review/UAT theo loại task
- **Nguồn baseline đối chiếu:** chưa có trong repository tại 24/09/2026

---

## 1. Mục tiêu và Bối cảnh Nghiệp vụ (Objective & Context)

Gói công việc **`S2-BAO-003`** chịu trách nhiệm cung cấp và chuẩn hóa đầu ra: **Migration maintenance**.
Trong hệ thống **Khách Sạn Di Động** (quy mô 50 phòng / 5 tầng), gói công việc này bảo đảm sự thống nhất giữa quầy lễ tân (`Flutter Web`), nhân viên hiện trường (`Android`) và hệ thống máy chủ (`Express + Prisma + PostgreSQL`), bám sát 9 feature MVP:
1. `auth-roles`: Phân quyền 3 vai trò (`MANAGER`, `RECEPTIONIST`, `STAFF`).
2. `room-catalog`: Danh mục 50 phòng và 3 trục trạng thái độc lập.
3. `check-in-out`: Điều kiện phòng sẵn sàng (`VACANT` + `CLEAN` + `OPERATIONAL`) và check-out tạo việc dọn.
4. `housekeeping`: Phân công việc dọn phòng, SLA 30 phút và quy trình nghiệm thu.
5. `maintenance`: Báo hỏng, khóa phòng `OUT_OF_SERVICE`, sửa chữa và mở lại phòng.
6. `audit-log`: Ghi nhận nhật ký `before`/`after` trong transaction, bảo mật dữ liệu PII.
7. `realtime-sync`: Đồng bộ Socket.IO, khóa nút ghi khi rớt mạng, chống ghi đè bằng `version`.
8. `room-dashboard`: Giám sát 50 phòng, KPI công suất và cảnh báo việc quá hạn.
9. `ai-ops-summary`: Tóm tắt vận hành ca/ngày có kiểm soát chi phí (<= 300.000 VNĐ) và fallback tất định.

---

## 2. Chi tiết Nội dung Đầu ra (Deliverable Specification)

### 2.1. Yêu cầu chi tiết của Migration maintenance
- **Phạm vi triển khai:** Thực hiện đầy đủ các tiêu chí được nêu trong WBS và Issue liên kết (Refs #147).
- **Chi tiết đầu ra:**
  - Mô tả rõ ràng vai trò trách nhiệm của từng bên liên quan (Owner: Bảo, Reviewer: Đạt).
  - Xác lập các ràng buộc dữ liệu và giao diện tương ứng với vai trò sử dụng.
  - Cung cấp minh chứng cụ thể, tránh dùng title hoặc mô tả chung chung.

### 2.2. Ma trận Trạng thái và Tiêu chuẩn Thao tác Liên quan
- Đảm bảo tính nhất quán của mô hình 3 trục trạng thái phòng:
  - **Lưu trú (`OccupancyStatus`):** `VACANT` | `OCCUPIED`
  - **Vệ sinh (`CleaningStatus`):** `CLEAN` | `DIRTY` | `INSPECTING`
  - **Bảo trì (`MaintenanceStatus`):** `OPERATIONAL` | `OUT_OF_SERVICE`
- Bất kỳ thao tác chuyển trạng thái nào cũng phải được ghi lại nhật ký truy vết (`AuditLog`) với định danh tài khoản thực hiện.

---

## 3. Quy tắc Nghiệp vụ và Ràng buộc Kỹ thuật (Business Rules & Constraints)

1. **Ràng buộc bảo mật (Security & Privacy):**
   - Tuyệt đối không commit bí mật, API key, JWT secret, database credentials hoặc thông tin định danh cá nhân (PII) của khách hàng.
   - Mật khẩu chỉ lưu dưới dạng hash `bcrypt`; token xác thực gắn thời hạn hợp lệ.
2. **Ràng buộc toàn vẹn dữ liệu (Data Integrity & Concurrency):**
   - Sử dụng khóa lạc quan (`version`) cho các thực thể quan trọng (`Room`, `HousekeepingTask`, `MaintenanceTask`). Trả mã lỗi `409 CONFLICT` khi phát hiện phiên bản cũ.
   - Phát sự kiện Socket.IO chỉ sau khi database transaction đã commit thành công.
3. **Ràng buộc trải nghiệm người dùng (UX & Accessibility):**
   - Ứng dụng Android tối ưu cho thao tác một tay tại hiện trường: touch target >= 48x48dp, quy trình thao tác không quá 3 chạm.
   - Ứng dụng Web hỗ trợ đầy đủ điều hướng phím và khả năng phóng to chữ 200% mà không bị vỡ bố cục.

---

## 4. Đối chiếu Nguồn Baseline và Liên kết trong Repository

- Tôn chỉ dự án: [`docs/project-charter.md`](../../project-charter.md)
- Đặc tả sản phẩm MVP: [`docs/_product/prd.md`](../../_product/prd.md)
- Thiết kế cơ sở dữ liệu: [`docs/_shared/database-design.md`](../../_shared/database-design.md)
- Kế hoạch nghiệm thu: [`docs/qa/acceptance.md`](../../qa/acceptance.md)

---

## 5. Tiêu chí Nghiệm thu và Trạng thái Hoàn thành

- [x] Đã hoàn thành artefact **Migration maintenance** đáp ứng đầy đủ yêu cầu của gói `S2-BAO-003`.
- [x] Đã gắn liên kết bằng chứng vào Issue Refs #147.
- [ ] Chờ Reviewer (`Đạt`) nghiệm thu và phê duyệt chính thức để đóng Issue.
