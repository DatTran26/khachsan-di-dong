---
type: prd
feature: housekeeping
status: draft
updated: 2026-09-15
links:
  - "[[docs/features/housekeeping/housekeeping-brd.md|Housekeeping BRD]]"
  - "[[docs/features/housekeeping/housekeeping-urd.md|Housekeeping URD]]"
---

# housekeeping — Product Requirements Document (Feature)

## 1. Overview

Số hóa chu trình dọn phòng từ lúc trả phòng đến lúc phòng "sẵn sàng" bán lại: hệ thống tự tạo và tự giao việc, nhân viên thao tác trên mobile, quản lý xác nhận chất lượng, trạng thái realtime, cảnh báo quá hạn bằng quy tắc.

### Product Gap

- AS-IS: phân công và báo cáo qua điện thoại/giấy, không trạng thái thống nhất, không bằng chứng truy vết.
- TO-BE: một chu trình khép kín có chủ sở hữu rõ ràng ở từng bước, mọi thiết bị thấy cùng trạng thái.

## 2. Goals & Non-Goals

### Goals

- G1: 100% việc dọn được tạo và phân công tự động (hoặc cảnh báo thiếu người trực) — không còn phân công thủ công.
- G2: Kiểm soát chất lượng qua bước xác nhận của quản lý trước khi phòng mở bán lại.
- G3: Việc quá hạn 60 phút được cảnh báo deterministic — không phụ thuộc AI.
- G4: Mọi thay đổi trạng thái đồng bộ realtime ≤3 giây trên mọi thiết bị.

### Non-Goals

- Không tối ưu tuyến đi, không phân công theo vị trí tầng/loại phòng (ngoài heuristic "chia đều").
- Không chấm công, phân ca, tính lương/KPI (feature quản lý tài khoản).
- Không AI quyết định hay tự đổi trạng thái (AI chỉ tóm tắt — feature riêng).
- Không xử lý nhận/trả phòng (feature nhận/trả phòng là nguồn sự kiện).
- Không làm báo cáo lịch sử chuyên sâu (feature audit-log).

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Nhân viên buồng phòng | Mobile, di chuyển giữa các phòng | Nhận thông báo việc mới; nhận/từ chối việc; báo hoàn tất; xem danh sách việc của mình và việc quá hạn |
| Quản lý | Web dashboard | Nhận thông báo chờ xác nhận; xác nhận/trả lại việc; xem cảnh báo quá hạn; phân công lại thủ công |
| Lễ tân | Web tại quầy | Xem phòng nào "sẵn sàng" để nhận khách (read-only trong feature này) |

Ref: `[[docs/features/housekeeping/housekeeping-urd.md]]` mục User Types + Journeys.

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-housekeeping-01 | Tự tạo & tự giao việc dọn khi trả phòng | P0 | Nền tảng của toàn chu trình; bỏ phân công thủ công | bóc ~6 story | UN-001 → BO-housekeeping-01 |
| CAP-housekeeping-02 | Nhân viên nhận/từ chối/báo hoàn tất trên mobile | P0 | Điểm chạm chính của người làm việc | ~5 | UN-002, UN-003 → BO-01 |
| CAP-housekeeping-03 | Quản lý xác nhận/trả lại "sẵn sàng" | P0 | Cổng kiểm soát chất lượng bắt buộc | ~4 | UN-004 → BO-02 |
| CAP-housekeeping-04 | Trạng thái vệ sinh + việc realtime trên mọi thiết bị | P0 | Giá trị cốt lõi của sản phẩm | ~4 | UN-006 → BO-01 |
| CAP-housekeeping-05 | Cảnh báo quá hạn 60 phút bằng quy tắc | P0 | Cam kết tôn chỉ; an toàn vận hành | ~3 | UN-005 → BO-01 |
| CAP-housekeeping-06 | Phân công lại thủ công + xử lý từ chối | P1 | Phương án dự phòng khi auto-assign lệch thực tế | ~4 | UN-001, UN-003 → BO-01 |
| CAP-housekeeping-07 | Lọc danh sách việc (nhân viên/trạng thái/phòng) | P1 | Giúp quản lý và nhân viên định vị nhanh | ~3 | UN-003, UN-005 → BO-01 |
| CAP-housekeeping-08 | Thống kê hiệu suất dọn (TB thời gian, việc/người, tỷ lệ trả lại) | P2 | Cải tiến vận hành sau MVP | ~5 | UN-005 → BO-01 |

### Done when (product level)

- CAP-01: Mỗi sự kiện trả phòng sinh đúng 1 việc dọn, được giao cho nhân viên trực ít việc mở nhất theo giờ trả, hoặc cảnh báo "chờ giao" khi không có ai trực — trong ≤1 phút.
- CAP-02: Nhân viên hoàn tất thao tác nhận/báo xong trong ≤3 chạm; chỉ thao tác được việc của mình; từ chối thì việc tự giao lại.
- CAP-03: Phòng chỉ chuyển "sạch"/"sẵn sàng" sau xác nhận quản lý; trả lại bắt buộc ghi chú ≤500 ký tự; vòng lặp trả lại hoạt động đúng.
- CAP-04: ≥95% cập nhật trạng thái hiển thị trên thiết bị khác ≤3 giây.
- CAP-05: 100% việc vượt 60 phút chưa hoàn tất được cờ "quá hạn" và cảnh báo, không dùng AI.
- CAP-06: Quản lý giao lại được việc đang mở; lịch sử đổi người ghi đủ.
- CAP-07: Lọc theo nhân viên/trạng thái/phòng trả kết quả đúng.
- CAP-08: Dashboard hiển thị thời gian dọn trung bình và số việc mỗi nhân viên từ dữ liệu thật.

## 5. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Tỷ lệ trả phòng có việc được giao ≤1 phút | Chưa có | 100% | Đối soát nhật ký trong kịch bản nghiệm thu | Sprint 2 |
| Thời gian trung bình trả phòng → sẵn sàng | Chưa có — xác lập qua demo | Đo được và hiển thị trên dashboard | Tính từ mốc log | Sprint 2–3 |
| Độ trễ đồng bộ realtime | Chưa có | ≥95% lượt ≤3 giây | Đo 100 lượt theo tiêu chí nghiệm thu | Nghiệm thu |
| Sự cố phòng bán nhầm khi chưa sạch | Chưa có | 0 | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |

## 6. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Sự kiện "trả phòng" từ feature nhận/trả phòng | Team backend (feature khác) | Song song sprint 2 | CAP-01 |
| Vai trò + danh sách nhân viên buồng phòng đang trực | Feature quản lý tài khoản | Sprint 1 (đã lên kế hoạch) | CAP-01, CAP-06 |
| Kênh realtime Socket.IO + màn dashboard | Feature dashboard | Song song sprint 2–3 | CAP-04, CAP-05 |
| Nhật ký thay đổi trạng thái | Feature audit-log (cùng nhóm) | Song song sprint 2 | CAP-01–05 (truy vết) |

## 7. Assumptions

- Nguồn "nhân viên đang trực" tồn tại trong hệ thống — OQ-1.
- Thông báo việc mới/cảnh báo đi qua kênh realtime trong app, không SMS/push ngoài.
- Ngưỡng 60 phút áp đồng nhất mọi phòng.
- Việc "chờ xác nhận" không tính ngưỡng quá hạn (đo tới lúc nhân viên báo hoàn tất) — OQ-3.

## 8. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| Nhân viên không mở app → không thấy việc | Medium | Việc treo | Cảnh báo quá hạn lên dashboard quản lý; demo kèm hướng dẫn quy trình | PM/Quản lý |
| Xác nhận quản lý thành nút thắt | Medium | Phòng sạch chờ bán | Danh sách chờ kiểm tra nổi bật; OQ-3 cân nhắc ngưỡng nhắc | PM |
| Chia đều đơn giản lệch thực tế | Medium | Cảnh báo nhiễu, nhân viên chạy xa | MVP chấp nhận; CAP-08 đo để điều chỉnh | PM |

## 9. Release Plan

### Now (Sprint 2 — khung 22/09–05/10)

- CAP-housekeeping-01, 02, 03, 04, 05 — chu trình lõi + cảnh báo + realtime.

### Next (Sprint 3)

- CAP-housekeeping-06, 07 — phân công lại, lọc danh sách (hỗ trợ dashboard).

### Later (sau MVP)

- CAP-housekeeping-08 — thống kê hiệu suất; ngưỡng quá hạn theo loại phòng.

## 10. Launch Readiness

- Guardrail: tỷ lệ trả phòng có việc được giao = 100%; không có phòng "sẵn sàng" khi chưa xác nhận.
- Demo script: luồng trả phòng → dọn → xác nhận → sẵn sàng → nhận khách lại phải chạy thông suốt trên Web + Android.
- Rollback: feature độc lập; nếu lỗi có thể quay về quy trình thủ công, dữ liệu log vẫn giữ.

## 11. Open Questions

- [ ] OQ-1: Nguồn danh sách "nhân viên buồng phòng đang trực" trong MVP?
- [ ] OQ-2: Cảnh báo quá hạn phát 1 lần hay lặp lại định kỳ tới khi hoàn tất?
- [ ] OQ-3: Việc "chờ xác nhận" quá lâu có cần ngưỡng nhắc riêng cho quản lý?
