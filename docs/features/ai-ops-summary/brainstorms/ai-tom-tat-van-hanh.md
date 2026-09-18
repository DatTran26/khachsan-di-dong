---
type: brainstorm
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - "[[docs/_product/prd.md|Product PRD — mục 7.9]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# ai-ops-summary — AI tóm tắt vận hành theo ca/ngày

## 1. Idea Seed

Cuối ca hoặc cuối ngày, quản lý bấm tạo bản tóm tắt vận hành: hệ thống tính số liệu tổng hợp từ dashboard và nhật ký (không chứa thông tin định danh khách), gửi tới một dịch vụ LLM bên ngoài, nhận về bản tóm tắt có cấu trúc kèm gợi ý việc cần chú ý. Bản tóm tắt luôn kèm thời điểm dữ liệu và nhãn "tham khảo"; AI chỉ đọc số liệu, không tự sửa dữ liệu hay đổi trạng thái phòng. Khi dịch vụ AI lỗi hoặc hết hạn mức, hệ thống hiển thị báo cáo mẫu dựng từ dữ liệu gốc.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: "Tích hợp AI tạo bản tóm tắt vận hành theo ca/ngày từ số liệu hệ thống và gợi ý các việc cần chú ý. AI chỉ hỗ trợ người quản lý, không tự sửa dữ liệu hoặc đưa ra quyết định nghiệp vụ"; ngân sách có hạng mục "API AI phục vụ thử nghiệm và demo" 300.000 VNĐ; cảnh báo quá hạn trên dashboard dùng quy tắc, không phụ thuộc AI. Feature nằm ở Sprint 3 (06/10–19/10): "tích hợp, đánh giá AI". Phụ thuộc `room-dashboard` (nguồn chỉ số tổng hợp) và `audit-log` (nguồn sự kiện trong kỳ) — xem Feature Map PRD mục 7.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Quản lý | Cuối ca phải tự mở nhiều màn hình (dashboard, nhật ký từng phòng) để tổng hợp tình hình — chậm, dễ sót việc đang trễ | Một bản tóm tắt có cấu trúc, đúng số liệu, nêu rõ việc cần chú ý, tạo trong 1 thao tác |

*Feature chỉ phục vụ quản lý (PRD mục 7.9); các vai trò khác không có điểm chạm trong feature này.*

## 4. Capabilities Breakdown

### P0 — must have

- Chọn kỳ tóm tắt (ca/ngày) và tạo tóm tắt theo yêu cầu — không tự động theo lịch.
- Tính số liệu tổng hợp không định danh khách từ chỉ số dashboard và nhật ký trong kỳ.
- Gọi dịch vụ LLM bên ngoài, nhận bản tóm tắt có cấu trúc kèm gợi ý việc cần chú ý.
- Kiểm tra đầu ra AI: số liệu trong tóm tắt phải khớp dữ liệu gốc, không thêm sự kiện.
- Hiển thị kèm thời điểm dữ liệu và nhãn "tham khảo" cố định.
- Giới hạn chi phí AI bằng hạn mức; hết hạn mức hoặc AI lỗi → báo cáo mẫu từ dữ liệu gốc.

### P1 — should have

- Xem lại bản tóm tắt gần nhất đã tạo (nếu chốt lưu — OQ-4).
- Gợi ý việc cần chú ý nhấn mạnh các việc quá hạn/phòng ngừng phục vụ, liên kết về dashboard.

### P2 — nice to have (ngoài MVP)

- Tự động tạo tóm tắt theo lịch cuối ca.
- Hỏi-đáp tự do với AI về số liệu vận hành.
- Đa ngôn ngữ; huấn luyện/tinh chỉnh AI riêng.

## 5. Core Flows (Happy Path)

### 5.1 Tạo tóm tắt AI thành công

1) Quản lý mở màn "Tóm tắt vận hành" trên web dashboard.
2) Quản lý chọn kỳ (ca hiện tại / ca trước / hôm nay) và bấm "Tạo tóm tắt".
3) Hệ thống chốt thời điểm dữ liệu T và tính số liệu tổng hợp của kỳ: số phòng theo từng trạng thái trên 3 trục, tỷ lệ lấp đầy, số việc dọn/bảo trì theo trạng thái, số việc quá hạn, các sự kiện nổi bật từ nhật ký — tất cả ở dạng tổng hợp, không định danh khách.
4) Hệ thống gửi số liệu tới dịch vụ LLM → nhận bản tóm tắt có cấu trúc (tổng quan + điểm nổi bật + việc cần chú ý).
5) Hệ thống kiểm tra đầu ra: số liệu khớp dữ liệu gốc, không có sự kiện bịa thêm.
6) Hiển thị tóm tắt kèm "Dữ liệu tính đến {thời điểm T}" và nhãn "Tham khảo — tóm tắt do AI tạo, không thay quyết định vận hành".

```
QUẢN LÝ            HỆ THỐNG                       DỊCH VỤ AI (ngoài)
   │                  │                                 │
   │ chọn kỳ,         │                                 │
   │ bấm "Tạo tóm tắt" │                                 │
   │─────────────────▶│ chốt thời điểm T                 │
   │                  │ tính số liệu tổng hợp           │
   │                  │ (dashboard + nhật ký,           │
   │                  │  không định danh khách)         │
   │                  │                                 │
   │                  │ còn hạn mức? ──NO──▶ báo cáo mẫu│
   │                  │        YES                      │
   │                  │ gửi số liệu tổng hợp            │
   │                  │────────────────────────────────▶│
   │                  │                                 │ tóm tắt có cấu trúc
   │                  │◀────────────────────────────────│
   │                  │ kiểm tra đầu ra:                │
   │                  │ số liệu khớp? không bịa?        │
   │                  │ ──NO──▶ báo cáo mẫu + ghi log   │
   │                  │        YES                      │
   │                  │ hiển thị + thời điểm T          │
   │◀─────────────────│ + nhãn "tham khảo"              │
   ▼                  ▼                                 ▼
   Mọi lượt tạo (thành công / fallback / lỗi) đều ghi nhật ký máy chủ
```

### 5.2 Fallback báo cáo mẫu khi AI lỗi / hết hạn mức

1) Quản lý bấm tạo tóm tắt như thường.
2) Hệ thống tính số liệu tổng hợp như bình thường.
3) Gọi dịch vụ AI thất bại (lỗi kết nối, lỗi dịch vụ, quá thời gian chờ) hoặc hệ thống từ chối gọi vì đã hết hạn mức.
4) Hệ thống hiển thị báo cáo mẫu dựng từ dữ liệu gốc: các chỉ số chính của kỳ + danh sách việc cần chú ý theo quy tắc (việc quá hạn, phòng ngừng phục vụ) + nhãn "Báo cáo mẫu — dữ liệu gốc, chưa qua AI" + thời điểm dữ liệu T.
5) Quản lý có thể bấm tạo lại sau (mỗi lần gọi đều tính vào hạn mức).

### 5.3 Đầu ra AI không khớp dữ liệu gốc

1) Dịch vụ AI trả bản tóm tắt nhưng bước kiểm tra phát hiện sai lệch (sai số liệu, nêu sự kiện không có trong dữ liệu).
2) Hệ thống KHÔNG hiển thị bản tóm tắt lỗi → rơi về báo cáo mẫu như 5.2, đồng thời ghi nhật ký sự kiện "đầu ra AI không hợp lệ".
3) Quản lý thấy báo cáo mẫu và có thể thử lại.

### 5.4 Kỳ được chọn không có dữ liệu

1) Quản lý chọn kỳ không có hoạt động nào (không trả phòng, không việc, không sự kiện nhật ký).
2) Hệ thống hiển thị báo cáo mẫu rỗng ("Chưa có dữ liệu trong kỳ đã chọn") mà KHÔNG gọi AI — tiết kiệm hạn mức.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Tạo tóm tắt | Kỳ chọn có dữ liệu hoạt động? | Tính số liệu tổng hợp, đi tiếp | Hiển thị báo cáo mẫu rỗng, không gọi AI |
| D2 | Gọi AI | Còn hạn mức chi phí? | Gửi số liệu tới dịch vụ AI | Báo cáo mẫu + nhãn hết hạn mức |
| D3 | Nhận kết quả | Dịch vụ AI trả kết quả hợp lệ trong thời gian chờ? | Sang kiểm tra đầu ra (D4) | Báo cáo mẫu |
| D4 | Kiểm tra đầu ra | Số liệu AI nêu khớp dữ liệu gốc và không có sự kiện bịa? | Hiển thị tóm tắt AI | Báo cáo mẫu + ghi nhật ký sự kiện lỗi đầu ra |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| Chưa có tóm tắt | Đang tạo | Quản lý chọn kỳ + bấm tạo | Chốt thời điểm T, tính số liệu | Hiển thị trạng thái đang tạo, khóa nút |
| Đang tạo | Sẵn sàng (AI) | AI trả hợp lệ + đầu ra khớp | Hiển thị tóm tắt có cấu trúc | Bản AI + thời điểm T + nhãn tham khảo |
| Đang tạo | Sẵn sàng (mẫu) | AI lỗi/timeout/hết hạn mức/đầu ra sai | Dựng báo cáo mẫu từ dữ liệu gốc | Bản mẫu + thời điểm T + nhãn báo cáo mẫu |
| Đang tạo | Rỗng | Kỳ không có dữ liệu | Không gọi AI | Thông báo "chưa có dữ liệu" |
| Đang tạo | Đang tạo | Bấm tạo lần nữa / thiết bị khác cùng tạo | Từ chối yêu cầu sau | Thông báo "đang tạo", giữ yêu cầu đầu |
| Sẵn sàng | Đang tạo | Quản lý đổi kỳ / bấm tạo lại | Tính lại tại thời điểm T mới | Bản mới thay bản cũ |

### 6.3 State Transitions

```
Bản tóm tắt của 1 kỳ:
chưa có → đang tạo → sẵn sàng (bản AI)
                  ↘ sẵn sàng (báo cáo mẫu)
                  ↘ rỗng (kỳ không dữ liệu)
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Bản tóm tắt | chưa có | đang tạo | Quản lý bấm tạo | không |
| Bản tóm tắt | đang tạo | sẵn sàng (AI) | AI hợp lệ + khớp số liệu | không |
| Bản tóm tắt | đang tạo | sẵn sàng (mẫu) | AI lỗi/hết hạn mức/đầu ra sai | không |
| Bản tóm tắt | đang tạo | rỗng | Kỳ không có dữ liệu | không |
| Bản tóm tắt | sẵn sàng | đang tạo | Quản lý tạo lại / đổi kỳ | có (tạo lại) |

*Trục trạng thái phòng (lưu trú/vệ sinh/bảo trì) KHÔNG bị feature này chạm vào — AI chỉ đọc số liệu.*

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Quản lý đóng tab khi đang tạo | Không có bản lưu; yêu cầu coi như hủy | Mở lại màn → bấm tạo lại | Không có |
| Dịch vụ AI quá thời gian chờ | Yêu cầu thất bại | Hiển thị báo cáo mẫu; quản lý thử lại sau | Không có |
| Dịch vụ AI lỗi / trả sai cấu trúc | Yêu cầu thất bại | Báo cáo mẫu | Ghi nhật ký sự kiện lỗi |
| Hết hạn mức giữa các lần tạo | Hạn mức đã cạn | Không gọi AI nữa, chỉ báo cáo mẫu | Không có |
| 2 yêu cầu tạo đồng thời | Yêu cầu đầu chạy | Yêu cầu sau nhận "đang tạo" | Không có |
| Mất mạng khi đang tạo | Yêu cầu không gửi/không nhận được | Có mạng lại → quản lý tạo lại | Không có |

### 6.5 Other Edge Cases

- Dữ liệu trong kỳ thay đổi trong lúc đang tạo: tóm tắt gắn thời điểm chốt T; thay đổi sau T không thuộc bản này — nhãn thời điểm dữ liệu làm rõ điều đó.
- Quản lý bấm tạo nhiều lần liên tiếp cho cùng kỳ: cho phép, nhưng mỗi lần gọi AI đều tính vào hạn mức — đây là lý do hạn mức phải chặn ở máy chủ.
- AI trả tóm tắt đúng số liệu nhưng gợi ý "việc cần chú ý" trống/không có gì nổi bật: hợp lệ — hiển thị bình thường.
- Lễ tân/nhân viên cố truy cập màn tóm tắt: không có quyền — hệ thống từ chối.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Vai trò thao tác | Chỉ quản lý được tạo/xem tóm tắt |
| Kỳ tóm tắt | Bắt buộc chọn trong các tùy chọn có sẵn (ca hiện tại / ca trước / hôm nay); không cho phép kỳ tương lai |
| Dữ liệu gửi AI | Chỉ số liệu tổng hợp (đếm, tỷ lệ); KHÔNG chứa thông tin định danh khách; không gửi nhật ký thô từng dòng |
| Đầu ra AI | Phải có cấu trúc đúng (tổng quan + điểm nổi bật + việc cần chú ý); số liệu nêu trong tóm tắt phải khớp dữ liệu gốc |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Hạn mức chi phí API AI | TBD (OQ-2) — ngân sách demo 300.000 VNĐ theo tôn chỉ | Tổng thời gian MVP | Không gọi AI nữa; mọi yêu cầu rơi về báo cáo mẫu |
| Thời gian chờ dịch vụ AI | TBD (OQ-5) | Mỗi lần gọi | Quá hạn → báo cáo mẫu |
| Tạo đồng thời | 1 yêu cầu đang chạy | Mỗi thời điểm | Yêu cầu sau báo "đang tạo" |
| Ngân sách API AI (tổng) | 300.000 VNĐ | Cả dự án (tôn chỉ) | Nguồn chi phí tối đa cho demo + thử nghiệm |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| Kỳ không có dữ liệu | "Chưa có dữ liệu trong kỳ đã chọn." | E-? |
| Dịch vụ AI lỗi/timeout | "Không tạo được tóm tắt AI lúc này — hiển thị báo cáo mẫu từ dữ liệu gốc." | E-? |
| Hết hạn mức AI | "Đã hết hạn mức AI — hiển thị báo cáo mẫu từ dữ liệu gốc." | E-? |
| Mất kết nối khi tạo | "Mất kết nối — chưa tạo được tóm tắt. Thử lại khi có mạng." | E-? |
| Sai quyền | "Bạn không có quyền thực hiện thao tác này." | E-? |

#### Success messages

| Tình huống | Wording |
|---|---|
| Tạo tóm tắt AI xong | "Đã tạo tóm tắt vận hành {kỳ} — dữ liệu tính đến {thời điểm}." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Nhãn bản AI | "Tham khảo — tóm tắt do AI tạo, không thay quyết định vận hành." |
| Nhãn báo cáo mẫu | "Báo cáo mẫu — dữ liệu gốc, chưa qua AI." |
| Đang tạo | "Đang tạo tóm tắt, vui lòng chờ." |
| Đã có yêu cầu đang chạy | "Đang có một tóm tắt được tạo — vui lòng chờ." |

## 8. Assumptions

- "Ca/ngày" là các tùy chọn kỳ có sẵn cho quản lý chọn; định nghĩa khung giờ ca cụ thể chưa chốt — OQ-1.
- Dịch vụ LLM là một provider có đầu ra có cấu trúc (tôn chỉ nêu ví dụ OpenAI/Google AI); provider cụ thể chưa chốt — OQ-3.
- Tóm tắt chỉ tạo theo yêu cầu (không tự động theo lịch); mỗi lần gọi AI tính vào hạn mức.
- Báo cáo mẫu hiển thị cùng nhóm số liệu chính của kỳ + danh sách việc cần chú ý theo quy tắc (quá hạn, ngừng phục vụ) — không có phần narrative của AI.
- Bản tóm tắt sau khi tạo có lưu để xem lại hay chỉ hiển thị tức thời chưa chốt — OQ-4.
- Kiểm tra đầu ra AI ở mức đối chiếu số liệu (các con số AI nêu phải khớp dữ liệu gốc; phát hiện sự kiện bịa → loại bỏ bản AI).

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| AI bịa sự kiện/sai số liệu | thỉnh thoảng | Quản lý mất tin vào hệ thống, quyết định trên dữ liệu sai | Kiểm tra đầu ra khớp dữ liệu gốc; nhãn "tham khảo"; fallback báo cáo mẫu; tiêu chí nghiệm thu ≥18/20 |
| Vượt chi phí API AI | thỉnh thoảng | Hết ngân sách 300.000 VNĐ giữa demo → mất tính năng | Hạn mức chi phí + chỉ tạo theo yêu cầu + báo cáo mẫu vẫn hoạt động |
| Dịch vụ AI ngoài không khả dụng/mạng chập chờn | thỉnh thoảng | Không có tóm tắt AI khi cần | Báo cáo mẫu vẫn cho đủ số liệu cốt lõi |
| Quản lý tin AI tuyệt đối (automation bias) | thỉnh thoảng | Quyết định sai mà không đối chiếu dữ liệu gốc | Nhãn tham khảo cố định; AI không có quyền ghi; cảnh báo quá hạn vẫn chạy quy tắc riêng |
| Dữ liệu giả lập ít sự kiện | thỉnh thoảng | Tóm tắt nghèo nàn, demo kém ấn tượng | Kịch bản giả lập có ca đỉnh; ghi rõ giới hạn xác thực |

## 10. Success Criteria (preliminary)

- ≥18/20 tình huống thử nghiệm: đúng số liệu, không thêm sự kiện không có trong dữ liệu, nêu đúng việc cần chú ý (tiêu chí tôn chỉ).
- 100% ca API lỗi hoặc hết hạn mức rơi về báo cáo mẫu (tiêu chí tôn chỉ).
- 100% bản hiển thị kèm thời điểm dữ liệu và nhãn "tham khảo"/"báo cáo mẫu".
- 0 lần AI tự ghi/sửa dữ liệu nghiệp vụ (bao gồm trạng thái phòng).

## 11. Open Questions

- [ ] OQ-1: Khung giờ "ca" để tóm tắt định nghĩa thế nào — ca cố định theo giờ (vd sáng/chiều/tối) hay quản lý chọn khoảng thời gian tùy ý?
- [ ] OQ-2: Hạn mức AI cụ thể là gì — số lần tạo tối đa/ngày, ngưỡng chi phí cắt, hay cả hai? Giá trị bao nhiêu?
- [ ] OQ-3: Chọn dịch vụ LLM nào cho demo (OpenAI, Google AI, hay provider khác có đầu ra có cấu trúc)?
- [ ] OQ-4: Bản tóm tắt đã tạo có được lưu để xem lại trong ngày, hay chỉ hiển thị tức thời?
- [ ] OQ-5: Thời gian chờ tối đa khi gọi dịch vụ AI trước khi rơi về báo cáo mẫu là bao nhiêu giây?

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd ai-ops-summary` — capture user perspective
- `/brd ai-ops-summary` — business case
- `/prd-epic ai-ops-summary` — product scope
