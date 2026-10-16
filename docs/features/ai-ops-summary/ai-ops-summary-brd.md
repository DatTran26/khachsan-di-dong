---
type: brd
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/ai-ops-summary/ai-ops-summary-urd.md|AI Ops Summary URD]]"
  - "[[docs/features/ai-ops-summary/brainstorms/ai-tom-tat-van-hanh.md|Brainstorm: AI tóm tắt vận hành]]"
  - "[[docs/_product/prd.md|Product PRD — mục 7.9]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# ai-ops-summary — Business Requirements Document

## 1. Executive Summary

Cuối mỗi ca/ngày, quản lý đang tự tổng hợp tình hình vận hành bằng cách mở nhiều màn hình (dashboard, nhật ký từng phòng) — chậm và dễ sót việc đang trễ. Feature này cho phép tạo bản tóm tắt vận hành trong một thao tác: hệ thống tính số liệu tổng hợp (không chứa thông tin định danh khách), gửi tới một dịch vụ LLM bên ngoài, nhận về bản tóm tắt có cấu trúc kèm gợi ý việc cần chú ý. Bản tóm tắt luôn kèm thời điểm dữ liệu và nhãn "tham khảo"; AI chỉ đọc số liệu, không tự sửa dữ liệu hay quyết định nghiệp vụ. Khi dịch vụ AI lỗi hoặc hết hạn mức, hệ thống hiển thị báo cáo mẫu dựng từ dữ liệu gốc — vận hành không bị gián đoạn và chi phí AI được kiểm soát trong ngân sách 300.000 VNĐ của tôn chỉ.

## 2. Business Problem & Context

### 2.1 Problem Statement

| ID | Business Condition | Baseline | Business Impact | Evidence |
|----|--------------------|----------|-----------------|----------|
| BP-ai-ops-summary-01 | Quản lý tự tổng hợp tình hình cuối ca từ nhiều màn hình | Chưa có — xác lập qua quan sát demo | Tổng hợp chậm, sót việc quá hạn/phòng ngừng phục vụ → bàn giao ca thiếu thông tin, điều phối trễ | Confirmed (tôn chỉ: "AI tạo bản tóm tắt vận hành theo ca/ngày từ số liệu hệ thống và gợi ý các việc cần chú ý") |
| BP-ai-ops-summary-02 | Dùng AI mà không kiểm chứng thì rủi ro bản tóm tắt sai số liệu/bịa sự kiện | Chưa có | Quản lý quyết định trên dữ liệu sai, mất tin vào hệ thống | Confirmed (tôn chỉ: "kiểm tra đầu ra"; PRD mục 10 rủi ro AI) |
| BP-ai-ops-summary-03 | Chi phí API AI không kiểm soát sẽ vượt ngân sách demo | Hạn mức 300.000 VNĐ cho toàn bộ thử nghiệm + demo (tôn chỉ) | Hết ngân sách giữa chừng → mất tính năng ngay lúc demo/nghiệm thu | Confirmed (tôn chỉ: "giới hạn chi phí", hạng mục API AI 300.000 VNĐ) |
| BP-ai-ops-summary-04 | Gửi dữ liệu vận hành ra dịch vụ ngoài có nguy cơ lộ thông tin khách | Chưa có | Vi phạm ràng buộc dữ liệu giả lập/không định danh của dự án | Confirmed (tôn chỉ: "gửi dữ liệu tổng hợp không chứa thông tin định danh khách") |

### 2.2 Opportunity & Why Now

Feature nằm trong Sprint 3 (06/10–19/10) theo kế hoạch tôn chỉ: "Dashboard và cảnh báo quá hạn; hoàn thiện giao diện web/mobile; tích hợp, đánh giá AI". Đây là thời điểm dashboard (`room-dashboard`) và nhật ký (`audit-log`) đã có dữ liệu đủ để tổng hợp, và là điều kiện để đạt tiêu chí nghiệm thu AI của tôn chỉ (≥18/20 tình huống đúng, 100% ca lỗi rơi về báo cáo mẫu).

### 2.3 Strategic Alignment

Trực tiếp phục vụ mục tiêu tôn chỉ: "Tích hợp AI tạo bản tóm tắt vận hành theo ca/ngày từ số liệu hệ thống và gợi ý các việc cần chú ý. AI chỉ hỗ trợ người quản lý, không tự sửa dữ liệu hoặc đưa ra quyết định nghiệp vụ." Đồng thời là lợi thế khác biệt của sản phẩm (PRD mục 4): tóm tắt AI hỗ trợ quản lý trên nền luồng vận hành 3 trục khép kín.

## 3. Current State, Future State & Gap

### 3.1 Current State (AS-IS)

Cuối ca, quản lý tự mở dashboard xem chỉ số, lật nhật ký từng phòng để biết sự kiện nổi bật, tự cộng số việc quá hạn — rồi tự viết/nhẩm bản bàn giao. Không có bản tin chốt theo thời điểm, không có cơ chế nhờ AI diễn giải số liệu.

### 3.2 Future State (TO-BE)

Quản lý chọn kỳ và bấm một nút: hệ thống chốt thời điểm dữ liệu, tính số liệu tổng hợp không định danh, nhờ AI diễn giải thành bản tóm tắt có cấu trúc đã được kiểm tra khớp dữ liệu gốc. Mọi bản kèm thời điểm dữ liệu và nhãn "tham khảo". Khi AI lỗi/hết hạn mức/kết quả sai, quản lý vẫn có báo cáo mẫu từ dữ liệu gốc. Chi phí AI bị chặn bởi hạn mức — không vượt ngân sách.

### 3.3 Gap

| Gap | Mô tả | Ưu tiên |
|-----|-------|---------|
| G1 | Chưa có cơ chế tổng hợp số liệu vận hành theo kỳ (từ chỉ số dashboard + sự kiện nhật ký) | Cao |
| G2 | Chưa có kênh nhờ AI diễn giải số liệu an toàn (không định danh, có kiểm tra đầu ra) | Cao |
| G3 | Chưa có cơ chế bảo vệ: hạn mức chi phí + fallback báo cáo mẫu khi AI lỗi | Cao |
| G4 | Chưa có chuẩn hiển thị "tham khảo" kèm thời điểm dữ liệu để tránh nhầm bản AI là quyết định hệ thống | Trung bình |

## 4. Stakeholders

| Stakeholder Role | Interest | Influence | Stakeholder Requirement / Expectation |
|------------------|----------|-----------|----------------------------------------|
| Quản lý khách sạn | Nắm tình hình cuối ca nhanh và đáng tin | Cao (người dùng chính, quyết định nghiệp vụ) | Bản tóm tắt đúng số liệu, nêu đúng việc cần chú ý; hiểu rõ đây là tham khảo; vẫn có báo cáo khi AI lỗi |
| WPCTeam (dev) | Hoàn thành MVP đúng phạm vi 8 tuần, trong ngân sách | Cao | Tích hợp AI khả thi trong sprint 3; chi phí API không vượt 300.000 VNĐ; không phình scope |
| Giảng viên hướng dẫn | Đánh giá theo tiêu chí môn học | Cao | Tiêu chí AI của tôn chỉ đạt: ≥18/20 tình huống đúng; fallback báo cáo mẫu 100% khi lỗi |
| Người vận hành hệ thống (WPCTeam vận hành demo) | Kiểm soát chi phí và sự cố dịch vụ ngoài | Trung bình | Theo dõi được hạn mức đã dùng; mọi lượt gọi AI có nhật ký để đối soát chi phí |

## 5. Business Objectives & Success Measures

| ID | Objective | Baseline | Target | Timeframe | Success Measure |
|----|-----------|----------|--------|-----------|-----------------|
| BO-ai-ops-summary-01 | Quản lý có bản tóm tắt vận hành đáng tin theo ca/ngày trong 1 thao tác | Chưa có — hiện tổng hợp thủ công | ≥18/20 tình huống thử nghiệm đúng số liệu, không thêm sự kiện, nêu đúng việc cần chú ý | Sprint 3 → nghiệm thu 02/11 | Kịch bản nghiệm thu AI của tôn chỉ |
| BO-ai-ops-summary-02 | Vận hành không phụ thuộc vào độ khả dụng của dịch vụ AI ngoài | Chưa có | 100% ca API lỗi hoặc hết hạn mức hiển thị báo cáo mẫu đủ số liệu cốt lõi | Sprint 3 → nghiệm thu | Kịch bản nghiệm thu bắt buộc |
| BO-ai-ops-summary-03 | Chi phí AI nằm trong ngân sách được duyệt | 300.000 VNĐ (hạng mục API AI, tôn chỉ) | 0 đồng chi vượt ngân sách; 100% lượt gọi AI đi qua kiểm tra hạn mức | Liên tục tới nghiệm thu | Đối soát nhật ký gọi AI + chi phí thực tế |
| BO-ai-ops-summary-04 | AI không bao giờ tự quyết định hay sửa dữ liệu nghiệp vụ | Chưa có | 0 hành động ghi từ phía AI; 0 payload chứa thông tin định danh khách | Liên tục | Đối soát nhật ký thay đổi + kiểm tra dữ liệu gửi ra |

## 6. Business Scope

### 6.1 In Scope

- Tạo bản tóm tắt vận hành theo yêu cầu cho kỳ ca/ngày tại 1 khách sạn 50 phòng, phục vụ vai trò quản lý trên web dashboard.
- Tổng hợp số liệu không định danh từ dashboard và nhật ký; gọi một dịch vụ LLM bên ngoài; kiểm tra đầu ra khớp dữ liệu gốc.
- Bảo vệ vận hành: hạn mức chi phí, báo cáo mẫu khi AI lỗi/hết hạn mức/kỳ rỗng, ghi nhật ký mọi lượt tạo.

### 6.2 Out of Scope

- Tự động tạo theo lịch; hỏi-đáp tự do với AI; huấn luyện/tinh chỉnh AI riêng; đa ngôn ngữ.
- AI ra quyết định hoặc tự sửa dữ liệu/trạng thái phòng (cấm theo tôn chỉ).
- Báo cáo doanh thu/dự báo; xuất bản tóm tắt ra kênh ngoài.
- Nhiều khách sạn; dữ liệu khách thật.

### 6.3 Assumptions

- Khung giờ "ca" được định nghĩa sẵn trong hệ thống (OQ-1); nếu không, quản lý chọn khoảng tùy ý.
- Dùng OpenAI Responses API với Structured Outputs.
- Bản tóm tắt có lưu để xem lại hay không chưa chốt (OQ-4); MVP tối thiểu hiển thị tức thời.
- Số liệu tổng hợp lấy từ dashboard và nhật ký đã đủ tin cậy (hai feature nguồn chạy trước/cùng sprint 3).

### 6.4 Constraints

- Ngân sách API AI tối đa 300.000 VNĐ cho toàn bộ thử nghiệm + demo (tôn chỉ) — do đó cần hạn mức chặn ở máy chủ (OQ-2).
- Dữ liệu gửi dịch vụ AI chỉ là số liệu tổng hợp, không chứa thông tin định danh khách (tôn chỉ + compliance dự án).
- AI chỉ hỗ trợ quản lý, không tự sửa dữ liệu hoặc đưa ra quyết định nghiệp vụ (tôn chỉ).
- Cảnh báo quá hạn trên dashboard chạy bằng quy tắc, không phụ thuộc AI (tôn chỉ) — tóm tắt AI không được là nguồn duy nhất cho cảnh báo vận hành.
- MVP 8 tuần, team 3 người ~20h/người/tuần; feature thuộc sprint 3.
- Tiếng Việt, dữ liệu giả lập, 1 khách sạn.

### 6.5 Dependencies

- `room-dashboard` cung cấp nhóm chỉ số tổng hợp của kỳ (sprint 3, cùng theme Giám sát & truy vết).
- `audit-log` cung cấp sự kiện nổi bật trong kỳ (sprint 2–3).
- `auth-roles` cung cấp vai trò quản lý và kiểm quyền (sprint 1).
- OpenAI Responses API cung cấp đầu ra có cấu trúc.

## 7. High-level Business Requirements

| ID | Business Requirement | Business Objective | Priority |
|----|----------------------|--------------------|----------|
| BREQ-ai-ops-summary-01 | Quản lý phải tạo được bản tóm tắt vận hành có cấu trúc theo yêu cầu cho kỳ ca/ngày | BO-ai-ops-summary-01 | Must |
| BREQ-ai-ops-summary-02 | Số liệu tổng hợp phải lấy từ dữ liệu hệ thống (dashboard + nhật ký) và không chứa thông tin định danh khách | BO-ai-ops-summary-01, BO-ai-ops-summary-04 | Must |
| BREQ-ai-ops-summary-03 | Mọi bản tóm tắt hiển thị phải kèm thời điểm dữ liệu và nhãn "tham khảo" / "báo cáo mẫu" đúng loại | BO-ai-ops-summary-01 | Must |
| BREQ-ai-ops-summary-04 | Khi AI lỗi, quá thời gian chờ, đầu ra sai, hết hạn mức hoặc kỳ rỗng — hệ thống phải hiển thị báo cáo mẫu từ dữ liệu gốc thay vì để trống | BO-ai-ops-summary-02 | Must |
| BREQ-ai-ops-summary-05 | Mọi lượt gọi AI phải bị chặn bởi hạn mức chi phí ở máy chủ và được ghi nhật ký phục vụ đối soát | BO-ai-ops-summary-03 | Must |
| BREQ-ai-ops-summary-06 | AI chỉ được đọc số liệu — không đường nào cho kết quả AI ghi vào dữ liệu nghiệp vụ | BO-ai-ops-summary-04 | Must |

## 8. Business Rules

| ID | Business Rule | Rationale |
|----|---------------|-----------|
| BR-ai-ops-summary-01 | Chỉ vai trò quản lý được tạo và xem tóm tắt vận hành | Feature phục vụ quản lý (PRD 7.9); tránh lộ số liệu tổng hợp cho vai trò không cần |
| BR-ai-ops-summary-02 | Dữ liệu gửi dịch vụ AI chỉ gồm số liệu tổng hợp (đếm, tỷ lệ); cấm thông tin định danh khách và nhật ký thô từng dòng | Ràng buộc compliance của tôn chỉ; giảm rủi ro lộ dữ liệu ra ngoài |
| BR-ai-ops-summary-03 | AI chỉ tham khảo: không tự sửa dữ liệu, không đổi trạng thái phòng, không quyết định nghiệp vụ; mọi bản kèm nhãn "tham khảo" | Tôn chỉ; chống automation bias của quản lý |
| BR-ai-ops-summary-04 | Kỳ không có dữ liệu hoạt động thì không gọi AI — hiển thị báo cáo mẫu rỗng | Tiết kiệm hạn mức trong ngân sách 300.000 VNĐ |
| BR-ai-ops-summary-05 | Đầu ra AI sai số liệu hoặc chứa sự kiện không có trong dữ liệu gốc thì loại bản AI, hiển thị báo cáo mẫu và ghi nhật ký sự kiện lỗi | Tôn chỉ "kiểm tra đầu ra"; bảo vệ niềm tin của quản lý |
| BR-ai-ops-summary-06 | Khi đã hết hạn mức, mọi yêu cầu tạo đều rơi về báo cáo mẫu — không còn lượt gọi AI nào | Kiểm soát ngân sách tuyệt đối |
| BR-ai-ops-summary-07 | Tại một thời điểm chỉ có 1 lượt tạo đang chạy; yêu cầu sau nhận thông báo "đang tạo" | Tránh gọi AI trùng lặp lãng phí hạn mức |

## 9. Cost-Benefit (định tính)

### 9.1 Cost Drivers

- Chi phí API AI: hạng mục riêng 300.000 VNĐ trong ngân sách 1.500.000 VNĐ (tôn chỉ) — giới hạn cứng cho thử nghiệm + demo.
- Effort phát triển sprint 3 (trong kế hoạch 480 giờ): màn tóm tắt trên web dashboard, tính số liệu tổng hợp, gọi dịch vụ AI, kiểm tra đầu ra, báo cáo mẫu, hạn mức.

### 9.2 Expected Benefits

- Quản lý tiết kiệm thời gian tổng hợp cuối ca và giảm sót việc đang trễ → điều phối kịp hơn.
- Demo/nghiệm thu có điểm khác biệt (AI hỗ trợ quản lý có kiểm chứng) đúng tiêu chí môn học.
- Không phụ thuộc AI: báo cáo mẫu giữ vận hành liên tục khi dịch vụ ngoài sự cố.

### 9.3 Priority / Rough ROI

Ưu tiên cao trong sprint 3 — là tiêu chí nghiệm thu bắt buộc của tôn chỉ ("AI đạt ít nhất 18/20 tình huống"). Chi phí bị chặn cứng 300.000 VNĐ; lợi ích chủ yếu là chất lượng demo và hỗ trợ quản lý, định tính — không dựng ROI định lượng (đồ án, không mô hình kinh doanh).

## 10. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner Role |
|----|------|------------|--------|------------|------------|
| RISK-ai-ops-summary-01 | AI bịa sự kiện/sai số liệu | Thỉnh thoảng | Quản lý mất tin vào hệ thống, quyết định trên dữ liệu sai | Kiểm tra đầu ra khớp dữ liệu gốc, loại bản sai → báo cáo mẫu; nhãn "tham khảo" cố định | Trưởng nhóm |
| RISK-ai-ops-summary-02 | Vượt chi phí API / hết hạn mức giữa demo | Thỉnh thoảng | Mất tính năng AI ngay lúc nghiệm thu | Hạn mức chặn ở máy chủ; chỉ tạo theo yêu cầu; kỳ rỗng không gọi; báo cáo mẫu vẫn hoạt động | Người vận hành |
| RISK-ai-ops-summary-03 | Dịch vụ AI ngoài không khả dụng/mạng chập chờn | Thỉnh thoảng | Không có tóm tắt AI khi cần | Thời gian chờ giới hạn (OQ-5) → báo cáo mẫu; chức năng báo cáo mẫu không phụ thuộc AI | Người vận hành |
| RISK-ai-ops-summary-04 | Quản lý tin AI tuyệt đối (automation bias) | Thỉnh thoảng | Quyết định sai mà không đối chiếu dữ liệu gốc | Nhãn tham khảo cố định; AI không có quyền ghi; cảnh báo quá hạn vẫn chạy quy tắc riêng trên dashboard | Quản lý |
| RISK-ai-ops-summary-05 | Dữ liệu giả lập ít sự kiện → tóm tắt nghèo nàn | Thỉnh thoảng | Demo kém ấn tượng | Kịch bản giả lập có ca đỉnh nhiều sự kiện; ghi rõ giới hạn xác thực thực tế | Trưởng nhóm |

## 11. Open Questions
