---
type: srs-spec
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/ai-ops-summary/ai-ops-summary-prd.md|AI Ops Summary PRD]]"
  - "[[docs/_product/prd.md|Product PRD — mục 7.9]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# ai-ops-summary — SRS (Core Spec)

## 1. Purpose & Scope

Đặc tả chức năng tạo bản tóm tắt vận hành theo ca/ngày cho quản lý: chọn kỳ và tạo theo yêu cầu, tính số liệu tổng hợp không định danh khách, gọi dịch vụ LLM bên ngoài, kiểm tra đầu ra khớp dữ liệu gốc, hiển thị kèm thời điểm dữ liệu và nhãn "tham khảo", và rơi về báo cáo mẫu khi AI lỗi/hết hạn mức/kỳ rỗng. Phạm vi: 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập, chỉ vai trò quản lý trên web dashboard. Chỉ Tầng 1 (core spec) — chưa gồm models/UX/delivery.

## 2. Actors & Stakeholders

| Actor | Type | Trách nhiệm |
|-------|------|-------------|
| Quản lý | Người | Chọn kỳ, bấm tạo, đọc tóm tắt/báo cáo mẫu, dùng mục việc cần chú ý điều phối |
| Hệ thống | Hệ thống | Chốt thời điểm dữ liệu, tính số liệu tổng hợp, gọi AI, kiểm tra đầu ra, chặn hạn mức, dựng báo cáo mẫu, ghi nhật ký lượt tạo |
| Dịch vụ LLM | OpenAI Responses API | Nhận số liệu tổng hợp, trả bản tóm tắt có cấu trúc theo JSON Schema |
| Feature `room-dashboard` | Hệ thống | Nguồn chỉ số tổng hợp của kỳ (ngoài phạm vi spec này) |
| Feature `audit-log` | Hệ thống | Nguồn sự kiện nổi bật trong kỳ; nhận nhật ký lượt tạo (ngoài phạm vi spec này) |
| Feature `auth-roles` | Hệ thống | Kiểm quyền vai trò quản lý (ngoài phạm vi spec này) |

## 3. Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| FR-ai-ops-summary-001 | Hệ thống phải cho quản lý chọn kỳ tóm tắt trong các tùy chọn có sẵn (ca hiện tại / ca trước / hôm nay) và bấm tạo; không cho phép chọn kỳ tương lai. Khi bấm tạo, hệ thống phải chốt thời điểm dữ liệu T và khóa nút tạo trong lúc xử lý. | Demo: chọn từng kỳ, thử chọn kỳ tương lai | Must |
| FR-ai-ops-summary-002 | Khi có yêu cầu tạo, hệ thống phải tính số liệu tổng hợp của kỳ tại thời điểm T gồm: số phòng theo từng trạng thái trên 3 trục (lưu trú / vệ sinh / bảo trì), tỷ lệ lấp đầy, số việc dọn và bảo trì theo trạng thái, số việc quá hạn, và các sự kiện nổi bật từ nhật ký — tất cả ở dạng tổng hợp, không chứa thông tin định danh khách. | Test: đối chiếu số liệu tính được với dashboard + nhật ký cùng kỳ | Must |
| FR-ai-ops-summary-003 | Nếu kỳ được chọn không có dữ liệu hoạt động, hệ thống phải hiển thị báo cáo mẫu rỗng "Chưa có dữ liệu trong kỳ đã chọn." mà không gọi dịch vụ AI. | Test: chọn kỳ rỗng | Must |
| FR-ai-ops-summary-004 | Khi kỳ có dữ liệu và còn hạn mức, hệ thống phải gửi số liệu tổng hợp tới OpenAI Responses API và nhận bản tóm tắt có cấu trúc JSON Schema gồm: tổng quan + điểm nổi bật + việc cần chú ý. | Test: mock dịch vụ AI trả cấu trúc đúng | Must |
| FR-ai-ops-summary-005 | Trước khi hiển thị, hệ thống phải kiểm tra đầu ra AI: mọi con số nêu trong tóm tắt phải khớp số liệu gốc của kỳ và không được chứa sự kiện không có trong dữ liệu. Nếu đầu ra không hợp lệ, hệ thống phải loại bản AI, hiển thị báo cáo mẫu theo FR-007 và ghi nhật ký sự kiện "đầu ra AI không hợp lệ". | Test: mock AI trả sai số liệu / bịa sự kiện | Must |
| FR-ai-ops-summary-006 | Khi hiển thị bản tóm tắt AI, hệ thống phải kèm "Dữ liệu tính đến {thời điểm T}" và nhãn cố định "Tham khảo — tóm tắt do AI tạo, không thay quyết định vận hành". | Demo: kiểm tra nhãn và thời điểm trên giao diện | Must |
| FR-ai-ops-summary-007 | Khi dịch vụ AI lỗi, quá 15 giây, hệ thống đã hết hạn mức, hoặc đầu ra AI không hợp lệ — hệ thống phải hiển thị báo cáo mẫu dựng từ dữ liệu gốc: các chỉ số chính của kỳ + danh sách việc cần chú ý theo quy tắc (việc quá hạn, phòng ngừng phục vụ), kèm thời điểm T và nhãn "Báo cáo mẫu — dữ liệu gốc, chưa qua AI". | Test: mô phỏng lỗi/timeout/hết hạn mức | Must |
| FR-ai-ops-summary-008 | Tại một thời điểm hệ thống chỉ xử lý 1 yêu cầu tạo; khi đã có lượt đang chạy, yêu cầu sau phải nhận thông báo "Đang có một tóm tắt được tạo — vui lòng chờ." và không tạo thêm lượt gọi AI. | Test: 2 thiết bị/bấm liên tiếp cùng tạo | Must |
| FR-ai-ops-summary-009 | Mọi lượt gọi dịch vụ AI phải đi qua kiểm tra hạn mức chi phí ở máy chủ trước khi gọi và được tính vào hạn mức; khi đã hết hạn mức, hệ thống không được phát sinh lượt gọi AI nào nữa. | Test: chạm ngưỡng hạn mức rồi bấm tạo | Must |
| FR-ai-ops-summary-010 | Mọi lượt tạo (thành công / báo cáo mẫu / kỳ rỗng / lỗi) phải được ghi nhật ký ở máy chủ gồm: ai tạo, khi nào, kỳ nào, kết quả loại nào, có gọi AI hay không (bàn giao chi tiết cho feature `audit-log`). | Đối soát nhật ký với số lượt bấm | Must |
| FR-ai-ops-summary-011 | Chỉ vai trò quản lý được truy cập màn tóm tắt và tạo/xem bản tóm tắt; mọi thao tác phải kiểm tra quyền ở máy chủ. | Test bằng tài khoản lễ tân/nhân viên | Must |
| FR-ai-ops-summary-012 | Mục "việc cần chú ý" trong bản tóm tắt/báo cáo mẫu phải liệt kê các việc quá hạn và phòng ngừng phục vụ của kỳ, và cho phép đi tới vị trí tương ứng trên dashboard. | Demo: bấm từ mục cần chú ý về dashboard | Should |
| FR-ai-ops-summary-013 | Hệ thống phải cho quản lý xem lại bản tóm tắt gần nhất đã tạo của mỗi kỳ mà không phát sinh lượt gọi AI mới. | Demo: mở lại bản cũ | Should |
| FR-ai-ops-summary-014 | Khi mất kết nối trong lúc tạo, hệ thống phải báo "Mất kết nối — chưa tạo được tóm tắt. Thử lại khi có mạng." và không lưu bản lỗi; có mạng lại thì quản lý tạo lại. | Test: ngắt mạng giữa lúc tạo | Must |

## 4. Non-Functional Requirements

| ID | Requirement | Verification | Priority |
|----|-------------|--------------|----------|
| NFR-ai-ops-summary-001 | Performance: thời gian chờ tối đa khi gọi dịch vụ AI là 15 giây; quá thời gian chờ thì rơi về báo cáo mẫu, quản lý không chờ vô hạn. | Test: mock AI treo quá 15 giây | Must |
| NFR-ai-ops-summary-002 | Privacy: dữ liệu gửi dịch vụ AI chỉ gồm số liệu tổng hợp (đếm, tỷ lệ) — 0 trường định danh khách, không gửi nhật ký thô từng dòng. | Đối soát nội dung gói dữ liệu gửi ra trong test | Must |
| NFR-ai-ops-summary-003 | Cost: tổng chi phí API AI không vượt 300.000 VNĐ trong toàn bộ MVP (tôn chỉ); hạn mức được chặn ở máy chủ, không dựa vào thao tác phía người dùng. | Đối soát nhật ký gọi AI + chi phí provider | Must |
| NFR-ai-ops-summary-004 | Reliability: khi dịch vụ AI ngoài không khả dụng, chức năng báo cáo mẫu vẫn hoạt động 100% — vận hành không phụ thuộc AI. | Test: tắt kết nối tới dịch vụ AI | Must |
| NFR-ai-ops-summary-005 | Auditability: mọi lượt tạo có bản ghi đủ ai/khi/kỳ/kết quả/có gọi AI — đối soát được với chi phí API thực tế. | Đối soát log vs lượt tạo | Must |
| NFR-ai-ops-summary-006 | Usability: toàn bộ giao diện, bản tóm tắt, báo cáo mẫu và thông báo bằng tiếng Việt; nhãn "tham khảo"/"báo cáo mẫu" luôn hiển thị. | Demo | Must |

## 5. Business Rules

| ID | Rule | Source | Liên kết |
|----|------|--------|----------|
| BR-ai-ops-summary-001 | Chỉ vai trò quản lý được tạo và xem tóm tắt vận hành. | BRD BR-ai-ops-summary-01 / PRD 7.9 | FR-011 |
| BR-ai-ops-summary-002 | Dữ liệu gửi dịch vụ AI chỉ gồm số liệu tổng hợp; cấm thông tin định danh khách và nhật ký thô. | Tôn chỉ / BRD BR-02 | FR-002, NFR-002 |
| BR-ai-ops-summary-003 | AI chỉ tham khảo: không tự sửa dữ liệu, không đổi trạng thái phòng, không quyết định nghiệp vụ — không đường nào cho kết quả AI ghi vào dữ liệu nghiệp vụ. | Tôn chỉ / BRD BR-03 | FR-004, FR-005 |
| BR-ai-ops-summary-004 | Kỳ không có dữ liệu hoạt động thì không gọi AI. | BRD BR-04 | FR-003 |
| BR-ai-ops-summary-005 | Đầu ra AI sai số liệu hoặc chứa sự kiện không có trong dữ liệu gốc thì loại bản AI, hiển thị báo cáo mẫu và ghi nhật ký lỗi. | Tôn chỉ / BRD BR-05 | FR-005, FR-007 |
| BR-ai-ops-summary-006 | Khi hết hạn mức, mọi yêu cầu tạo rơi về báo cáo mẫu — không phát sinh lượt gọi AI. | BRD BR-06 | FR-009, FR-007 |
| BR-ai-ops-summary-007 | Tại một thời điểm chỉ 1 lượt tạo đang chạy. | BRD BR-07 | FR-008 |
| BR-ai-ops-summary-008 | Cảnh báo quá hạn trên dashboard chạy bằng quy tắc, không phụ thuộc AI — tóm tắt AI không phải nguồn duy nhất cho cảnh báo vận hành. | Tôn chỉ | FR-007, FR-012 |

## 6. Error Matrix

| ID | Error | Trigger | Severity | Linked Req | User Message |
|----|-------|---------|----------|------------|--------------|
| E-ai-ops-summary-001 | Kỳ không có dữ liệu | Chọn kỳ không có hoạt động | minor | FR-003 | "Chưa có dữ liệu trong kỳ đã chọn." (báo cáo mẫu rỗng) |
| E-ai-ops-summary-002 | Dịch vụ AI lỗi/timeout | AI trả lỗi hoặc quá thời gian chờ | major | FR-007 | "Không tạo được tóm tắt AI lúc này — hiển thị báo cáo mẫu từ dữ liệu gốc." |
| E-ai-ops-summary-003 | Hết hạn mức AI | Kiểm tra hạn mức trước khi gọi | major | FR-009 | "Đã hết hạn mức AI — hiển thị báo cáo mẫu từ dữ liệu gốc." |
| E-ai-ops-summary-004 | Mất kết nối khi tạo | Offline giữa lúc tạo | major | FR-014 | "Mất kết nối — chưa tạo được tóm tắt. Thử lại khi có mạng." |
| E-ai-ops-summary-005 | Đầu ra AI không hợp lệ | Sai số liệu / bịa sự kiện / sai cấu trúc | major | FR-005 | Không hiển thị bản sai — hiển thị báo cáo mẫu + ghi nhật ký lỗi đầu ra |
| E-ai-ops-summary-006 | Sai quyền vai trò | Vai trò không phải quản lý truy cập/tạo | major | FR-011 | "Bạn không có quyền thực hiện thao tác này." |
| E-ai-ops-summary-007 | Đã có lượt đang tạo | Bấm tạo khi đang có yêu cầu chạy | minor | FR-008 | "Đang có một tóm tắt được tạo — vui lòng chờ." |

## 7. Success Criteria

| ID | Criterion | Đo lường |
|----|-----------|----------|
| SC-ai-ops-summary-01 | ≥18/20 tình huống thử nghiệm: đúng số liệu, không thêm sự kiện không có trong dữ liệu, nêu đúng việc cần chú ý | Kịch bản nghiệm thu AI của tôn chỉ |
| SC-ai-ops-summary-02 | 100% ca API lỗi hoặc hết hạn mức rơi về báo cáo mẫu đủ số liệu cốt lõi | Kịch bản nghiệm thu bắt buộc |
| SC-ai-ops-summary-03 | 100% bản hiển thị kèm thời điểm dữ liệu và nhãn đúng loại ("tham khảo" / "báo cáo mẫu") | Kiểm tra giao diện trong demo |
| SC-ai-ops-summary-04 | 0 lần AI tự ghi/sửa dữ liệu nghiệp vụ (kể cả trạng thái phòng); 0 gói dữ liệu gửi ra chứa thông tin định danh khách | Đối soát audit-log + payload trong test |
| SC-ai-ops-summary-05 | Chi phí API AI thực tế ≤300.000 VNĐ trong toàn MVP | Đối soát nhật ký gọi AI + hóa đơn provider |

## 8. Entity Summary

| Entity | Fields chính | Quan hệ | Ghi chú |
|--------|--------------|---------|---------|
| Bản tóm tắt kỳ | kỳ (ca/ngày), thời điểm dữ liệu T, loại (AI / báo cáo mẫu), nội dung có cấu trúc (tổng quan + nổi bật + việc cần chú ý), trạng thái tạo | Tạo bởi 1 quản lý; đọc số liệu từ dashboard + nhật ký | Trạng thái: chưa có → đang tạo → sẵn sàng (AI) / sẵn sàng (mẫu) / rỗng; lưu bản gần nhất mỗi kỳ |
| Hạn mức AI | chi phí đã dùng, chi phí còn lại | Kiểm tra trước mọi lượt gọi AI | Chặn ở máy chủ; ngân sách tổng 300.000 VNĐ cho MVP |
| Số liệu tổng hợp kỳ | số phòng theo 3 trục, tỷ lệ lấp đầy, số việc theo trạng thái, số việc quá hạn, sự kiện nổi bật | Tính từ `room-dashboard` + `audit-log` | Chỉ tổng hợp, không định danh khách; không phải entity lưu trữ bắt buộc |

## 9. Flow Summary

- Luồng chính: quản lý chọn kỳ → bấm tạo → chốt thời điểm T → tính số liệu tổng hợp → kỳ rỗng thì báo cáo mẫu rỗng (không gọi AI) → còn hạn mức thì gọi AI → kiểm tra đầu ra khớp → hiển thị bản AI + thời điểm T + nhãn tham khảo → ghi nhật ký lượt tạo.
- Luồng phụ: AI lỗi/timeout/hết hạn mức/đầu ra sai → báo cáo mẫu từ dữ liệu gốc + nhãn báo cáo mẫu → ghi nhật ký; bấm tạo khi đang chạy → thông báo "đang tạo"; mất mạng → báo lỗi kết nối, không lưu bản lỗi.

## 10. Screen Summary

| Screen | Vai trò | Nội dung chính |
|--------|---------|----------------|
| Tóm tắt vận hành | Quản lý | Chọn kỳ (ca hiện tại/ca trước/hôm nay); nút "Tạo tóm tắt"; trạng thái đang tạo; vùng hiển thị bản AI/báo cáo mẫu kèm thời điểm T + nhãn đúng loại; mục việc cần chú ý liên kết về dashboard |

## 11. Constraints & Dependencies

### Constraints

- AI chỉ hỗ trợ quản lý, không tự sửa dữ liệu hoặc đưa ra quyết định nghiệp vụ (tôn chỉ).
- Dữ liệu gửi dịch vụ AI chỉ là số liệu tổng hợp không chứa thông tin định danh khách (tôn chỉ).
- Ngân sách API AI tối đa 300.000 VNĐ cho thử nghiệm + demo (tôn chỉ).
- Cảnh báo quá hạn trên dashboard dùng quy tắc, không phụ thuộc AI (tôn chỉ).
- Dùng OpenAI Responses API với Structured Outputs (`json_schema`); khóa API chỉ ở máy chủ và chi phí được đối soát theo usage/cost của provider.
- Nền tảng đã duyệt theo tôn chỉ: Flutter Web (màn dashboard), backend Node.js + Express + TypeScript, PostgreSQL + Prisma, Socket.IO cho realtime.
- MVP 8 tuần; feature thuộc Sprint 3 (06/10–19/10); 1 khách sạn 50 phòng, tiếng Việt, dữ liệu giả lập.
- Kiểm tra quyền và ghi nhật ký ở máy chủ cho mọi thao tác (tôn chỉ).

### Dependencies

- `room-dashboard`: nhóm chỉ số tổng hợp của kỳ (sprint 3, song song — tham chiếu PRD 7.7).
- `audit-log`: sự kiện nổi bật trong kỳ + nhận nhật ký lượt tạo (sprint 2–3 — tham chiếu PRD 7.8).
- `auth-roles`: vai trò quản lý + kiểm quyền máy chủ (sprint 1).
- OpenAI Responses API: đầu ra có cấu trúc cho bản tóm tắt.

### Assumptions

- Ca cố định theo giờ địa phương: 06:00–14:00, 14:00–22:00 và 22:00–06:00; quản lý cũng có thể chọn "hôm nay". Hạn mức theo chi phí thực tế, tổng tối đa 300.000 VNĐ trong MVP; lưu bản gần nhất của mỗi kỳ để xem lại mà không gọi AI; timeout 15 giây.
- Dữ liệu giả lập đủ sự kiện (kịch bản ca đỉnh) để bản tóm tắt có nội dung khi demo.
- Báo cáo mẫu dùng cùng nhóm chỉ số chính + việc cần chú ý theo quy tắc, không có narrative AI.
- Chốt 10/10/2026: kỳ "rỗng" (FR-003) = không có thao tác vận hành nào trong kỳ (nhận/trả, dọn, báo hỏng/sửa, ngừng/mở phục vụ, quá hạn). Bản rỗng vẫn kèm danh sách việc cần chú ý theo quy tắc đang tồn tại tại T (việc quá hạn, phòng ngừng phục vụ) để quản lý không bỏ sót; không gọi AI.
- Chốt 10/10/2026: với mọi kỳ, số phòng theo 3 trục / việc đang mở / việc quá hạn là ảnh chụp tại thời điểm T (khớp dashboard); số thao tác vận hành được đếm trong khung giờ của kỳ (kể cả "ca trước").
