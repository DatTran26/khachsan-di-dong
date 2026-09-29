---
type: srs-spec
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/maintenance/maintenance-prd.md|Maintenance PRD]]"
  - "[[docs/features/maintenance/maintenance-brd.md|Maintenance BRD]]"
---

# maintenance — System Requirements Specification (Tier 1)

## 1. Scope

### In Scope

- Báo hỏng kèm phòng + mô tả (bắt buộc) + vị trí/hạng mục (tùy chọn) từ mọi vai trò đã đăng nhập. Với phòng đang ở, báo hỏng vẫn chặn nhận khách mới; quản lý điều phối việc vào phòng với khách ngoài phạm vi app.
- Tự động chuyển phòng sang "ngừng phục vụ" trên trục bảo trì khi có việc mở; tự mở lại khi hết việc mở.
- Danh sách việc bảo trì; nhân viên bảo trì tự nhận, báo xong; người báo/quản lý hủy việc "chờ nhận".
- Đặt/gỡ "ngừng phục vụ" thủ công (lễ tân/quản lý); cảnh báo quá hạn bằng quy tắc (ngưỡng OQ-1).
- Đồng bộ realtime + ghi nhật ký máy chủ mọi thay đổi.

### Out of Scope

- Kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ, mức độ ưu tiên hỏng.
- Xác nhận chất lượng sau sửa (mở lại trực tiếp theo PRD).
- Nhận/trả phòng (`check-in-out`), dashboard tổng hợp (`room-dashboard`), lịch sử chi tiết (`audit-log`).

## 2. Actors & Stakeholders

| Actor | Type | Responsibility |
|-------|------|----------------|
| Mọi vai trò (người báo hỏng) | primary | Báo hỏng; hủy báo hỏng của mình khi chưa nhận |
| Nhân viên bảo trì *(vai trò gộp buồng phòng–bảo trì)* | primary | Nhận việc, báo xong |
| Lễ tân | secondary | Báo hỏng; đặt/gỡ "ngừng phục vụ" tay |
| Quản lý | secondary | Giám sát việc mở/quá hạn; đặt/gỡ ngừng tay; hủy việc; chỉ định lại (P1) |
| Hệ thống | system | Tự đổi trục bảo trì, chặn nhận khách, phát cập nhật, ghi nhật ký |

## 3. Functional Requirements

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-maintenance-001 | Cho mọi vai trò đã đăng nhập tạo báo hỏng với phòng (bắt buộc, thuộc `room-catalog`) + mô tả (bắt buộc, ≤500 ký tự) + vị trí/hạng mục (tùy chọn, ≤100 ký tự); báo hỏng hợp lệ tạo việc ở "chờ nhận" | Mọi vai trò | Must |
| FR-maintenance-002 | Khi phòng có ≥1 việc bảo trì đang mở → trục bảo trì của phòng là "ngừng phục vụ"; phòng này bị `check-in-out` chặn nhận khách | Hệ thống | Must |
| FR-maintenance-003 | Khi phòng không còn việc bảo trì đang mở (mọi việc "hoàn tất"/"đã hủy") và không có cờ ngừng tay → trục bảo trì tự về "bình thường" | Hệ thống | Must |
| FR-maintenance-004 | Hiển thị danh sách việc bảo trì kèm phòng, mô tả, vị trí, trạng thái, người xử lý; nhân viên bảo trì nhận việc "chờ nhận" → "đang sửa" (gán người xử lý) | Nhân viên bảo trì | Must |
| FR-maintenance-005 | Nhân viên bảo trì báo hoàn tất việc do chính mình "đang sửa" → "hoàn tất" (đóng) | Nhân viên bảo trì | Must |
| FR-maintenance-006 | Người báo hoặc quản lý hủy việc đang "chờ nhận" → "đã hủy" (lý do tùy chọn ≤200 ký tự); việc đã "đang sửa" chỉ quản lý xử lý | Người báo/Quản lý | Must |
| FR-maintenance-007 | Lễ tân/quản lý đặt "ngừng phục vụ" tay kèm lý do bắt buộc (≤200 ký tự); gỡ tay chỉ khi phòng không còn việc bảo trì đang mở | Lễ tân/Quản lý | Must |
| FR-maintenance-008 | Báo hỏng trên phòng đã có việc bảo trì đang mở vẫn được tạo, kèm cảnh báo nhẹ "đang có việc mở" | Hệ thống | Should |
| FR-maintenance-009 | Quản lý/lễ tân chỉ định hoặc đổi người xử lý cho việc đang mở | Quản lý/Lễ tân | Should (P1) |
| FR-maintenance-010 | Việc bảo trì vượt ngưỡng OQ-1 chưa "hoàn tất" → đánh cờ "quá hạn" + cảnh báo hiển thị cho quản lý và người phụ trách | Hệ thống | Should (P1) |
| FR-maintenance-011 | Mọi thay đổi trạng thái việc/phòng được ghi nhật ký ở máy chủ (ai/khi nào/từ→sang) và phát realtime tới các thiết bị đang mở | Hệ thống | Must |
| FR-maintenance-012 | Lọc danh sách việc theo trạng thái/phòng/người xử lý | Nhân viên bảo trì/Quản lý | Should (P1) |

## 4. Non-Functional Requirements

| Category | Requirement | Target |
|----------|-------------|--------|
| Performance | Cập nhật trạng thái việc/phòng hiển thị trên thiết bị khác | ≤3 giây (mục tiêu ≥95% lượt) |
| Usability | Nhận việc / báo xong trên mobile | ≤3 chạm, ≤10 giây mỗi thao tác |
| Security | Mọi thao tác kiểm quyền ở máy chủ theo vai trò; báo xong chỉ trên việc của mình | Bắt buộc |
| Auditability | Mọi thay đổi có bản ghi ai/khi nào/từ→sang | 100% sự kiện |
| Consistency | Kiểm tra phiên bản trước khi ghi; chống ghi đè khi 2 thiết bị sửa cùng việc/phòng | Bắt buộc (theo `realtime-sync`) |
| Availability | Mất mạng → báo trạng thái + khóa ghi; kết nối lại → tải trạng thái mới | Bắt buộc (theo `realtime-sync`) |

## 5. Business Rules (system enforced)

| ID | Rule | Enforcement |
|----|------|-------------|
| BR-maintenance-01 | Có việc bảo trì đang mở → phòng "ngừng phục vụ"; hết việc mở → "bình thường" (nếu không có cờ đặt tay) | Tự động tại máy chủ |
| BR-maintenance-02 | Chỉ nhận khách khi trống + sạch + không ngừng phục vụ | `check-in-out` kiểm server-side khi nhận phòng |
| BR-maintenance-03 | Chỉ vai trò buồng phòng–bảo trì nhận/báo xong; báo xong chỉ trên việc của mình | Kiểm quyền máy chủ |
| BR-maintenance-04 | Chỉ lễ tân/quản lý đặt/gỡ ngừng tay; đặt tay bắt buộc lý do | Kiểm quyền máy chủ |
| BR-maintenance-05 | Việc "hoàn tất"/"đã hủy" không mở lại | Kiểm soát chuyển trạng thái |
| BR-maintenance-06 | "Ngừng phục vụ" chặn nhận khách mới, không ảnh hưởng khách đang ở | Kiểm chỉ áp dụng lúc nhận phòng |
| BR-maintenance-07 | Cờ ngừng tay và cờ do việc mở độc lập — một nguồn gỡ không mở phòng nếu nguồn kia còn | Kiểm soát trạng thái phòng |

## 6. Error Matrix

| ID | Trigger | User Message | System Action |
|------|---------|--------------|---------------|
| E-maintenance-001 | Hai thiết bị cùng nhận 1 việc | "Công việc này đã có người khác nhận." | Từ chối thao tác sau + tải lại danh sách |
| E-maintenance-002 | Mất mạng khi ghi | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | Khóa ghi; cho thử lại sau khi kết nối lại |
| E-maintenance-003 | Báo hỏng thiếu mô tả | "Vui lòng nhập mô tả hỏng hóc." | Giữ form, không tạo việc |
| E-maintenance-004 | Thao tác sai trạng thái | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." | Từ chối + gợi ý tải lại |
| E-maintenance-005 | Gỡ ngừng tay khi còn việc mở | "Phòng còn việc bảo trì đang xử lý — hãy hoàn tất hoặc hủy việc trước." | Từ chối, giữ trạng thái |
| E-maintenance-006 | Sai quyền thao tác | "Bạn không có quyền thực hiện thao tác này." | Từ chối + ghi nhật ký |

## 7. Success Criteria (system level)

| ID | Criterion | Target |
|----|-----------|--------|
| SC-maintenance-01 | 100% phòng có việc bảo trì đang mở bị chặn nhận khách | Pass kịch bản nghiệm thu |
| SC-maintenance-02 | 100% phòng chỉ về "bình thường" khi hết việc mở (hoặc gỡ tay hợp lệ) | Pass kiểm thử chuyển trạng thái |
| SC-maintenance-03 | 100% thay đổi trạng thái có bản ghi nhật ký đầy đủ | Đối soát audit-log |
| SC-maintenance-04 | ≥95% cập nhật hiển thị trên thiết bị khác ≤3 giây | Đo theo tiêu chí nghiệm thu |

## 8. Data Entities (high-level)

| Entity | Key Attributes | Relationships |
|--------|----------------|---------------|
| Phòng | id, số phòng, trục lưu trú, trục vệ sinh, trục bảo trì, cờ ngừng tay | 1..n việc bảo trì |
| Việc bảo trì | id, phòng, mô tả, vị trí/hạng mục, trạng thái (chờ nhận/đang sửa/hoàn tất/đã hủy), người báo, người xử lý, cờ quá hạn, mốc thời gian, phiên bản | thuộc 1 phòng; gán 1 người xử lý |
| Ngừng phục vụ (đặt tay) | id, phòng, lý do, người đặt, trạng thái | thuộc 1 phòng |
| Người dùng | id, vai trò, trạng thái | báo việc, xử lý việc |
| Nhật ký | id, đối tượng, hành động, từ→sang, ai, khi nào | ghi theo mọi thay đổi |

## 9. Flows (summary — chi tiết ở Tầng 2)

| Flow | Trigger | Outcome |
|------|---------|---------|
| FL-01 Báo hỏng → sửa xong → mở lại | Báo hỏng hợp lệ | Phòng ngừng → việc có chủ → hoàn tất → phòng mở lại |
| FL-02 Nhận khách vào phòng ngừng | Lễ tân chọn phòng ngừng | Bị chặn với lý do rõ ràng |
| FL-03 Việc quá hạn | Vượt ngưỡng OQ-1 | Cờ quá hạn + cảnh báo quản lý |
| FL-04 Đặt/gỡ ngừng tay | Lễ tân/QL thao tác | Trạng thái đổi, chặn/mở nhận khách, ghi nhật ký |
| FL-05 Hủy báo nhầm | Người báo/QL hủy việc chờ nhận | Việc "đã hủy"; phòng mở lại nếu hết việc mở |

## 10. Screens (summary — chi tiết ở Tầng 4)

| Screen | Actor | Purpose |
|--------|-------|---------|
| Form báo hỏng | Mọi vai trò | Chọn phòng + nhập mô tả/vị trí, gửi nhanh |
| Danh sách việc bảo trì | NV bảo trì, QL | Xem/lọc việc chờ nhận/đang sửa/quá hạn |
| Chi tiết việc | NV bảo trì, QL | Nhận việc, báo xong, hủy, chỉ định |
| Đặt/gỡ ngừng phục vụ | Lễ tân, QL | Đặt tay kèm lý do; gỡ tay |
| Sơ đồ phòng (ô trạng thái) | Mọi vai trò | Hiển thị "ngừng phục vụ" trên trục bảo trì (qua `room-dashboard`/`check-in-out`) |

## 11. Constraints

- MVP 8 tuần, nhóm 3 người; 1 khách sạn 50 phòng; tiếng Việt; dữ liệu giả lập.
- Trục bảo trì tách biệt lưu trú/vệ sinh — không trộn trạng thái.
- Cảnh báo quá hạn bằng quy tắc, không AI.
- Stack theo tôn chỉ: Flutter Web + Android, Node.js/Express, PostgreSQL, Socket.IO (triển khai — chi tiết Tầng 2+).

## 12. Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| `room-catalog` | Feature (danh mục phòng) | Sprint 1 |
| `auth-roles` | Feature (vai trò, kiểm quyền) | Sprint 1, đã chi tiết |
| `check-in-out` | Feature (tiêu thụ "ngừng phục vụ" khi nhận khách) | Sprint 2 song song |
| `realtime-sync` | Feature (lan truyền sự kiện) | Đang pipeline |
| `audit-log` | Feature (nhận ghi nhật ký) | Nhóm vận hành |
| `room-dashboard` | Feature (hiển thị ngừng/quá hạn) | Sprint 3 |

## 13. Assumptions

- Việc bảo trì vào danh sách chung, nhân viên tự nhận (MVP) — chỉ định tay ở P1.
- Báo xong → phòng mở lại ngay, không bước xác nhận (PRD). Với phòng đang ở, ứng dụng không xử lý chuyển phòng hay xin ý kiến khách; quản lý chịu trách nhiệm điều phối thực tế trước khi nhân viên thao tác.
- Thông báo realtime trong app; không SMS/push.

## 14. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" việc bảo trì + tần suất cảnh báo?
