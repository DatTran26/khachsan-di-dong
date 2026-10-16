---
type: prd
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/maintenance/maintenance-brd.md|Maintenance BRD]]"
  - "[[docs/features/maintenance/maintenance-urd.md|Maintenance URD]]"
---

# maintenance — Product Requirements Document (Feature)

## 1. Overview

Số hóa chu trình báo hỏng và bảo trì: mọi vai trò báo hỏng trực tiếp kèm phòng + mô tả, phòng tự "ngừng phục vụ" trên trục bảo trì riêng, nhân viên bảo trì tự nhận việc và báo xong trên mobile, phòng tự mở lại khi hết việc — đồng bộ realtime và ghi nhật ký đầy đủ.

### Product Gap

- AS-IS: báo hỏng qua miệng/điện thoại nhiều trung gian, phòng đang sửa vẫn có thể bị nhận khách nhầm, không truy vết được tiến độ.
- TO-BE: một chu trình khép kín — báo hỏng tự chặn phòng, việc có chủ và trạng thái rõ, phòng tự mở lại khi xong.

## 2. Goals & Non-Goals

### Goals

- G1: 100% báo hỏng hợp lệ tạo việc và tự chuyển phòng sang "ngừng phục vụ" — không còn bước trung gian.
- G2: 0 lượt nhận khách vào phòng đang ngừng phục vụ (điều kiện tôn chỉ).
- G3: Mọi việc bảo trì có trạng thái xử lý rõ ràng tới khi đóng và truy vết được qua nhật ký.
- G4: Mọi thay đổi trạng thái đồng bộ realtime ≤3 giây trên mọi thiết bị.

### Non-Goals

- Không kho vật tư, chi phí sửa chữa, lịch bảo trì định kỳ, mức độ ưu tiên hỏng (PRD "chưa làm").
- Không xác nhận chất lượng sau sửa (PRD chốt: sửa xong → phòng mở lại).
- Không xử lý nhận/trả phòng (feature `check-in-out` — chỉ tiêu thụ trạng thái "ngừng phục vụ").
- Không làm báo cáo lịch sử chuyên sâu (feature `audit-log`) hay dashboard tổng hợp (`room-dashboard`).
- Không chấm công/KPI nhân viên bảo trì; không báo hỏng từ phía khách.

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Nhân viên bảo trì *(vai trò gộp buồng phòng–bảo trì)* | Mobile, tại hiện trường | Xem danh sách việc chờ nhận/đang sửa; nhận việc; báo xong; xem việc quá hạn |
| Mọi vai trò (người báo hỏng) | Web/mobile | Báo hỏng kèm phòng + mô tả (+ vị trí); theo dõi trạng thái báo hỏng; hủy báo nhầm khi chưa nhận |
| Quản lý | Web dashboard | Xem việc đang mở/quá hạn; chỉ định lại việc (P1); đặt/gỡ ngừng phục vụ tay; hủy việc |
| Lễ tân | Web tại quầy | Báo hỏng; đặt/gỡ ngừng phục vụ tay; bị chặn khi nhận phòng ngừng (qua `check-in-out`) |

Ref: `[[docs/features/maintenance/maintenance-urd.md]]` mục User Types + Journeys.

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-maintenance-01 | Báo hỏng kèm phòng + mô tả từ mọi vai trò | P0 | Điểm vào của chu trình; bỏ trung gian truyền miệng | ~4 story | UN-001 → BO-maintenance-02 |
| CAP-maintenance-02 | Tự "ngừng phục vụ" khi có việc mở + chặn nhận khách | P0 | Ràng buộc an toàn lõi (tôn chỉ); đo thành công chính | ~4 | UN-004, UN-005 → BO-01 |
| CAP-maintenance-03 | Nhân viên bảo trì nhận/báo xong trên mobile | P0 | Điểm chạm chính của người xử lý | ~4 | UN-002, UN-003 → BO-02 |
| CAP-maintenance-04 | Tự mở lại phục vụ khi hết việc mở | P0 | Khép kín chu trình, không phụ thuộc ai nhớ | ~3 | UN-004 → BO-01, BO-02 |
| CAP-maintenance-05 | Trạng thái bảo trì + việc realtime trên mọi thiết bị | P0 | Giá trị cốt lõi sản phẩm (một nguồn sự thật) | ~3 | UN-005 → BO-02 |
| CAP-maintenance-06 | Ghi nhật ký máy chủ mọi thay đổi | P0 | Truy vết ai báo/ai sửa/khi nào | ~2 | UN-007 → BO-03 |
| CAP-maintenance-07 | Đặt/gỡ "ngừng phục vụ" thủ công (lễ tân/quản lý, kèm lý do) | P1 | Ngừng vì lý do vận hành không qua báo hỏng | ~3 | UN-006 → BO-01 |
| CAP-maintenance-08 | Hủy báo hỏng nhầm (khi chưa nhận) + chỉ định/đổi người xử lý | P1 | Dọn nhiễu và điều phối dự phòng | ~4 | UN-007 → BO-02 |
| CAP-maintenance-09 | Cảnh báo việc quá hạn bằng quy tắc | P1 | Ngưỡng chưa chốt (OQ-1); dashboard tổng hợp cần | ~3 | UN-004 → BO-02 |
| CAP-maintenance-10 | Mức ưu tiên hỏng + ảnh hiện trường + lịch định kỳ | P2 | Ngoài phạm vi MVP theo PRD | ~6 | — |

### Done when (product level)

- CAP-01: Mọi vai trò gửi được báo hỏng với phòng + mô tả bắt buộc; báo hỏng hiện trong danh sách "chờ nhận" realtime.
- CAP-02: 100% phòng có việc bảo trì đang mở hiển thị "ngừng phục vụ" và bị `check-in-out` chặn nhận khách (kể cả khi trống + sạch).
- CAP-03: Nhân viên nhận việc/báo xong trong ≤3 chạm; chỉ thao tác được việc của mình; 2 người cùng nhận → người đầu giữ, người sau được báo.
- CAP-04: Khi việc cuối cùng của phòng đóng (hoàn tất/hủy) → phòng tự về "bình thường" và đủ điều kiện "sẵn sàng" nếu trống + sạch.
- CAP-05: ≥95% cập nhật trạng thái hiển thị trên thiết bị khác ≤3 giây.
- CAP-06: Mọi thay đổi trạng thái việc/phòng có bản ghi ai/khi/từ→sang trong nhật ký.
- CAP-07: Lễ tân/quản lý đặt ngừng tay kèm lý do bắt buộc; gỡ tay bị từ chối khi phòng còn việc mở.
- CAP-08: Hủy được việc "chờ nhận" (người báo/quản lý); quản lý chỉ định/đổi người xử lý việc đang mở.
- CAP-09: Việc vượt ngưỡng OQ-1 được cờ "quá hạn" và hiển thị trên dashboard.
- CAP-10: (sau MVP) báo hỏng có mức ưu tiên và ảnh đính kèm.

## 5. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Lượt nhận khách vào phòng ngừng phục vụ | Chưa có | 0 (100% bị chặn) | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |
| Báo hỏng có trạng thái xử lý rõ tới khi đóng | Chưa có | 100% | Đối soát danh sách việc + nhật ký | Sprint 2 |
| Thời gian trung bình báo hỏng → mở lại phục vụ | Chưa có — xác lập qua demo | Đo được từ mốc log | Đối soát nhật ký | Sprint 2–3 |
| Độ trễ đồng bộ realtime | Chưa có | ≥95% lượt ≤3 giây | Đo 100 lượt theo tiêu chí nghiệm thu | Nghiệm thu |

## 6. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Danh mục phòng 50 phòng | `room-catalog` (team, sprint 1) | Đã lên kế hoạch | CAP-01 |
| Vai trò + kiểm quyền phía server | `auth-roles` (team, sprint 1) | Đã chi tiết | CAP-03, CAP-07, CAP-08 |
| `check-in-out` tôn trọng "ngừng phục vụ" | Team backend (feature khác, song song sprint 2) | Chưa chi tiết | CAP-02 |
| Cơ chế realtime + nhật ký | `realtime-sync`, `audit-log` (song song sprint 1–2) | Đang pipeline | CAP-05, CAP-06 |
| Dashboard hiển thị ngừng/quá hạn | `room-dashboard` (sprint 3) | Chưa chi tiết | CAP-09 |

## 7. Assumptions

- Việc bảo trì vào danh sách chung, nhân viên tự nhận; chỉ định từ đầu không thuộc MVP (CAP-08 giữ P1).
- Báo xong → phòng mở lại ngay, không bước xác nhận (PRD chốt).
- "Ngừng phục vụ" 2 nguồn độc lập: việc mở (tự gỡ) và đặt tay (gỡ tay).
- Thông báo qua realtime trong app, không SMS/push ngoài.

## 8. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| Nhân viên không mở app → không thấy việc | Medium | Việc treo, phòng ngừng kéo dài | Cảnh báo quá hạn (CAP-09) + dashboard quản lý | PM/Quản lý |
| Mở lại phòng không qua kiểm tra | Medium | Phòng chưa xong đã bán lại | PRD chấp nhận; nhật ký truy vết người báo xong; đánh giá sau pilot | PM |
| Báo hỏng trùng/spam | Medium | Danh sách việc nhiễu | Cảnh báo "đang có việc mở" + hủy khi chưa nhận (CAP-08) | PM |

## 9. Release Plan

### Now (Sprint 2 — khung 22/09–05/10)

- CAP-maintenance-01 → 06 — chu trình lõi báo hỏng → ngừng → sửa → mở lại + realtime + nhật ký.

### Next (Sprint 3)

- CAP-maintenance-07, 08, 09 — đặt/gỡ tay, hủy/chỉ định, cảnh báo quá hạn (cùng dashboard).

### Later (sau MVP)

- CAP-maintenance-10 — mức ưu tiên, ảnh hiện trường, lịch định kỳ, kho vật tư/chi phí.

## 10. Launch Readiness

- Guardrail: 0 lượt nhận khách vào phòng "ngừng phục vụ"; 100% báo hỏng có trạng thái rõ tới khi đóng.
- Demo script: báo hỏng từ mobile → phòng ngừng trên web quầy → chặn check-in → nhận việc → báo xong → phòng mở lại → nhận khách lại; chạy thông suốt Web + Android.
- Rollback: feature độc lập; nếu lỗi quay về quy trình báo miệng, dữ liệu log vẫn giữ.

## 11. Open Questions

- [ ] OQ-1: Ngưỡng "quá hạn" việc bảo trì + tần suất cảnh báo (1 lần hay lặp)? → **Chốt 10/10/2026: ngưỡng 4 giờ** từ lúc báo hỏng. Tần suất cảnh báo chưa chốt (hiện cảnh báo 1 lần).
