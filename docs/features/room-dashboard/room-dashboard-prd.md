---
type: prd
feature: room-dashboard
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/room-dashboard/room-dashboard-brd.md|Room Dashboard BRD]]"
  - "[[docs/features/room-dashboard/room-dashboard-urd.md|Room Dashboard URD]]"
---

# room-dashboard — Product Requirements Document (Feature)

## 1. Overview

Một màn hình giám sát realtime trên web cho quản lý (và tham khảo cho lễ tân): lưới 50 phòng hiển thị riêng 3 trục trạng thái (lưu trú / vệ sinh / bảo trì), chỉ số tổng hợp tại thời điểm xem — đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy — cùng tô cờ việc quá hạn bằng quy tắc để quản lý can thiệp ngay trong ca. Dashboard chỉ đọc: trạng thái do các feature nghiệp vụ sở hữu và lan lên qua `realtime-sync`.

### Product Gap

- AS-IS: trạng thái 3 trục nằm rải ở từng vai trò, quản lý phải hỏi từng người; việc quá hạn tự phát hiện muộn; lễ tân không chắc phòng nào thật sự sẵn sàng.
- TO-BE: một màn hình tổng realtime — mọi thay đổi lan lên ≤3 giây, việc trễ tự tô cờ, chỉ số đối soát được với dữ liệu nguồn.

## 2. Goals & Non-Goals

### Goals

- G1: 100% phòng hiển thị đúng và riêng 3 trục trạng thái tại thời điểm xem — không trộn trục.
- G2: 6 chỉ số tổng hợp (đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / tỷ lệ lấp đầy) luôn khớp dữ liệu đối soát.
- G3: Công việc quá hạn tự lộ diện bằng quy tắc — không phụ thuộc AI.
- G4: Mọi cập nhật trạng thái lan lên dashboard ≤3 giây; mất kết nối được báo rõ thay vì im lặng.

### Non-Goals

- Không thao tác ghi/đổi trạng thái từ dashboard (nhận/trả, xác nhận dọn, nhận việc sửa) — thuộc feature nghiệp vụ sở hữu.
- Không sở hữu quy tắc đánh cờ quá hạn theo loại việc — `housekeeping`/`maintenance` sở hữu; dashboard chỉ hiển thị.
- Không dự báo, không báo cáo doanh thu, không xem lịch sử từ dashboard (PRD: chưa làm).
- Không tóm tắt AI (`ai-ops-summary`); không truy vết nhật ký (`audit-log`); không xây kênh realtime (`realtime-sync` là dependency).
- Không hiển thị dữ liệu định danh khách; khách không phải người dùng.

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Quản lý | Web dashboard, xem liên tục trong ca | Mở dashboard xem tổng quan; lọc theo tầng/trạng thái; theo dõi cập nhật realtime; nhận diện + xử lý việc quá hạn (can thiệp qua feature sở hữu); biết khi dữ liệu lỗi thời |
| Lễ tân | Web tại quầy lễ tân | Tham khảo dashboard (read-only): xem/lọc phòng "sẵn sàng" trước khi nhận khách |
| Nhân viên buồng phòng–bảo trì | Mobile Android | Không dùng dashboard — là nguồn dữ liệu qua feature nghiệp vụ |

Ref: `[[docs/features/room-dashboard/room-dashboard-urd.md]]` mục User Types + Journeys.

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-room-dashboard-01 | Lưới 50 phòng realtime hiển thị riêng 3 trục trạng thái | P0 | Cốt lõi giám sát; ràng buộc tôn chỉ "3 trục riêng" | ~4 story | UN-001 → BO-room-dashboard-01 |
| CAP-room-dashboard-02 | Chỉ số tổng hợp tại thời điểm xem (6 chỉ số, gồm tỷ lệ lấp đầy + xử lý mẫu = 0) | P0 | Cam kết tôn chỉ; nguồn số liệu cho `ai-ops-summary` | ~3 | UN-001, UN-003 → BO-01, BO-03 |
| CAP-room-dashboard-03 | Tô cờ + đếm công việc quá hạn theo quy tắc | P0 | Cam kết tôn chỉ; giá trị "can thiệp trong ca" | ~3 | UN-002 → BO-02 |
| CAP-room-dashboard-04 | Lọc lưới theo tầng và nhóm trạng thái | P0 | Khoanh vùng trên 50 phòng nhiều tầng | ~2 | UN-005 → BO-01 |
| CAP-room-dashboard-05 | Chỉ báo sức khỏe dữ liệu (banner offline, đánh dấu lỗi thời, tự tải lại khi có mạng) | P0 | Tránh tin nhầm dữ liệu cũ; kịch bản "khôi phục kết nối" | ~2 | UN-006 → BO-03 |
| CAP-room-dashboard-06 | Phân quyền xem theo vai trò (quản lý + lễ tân), dashboard chỉ đọc | P0 | Kiểm quyền máy chủ theo tôn chỉ | ~2 | BR-room-dashboard-06 → BO-03 |
| CAP-room-dashboard-07 | Điều hướng từ ô phòng/cảnh báo quá hạn sang màn nghiệp vụ sở hữu | P1 | Rút ngắn đường can thiệp, không bắt buộc để demo MVP | ~2 | UN-002 → BO-02 |
| CAP-room-dashboard-08 | Chi tiết một phòng (đủ 3 trục + công việc đang mở) | P1 | Phục vụ can thiệp sâu; phụ thuộc OQ-4 | ~3 | UN-001, UN-002 → BO-01 |
| CAP-room-dashboard-09 | Dashboard trên Android cho quản lý/lễ tân | P2 | Hậu MVP; PRD chỉ cam kết web cho v1 | ~3 | UN-001 → BO-01 |

### Done when (product level)

- CAP-01: Mở dashboard hiển thị đủ 50 phòng, mỗi phòng đủ 3 trục riêng khớp trạng thái nguồn; thay đổi ở bất kỳ trục nào cập nhật lên ô phòng ≤3 giây.
- CAP-02: 6 chỉ số hiển thị đúng tại thời điểm xem; tỷ lệ lấp đầy = đang ở ÷ có thể phục vụ × 100%; mẫu = 0 → "không áp dụng"; 100% khớp đối soát.
- CAP-03: 100% công việc có cờ quá hạn (do feature nguồn đánh) được tô cờ trên ô phòng và đếm vào chỉ số; cờ tự mất khi việc hoàn tất; không dùng AI.
- CAP-04: Lọc theo tầng và nhóm trạng thái trả đúng tập phòng; lọc ra 0 phòng hiển thị trạng thái rỗng rõ ràng.
- CAP-05: Mất kết nối → banner rõ + dữ liệu đánh dấu lỗi thời; kết nối lại → tự tải trạng thái mới nhất, không ghép dữ liệu cũ.
- CAP-06: Chỉ quản lý và lễ tân vào được dashboard; vai trò khác bị từ chối phía máy chủ; không có thao tác ghi nào trên màn hình.
- CAP-07: Từ cảnh báo quá hạn/ô phòng mở được màn xử lý tương ứng của `housekeeping`/`maintenance`.
- CAP-08: Chạm ô phòng hiển thị đủ 3 trục + công việc đang mở của phòng đó (chờ OQ-4).
- CAP-09: Mở được dashboard trong app Android sau MVP.

## 5. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Chỉ số dashboard khớp dữ liệu đối soát | Chưa có | 100% | Đối soát chỉ số với dữ liệu nguồn trong nghiệm thu | Nghiệm thu (02/11/2026) |
| Độ trễ cập nhật realtime lên dashboard | Chưa có | ≥95% trong 100 lượt ≤3 giây | Đo theo tiêu chí tôn chỉ (50 phòng, ~10 phiên đồng thời) | Nghiệm thu |
| Việc quá hạn được lộ diện | Chưa có — tự phát hiện muộn | 100% việc có cờ quá hạn được tô cờ + đếm | Kịch bản nghiệm thu "dashboard + cảnh báo quá hạn" | Sprint 3 |
| Phòng hiển thị "sẵn sàng" sai | Chưa có | 0 phòng "sẵn sàng" khi chưa đủ trống + sạch + phục vụ | Đối chiếu trạng thái nguồn trong test | Nghiệm thu |

## 6. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Trục vệ sinh + cờ quá hạn việc dọn (ngưỡng 60') | Feature `housekeeping` | Đã chi tiết hóa (spec có sẵn) | CAP-01, CAP-02, CAP-03 |
| Trục bảo trì + cờ quá hạn việc sửa (ngưỡng OQ-1) | Feature `maintenance` | Chưa chi tiết hóa — song song | CAP-01, CAP-02, CAP-03 |
| Kênh realtime ≤3 giây + xử lý xung đột/offline phía nguồn | Feature `realtime-sync` | Chưa chi tiết hóa — song song | CAP-01, CAP-05 |
| Danh mục 50 phòng + dữ liệu tầng | Feature `room-catalog` | Chưa chi tiết hóa | CAP-01, CAP-04 |
| Trục lưu trú (trống / đang ở) | Feature `check-in-out` | Chưa chi tiết hóa — Sprint 2 | CAP-01, CAP-02 |
| Vai trò quản lý/lễ tân + kiểm quyền máy chủ | Feature `auth-roles` | Đã chi tiết hóa | CAP-06 |

## 7. Assumptions

- Các feature vận hành sinh và sở hữu trạng thái 3 trục; dashboard chỉ đọc.
- Cờ "quá hạn" do feature nghiệp vụ sở hữu đánh — dashboard hiển thị và đếm, không tự tính ngưỡng.
- Mẫu số tỷ lệ lấp đầy = phòng không "ngừng phục vụ" — giả định từ công thức tôn chỉ.
- Chỉ số "phòng cần dọn" chỉ đếm trục vệ sinh `can_don`; `dang_don` và `cho_kiem_tra` hiển thị riêng trên lưới.
- Dashboard v1 chỉ trên Web; Android là hậu MVP.

## 8. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| Chỉ số lệch dữ liệu thật → quản lý điều phối sai | Low | Mất niềm tin vào sản phẩm | Đối soát nghiệm thu 100%; chỉ báo offline/lỗi rõ; không che lỗi | PM |
| Upstream chậm (maintenance/realtime-sync) → dashboard thiếu dữ liệu | Medium | Demo hổng, chỉ số khuyết | Thứ tự sprint đặt dashboard sau vận hành; dữ liệu giả lập đủ 3 trục để phát triển song song | PM/Trưởng nhóm |
| Scope creep thao tác trực tiếp trên dashboard | Medium | Trễ Sprint 3 | Giữ chỉ-đọc; can thiệp qua feature sở hữu (CAP-07 điều hướng) | PM |
| Ngưỡng quá hạn bảo trì chưa chốt (OQ-1) | Medium | Chỉ số quá hạn thiếu việc sửa | Cờ do nguồn đánh — tự đầy đủ khi `maintenance` chốt | PM |

## 9. Release Plan

### Now (Sprint 3 — dashboard + cảnh báo quá hạn, khung tới 19/10)

- CAP-room-dashboard-01, 02, 03, 04, 05, 06 — lưới realtime + chỉ số + cờ quá hạn + lọc + chỉ báo kết nối + phân quyền.

### Next (cuối Sprint 3 / Sprint 4 — hoàn thiện + nghiệm thu)

- CAP-room-dashboard-07 — điều hướng sang màn nghiệp vụ sở hữu.
- CAP-room-dashboard-08 — chi tiết phòng (nếu OQ-4 chốt có).

### Later (sau MVP)

- CAP-room-dashboard-09 — dashboard trên Android; lọc chi tiết theo từng trạng thái trục.

## 10. Launch Readiness

- Guardrail: chỉ số dashboard khớp đối soát = 100%; không có phòng "sẵn sàng" khi chưa đủ điều kiện; không có thao tác ghi nào trên dashboard.
- Demo script: mở dashboard → thay đổi trạng thái ở vai trò khác lan lên ≤3 giây → việc quá hạn được tô cờ → lọc theo tầng/trạng thái → mất mạng có banner → có lại mạng tự cập nhật.
- Rollback: feature chỉ-đọc, không ghi dữ liệu — tắt màn hình không ảnh hưởng dữ liệu nguồn.

## 11. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" cho công việc bảo trì là bao nhiêu (việc dọn đã chốt 60 phút ở `housekeeping`)? Chỉ số "việc quá hạn" của dashboard chỉ đầy đủ khi ngưỡng này được chốt — quyết cùng feature `maintenance`.
- [ ] OQ-4: Chạm vào một ô phòng có mở màn chi tiết phòng (đủ 3 trục + công việc đang mở + liên kết sang màn xử lý của housekeeping/maintenance) không, hay lưới tổng quan đã đủ cho v1?
