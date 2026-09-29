---
type: prd
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/ai-ops-summary/ai-ops-summary-brd.md|AI Ops Summary BRD]]"
  - "[[docs/features/ai-ops-summary/ai-ops-summary-urd.md|AI Ops Summary URD]]"
  - "[[docs/_product/prd.md|Product PRD — mục 7.9]]"
---

# ai-ops-summary — Product Requirements Document (Feature)

## 1. Overview

Cho quản lý một nút "Tạo tóm tắt" cuối ca/ngày: hệ thống tính số liệu tổng hợp không định danh từ dashboard + nhật ký, nhờ dịch vụ LLM bên ngoài diễn giải thành bản tóm tắt có cấu trúc (tổng quan + điểm nổi bật + việc cần chú ý), kiểm tra đầu ra khớp dữ liệu gốc, hiển thị kèm thời điểm dữ liệu và nhãn "tham khảo". AI lỗi/hết hạn mức → báo cáo mẫu từ dữ liệu gốc.

### Product Gap

- AS-IS: quản lý tự mở nhiều màn và tự cộng dồn để bàn giao ca — chậm, sót việc trễ, không có bản tin chốt theo thời điểm.
- TO-BE: một bản tóm tắt đã kiểm chứng trong 1 thao tác, luôn rõ nguồn/thời điểm, và luôn có báo cáo mẫu khi AI không khả dụng.

## 2. Goals & Non-Goals

### Goals

- G1: Quản lý tạo được bản tóm tắt vận hành theo ca/ngày theo yêu cầu — đúng số liệu, không bịa sự kiện, nêu đúng việc cần chú ý.
- G2: Dữ liệu ra khỏi hệ thống chỉ là số liệu tổng hợp không định danh khách; AI không bao giờ ghi/sửa dữ liệu nghiệp vụ.
- G3: Chi phí AI bị chặn bởi hạn mức ở máy chủ — không vượt ngân sách 300.000 VNĐ.
- G4: 100% ca AI lỗi/hết hạn mức/kỳ rỗng vẫn có báo cáo mẫu đủ số liệu cốt lõi.

### Non-Goals

- Không tự động tạo theo lịch cuối ca (hướng sau MVP).
- Không hỏi-đáp tự do với AI; không đa ngôn ngữ; không huấn luyện/tinh chỉnh AI riêng.
- Không làm dashboard/lưới phòng (feature `room-dashboard`) hay nhật ký chi tiết (feature `audit-log`) — feature này chỉ tiêu thụ số liệu của chúng.
- Không xuất/chia sẻ bản tóm tắt ra kênh ngoài.

## 3. Personas & Use Cases

| Persona | Bối cảnh | Use cases trong feature |
|---------|----------|--------------------------|
| Quản lý | Web dashboard, cuối ca/ngày | Chọn kỳ và tạo tóm tắt; đọc bản AI/báo cáo mẫu kèm thời điểm + nhãn; đi từ mục "việc cần chú ý" về dashboard; tạo lại/đổi kỳ |

Ref: `[[docs/features/ai-ops-summary/ai-ops-summary-urd.md]]` mục User Types + Journeys. *Chỉ quản lý dùng feature này — vai trò khác bị chặn truy cập.*

## 4. Capabilities (Epics)

| ID | Epic | P | Rationale | Sizing | Trace |
|----|------|---|-----------|--------|-------|
| CAP-ai-ops-summary-01 | Chọn kỳ + tạo tóm tắt theo yêu cầu | P0 | Điểm vào của feature; không có thì không có gì | bóc ~3 story | UN-001 → BO-ai-ops-summary-01 |
| CAP-ai-ops-summary-02 | Tính số liệu tổng hợp không định danh của kỳ | P0 | Nguồn dữ liệu bắt buộc cho AI lẫn báo cáo mẫu; ràng buộc compliance | ~4 | UN-002 → BO-01, BO-04 |
| CAP-ai-ops-summary-03 | Gọi dịch vụ LLM + nhận tóm tắt có cấu trúc kèm gợi ý việc cần chú ý | P0 | Giá trị cốt lõi của feature | ~4 | UN-001, UN-003 → BO-01 |
| CAP-ai-ops-summary-04 | Kiểm tra đầu ra AI khớp dữ liệu gốc | P0 | Cam kết tôn chỉ "kiểm tra đầu ra"; chống bản sai lọt hiển thị | ~3 | UN-002 → BO-01 |
| CAP-ai-ops-summary-05 | Hiển thị kèm thời điểm dữ liệu + nhãn "tham khảo"/"báo cáo mẫu" | P0 | Cam kết tôn chỉ; chống nhầm bản AI là quyết định hệ thống | ~3 | UN-004 → BO-01 |
| CAP-ai-ops-summary-06 | Hạn mức chi phí + fallback báo cáo mẫu | P0 | Bảo vệ ngân sách 300.000 VNĐ và tính liên tục vận hành | ~4 | UN-005 → BO-02, BO-03 |
| CAP-ai-ops-summary-07 | Gợi ý việc cần chú ý liên kết về dashboard (việc quá hạn, phòng ngừng phục vụ) | P1 | Tăng giá trị hành động; phụ thuộc dashboard có sẵn | ~3 | UN-003 → BO-01 |
| CAP-ai-ops-summary-08 | Xem lại bản tóm tắt gần nhất đã tạo | P1 | Tiện cho quản lý, không phát sinh lượt gọi AI mới | ~3 | UN-006 → BO-01 |
| CAP-ai-ops-summary-09 | Tự động tạo tóm tắt theo lịch cuối ca | P2 | Ngoài MVP — tôn chỉ chỉ yêu cầu theo yêu cầu | ~4 | UN-001 → BO-01 |

### Done when (product level)

- CAP-ai-ops-summary-01: Quản lý chọn được kỳ trong các tùy chọn có sẵn và bấm tạo; thấy trạng thái đang tạo, nút bị khóa trong lúc chạy; không cho chọn kỳ tương lai.
- CAP-ai-ops-summary-02: Số liệu của kỳ gồm: số phòng theo từng trạng thái trên 3 trục, tỷ lệ lấp đầy, số việc dọn/bảo trì theo trạng thái, số việc quá hạn, sự kiện nổi bật từ nhật ký — tất cả dạng tổng hợp, 0 trường định danh khách.
- CAP-ai-ops-summary-03: Với kỳ có dữ liệu và còn hạn mức, nhận về bản tóm tắt có cấu trúc 3 phần (tổng quan + điểm nổi bật + việc cần chú ý).
- CAP-ai-ops-summary-04: Mọi con số trong bản AI khớp số liệu gốc của kỳ; bản chứa sự kiện không có trong dữ liệu bị loại và không bao giờ hiển thị.
- CAP-ai-ops-summary-05: 100% bản hiển thị kèm "Dữ liệu tính đến {T}" và nhãn đúng loại ("tham khảo" cho bản AI / "báo cáo mẫu" cho bản mẫu).
- CAP-ai-ops-summary-06: Mọi lượt gọi AI đi qua kiểm tra hạn mức ở máy chủ; AI lỗi/timeout/hết hạn mức/đầu ra sai/kỳ rỗng → báo cáo mẫu đủ chỉ số chính + việc cần chú ý theo quy tắc; mọi lượt tạo có nhật ký.
- CAP-ai-ops-summary-07: Mục việc cần chú ý dẫn về đúng vị trí tương ứng trên dashboard.
- CAP-ai-ops-summary-08: Quản lý mở lại được bản gần nhất mà không tạo mới.
- CAP-ai-ops-summary-09: (Sau MVP) hệ thống tự tạo tóm tắt theo lịch cuối ca.

## 5. Upstream Traceability

| Capability | Traces to (UN-* / BO-*) | Product outcome | Success metric |
|------------|-------------------------|-----------------|----------------|
| CAP-ai-ops-summary-01 | UN-001 → BO-01 | Tóm tắt tạo được trong 1 thao tác | ≥18/20 tình huống nghiệm thu |
| CAP-ai-ops-summary-02 | UN-002 → BO-01, BO-04 | Số liệu đúng và không định danh | 0 payload chứa định danh khách |
| CAP-ai-ops-summary-03 | UN-001, UN-003 → BO-01 | Bản có cấu trúc + việc cần chú ý | ≥18/20 tình huống nghiệm thu |
| CAP-ai-ops-summary-04 | UN-002 → BO-01 | Không bản sai nào hiển thị | 0 sự kiện bịa lọt qua |
| CAP-ai-ops-summary-05 | UN-004 → BO-01 | Luôn rõ nguồn + thời điểm | 100% bản kèm nhãn + thời điểm |
| CAP-ai-ops-summary-06 | UN-005 → BO-02, BO-03 | Vận hành liên tục, chi phí trong ngân sách | 100% ca lỗi → báo cáo mẫu; 0 đồng vượt ngân sách |
| CAP-ai-ops-summary-07 | UN-003 → BO-01 | Việc cần chú ý dẫn hành động | Đếm được trong demo |
| CAP-ai-ops-summary-08 | UN-006 → BO-01 | Xem lại không tốn hạn mức | Phụ thuộc OQ-4 |
| CAP-ai-ops-summary-09 | UN-001 → BO-01 | Tự động hóa sau MVP | — (ngoài MVP) |

## 6. Key Capability Interactions

- `room-dashboard` → nguồn chỉ số tổng hợp (đang ở/sẵn sàng/cần dọn/ngừng/quá hạn/lấp đầy) và đích liên kết từ mục việc cần chú ý (CAP-07).
- `audit-log` → nguồn sự kiện nổi bật trong kỳ; đồng thời nhận nhật ký mọi lượt tạo tóm tắt (thành công/fallback/lỗi).
- `auth-roles` → kiểm quyền quản lý cho mọi thao tác của feature.
- Feature này KHÔNG ghi vào feature nào khác: AI chỉ đọc số liệu, không chạm 3 trục trạng thái phòng.

## 7. Success Metrics

| Metric | Baseline | Target | Measurement | Timeframe |
|--------|----------|--------|-------------|-----------|
| Tỉ lệ tóm tắt AI đúng (số liệu đúng, không bịa sự kiện, nêu đúng việc cần chú ý) | Chưa có | ≥18/20 tình huống | Kịch bản nghiệm thu AI của tôn chỉ | Nghiệm thu 02/11 |
| Tỉ lệ ca AI lỗi/hết hạn mức rơi về báo cáo mẫu | Chưa có | 100% | Kịch bản nghiệm thu bắt buộc | Nghiệm thu |
| Bản hiển thị kèm thời điểm dữ liệu + nhãn đúng loại | Chưa có | 100% | Kiểm tra giao diện trong demo | Nghiệm thu |
| Chi phí API AI thực tế | Chưa có | ≤300.000 VNĐ toàn MVP | Đối soát nhật ký gọi AI + hóa đơn provider | Liên tục |
| Hành động ghi phát sinh từ kết quả AI | Chưa có | 0 | Đối soát audit-log | Liên tục |

## 8. Dependencies

| Dependency | Owner | Status | Needed By |
|------------|-------|--------|-----------|
| Nhóm chỉ số tổng hợp của kỳ | Feature `room-dashboard` (sprint 3, song song) | Chưa có — tham chiếu theo PRD 7.7 | CAP-02, CAP-07 |
| Sự kiện nổi bật trong kỳ + ghi nhật ký lượt tạo | Feature `audit-log` (sprint 2–3) | Chưa có — tham chiếu theo PRD 7.8 | CAP-02, CAP-06 |
| Vai trò quản lý + kiểm quyền máy chủ | Feature `auth-roles` (sprint 1) | Đã chi tiết | CAP-ai-ops-summary-01 |
| Dịch vụ LLM có đầu ra cấu trúc | OpenAI Responses API, Structured Outputs | Đã chốt | CAP-ai-ops-summary-03 |
| Ngân sách API AI 300.000 VNĐ | WPCTeam (tôn chỉ) | Đã phân bổ | CAP-ai-ops-summary-06 |

## 9. Assumptions

- Ca cố định 06:00–14:00, 14:00–22:00, 22:00–06:00 theo giờ địa phương; có tùy chọn hôm nay.
- Hạn mức là chi phí thực tế, tối đa 300.000 VNĐ toàn MVP; timeout 15 giây.
- Dùng OpenAI Responses API với Structured Outputs; lưu bản gần nhất của mỗi kỳ.
- Dữ liệu giả lập đủ sự kiện để tóm tắt có nội dung (kịch bản ca đỉnh).

## 10. Risks (product)

| Risk | P | Impact | Mitigation | Owner |
|------|---|--------|------------|-------|
| AI bịa sự kiện/sai số liệu → mất tin | Medium | Cao | CAP-04 kiểm tra đầu ra; nhãn tham khảo; fallback báo cáo mẫu | PM |
| Hết hạn mức/vượt ngân sách giữa demo | Medium | Cao | CAP-06 hạn mức máy chủ; chỉ tạo theo yêu cầu; báo cáo mẫu vẫn chạy | PM |
| Dịch vụ AI ngoài sập/mạng chập chờn | Medium | Trung bình | Báo cáo mẫu không phụ thuộc AI; thời gian chờ giới hạn | PM |
| Quản lý tin AI mù (automation bias) | Medium | Trung bình | Nhãn tham khảo cố định; AI không quyền ghi; cảnh báo quá hạn chạy quy tắc riêng | PM |
| `room-dashboard`/`audit-log` chậm → không có nguồn số liệu | Medium | Cao | Sprint 3 song song; fallback báo cáo mẫu vẫn cần số liệu nguồn — theo dõi tiến độ 2 feature nguồn | PM |

## 11. Release Plan

### Now (Sprint 3 — khung 06/10–19/10, "tích hợp, đánh giá AI")

- CAP-ai-ops-summary-01, 02, 03, 04, 05, 06 — đủ để tạo tóm tắt an toàn + fallback + kiểm soát chi phí (P0-sufficient).

### Next (cuối Sprint 3 / Sprint 4 nếu còn thời gian)

- CAP-ai-ops-summary-07 — liên kết việc cần chú ý về dashboard.
- CAP-ai-ops-summary-08 — xem lại bản gần nhất.

### Later (sau MVP)

- CAP-ai-ops-summary-09 — tự động theo lịch; hỏi-đáp tự do; đa ngôn ngữ.

## 12. Launch Readiness

- Guardrail: tỉ lệ tóm tắt đúng ≥18/20 trong kịch bản nghiệm thu; 100% ca lỗi → báo cáo mẫu; 0 đồng vượt 300.000 VNĐ; 0 hành động ghi từ AI. Vượt ngưỡng → dừng demo AI, giữ báo cáo mẫu.
- Demo script: ca giả lập nhiều sự kiện → tạo tóm tắt AI → đối chiếu số liệu dashboard → tắt AI mô phỏng lỗi → báo cáo mẫu vẫn đủ số liệu.
- Rollback: tắt gọi AI (hết hạn mức) — báo cáo mẫu thay thế hoàn toàn, không mất chức năng xem số liệu.

## 13. Open Questions
