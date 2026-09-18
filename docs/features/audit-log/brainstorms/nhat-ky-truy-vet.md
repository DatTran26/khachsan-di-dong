---
type: brainstorm
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - "[[docs/_product/prd.md|Product PRD — mục 7.8]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# audit-log — Nhật ký truy vết thay đổi

## 1. Idea Seed

Mọi thay đổi trạng thái và thao tác ghi trên hệ thống tự động để lại dấu vết ở máy chủ: ai thực hiện, thuộc vai trò nào, vào lúc nào, hành động gì, trên đối tượng nào, từ giá trị nào sang giá trị nào. Quản lý mở nhật ký của một phòng hoặc theo khoảng thời gian để truy vết khi có sai lệch hay tranh chấp "ai đã đổi gì". Nhật ký cũng là nguồn sự kiện nghiệp vụ cho `ai-ops-summary` tính số liệu tổng hợp cuối ca/ngày.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: "Mọi thay đổi được kiểm tra quyền và ghi nhật ký ở máy chủ", "lưu dữ liệu trước khi phát sự kiện", và ba trục trạng thái phòng (lưu trú / vệ sinh / bảo trì) được theo dõi riêng để tránh nhầm lẫn. `audit-log` thuộc theme Giám sát & truy vết, phụ thuộc `auth-roles` (định danh người thực hiện + vai trò + sự kiện auth) và là nguồn sự kiện cho `ai-ops-summary`. Tôn chỉ xếp "nhật ký" vào kết quả Sprint 2 (22/09–05/10), cùng nhịp với các luồng vận hành.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Quản lý | Khi trạng thái phòng hoặc dữ liệu bị sai lệch, hoặc có tranh chấp giữa các ca, không có cách nào biết ai đã đổi gì lúc nào | Mở nhật ký của phòng/khoảng thời gian, đọc được chuỗi thay đổi đủ ai–khi–hành động–trước→sau mà không cần hỗ trợ kỹ thuật |
| Hệ thống | — (tác nhân tự động, không phải người dùng) | Tự sinh bản ghi khi một thao tác ghi hoàn tất, kể cả hành động do hệ thống tự thực hiện (tự tạo việc, đánh cờ quá hạn, khóa tài khoản) |
| Người vận hành (WPCTeam) | Cần dữ liệu đối soát khi demo/nghiệm thu và khi phục hồi sự cố | Nhật ký đủ tin cậy để đối chiếu với dashboard và kịch bản nghiệm thu |

*Lễ tân và nv buồng phòng–bảo trì không có màn hình trong feature này — họ là chủ thể được ghi trong nhật ký. Khách chỉ là đối tượng dữ liệu (tên giả lập có thể xuất hiện trong giá trị bản ghi). Quyền xem nhật ký đã chốt ở `auth-roles`: chỉ quản lý.*

## 4. Capabilities Breakdown

### P0 — must have

- Tự động ghi mọi thay đổi trạng thái phòng — mỗi bản ghi chỉ rõ trục bị đổi (lưu trú / vệ sinh / bảo trì) kèm giá trị trước → sau; không gộp ba trục thành một "trạng thái chung".
- Tự động ghi mọi thao tác ghi nghiệp vụ khác (tạo/sửa phòng, giao/nhận/hoàn tất việc, báo hỏng, quản lý tài khoản...) và các sự kiện auth theo `auth-roles`.
- Bản ghi luôn đủ: thời điểm máy chủ lưu, người thực hiện + vai trò (hoặc "hệ thống"), hành động, đối tượng, thay đổi trước → sau.
- Nhật ký bất biến: không có thao tác sửa/xóa bản ghi trong ứng dụng; giữ toàn bộ thời gian MVP, không tự xóa.
- Quản lý xem nhật ký theo phòng; lọc theo khoảng thời gian và vai trò/người thao tác.
- Bản ghi đủ cấu trúc để `ai-ops-summary` tổng hợp theo kỳ (đếm và nhóm sự kiện theo loại/phòng/khoảng thời gian).

### P1 — should have

- Màn nhật ký chung toàn hệ thống (không gắn một phòng) — mở rộng màn "xem nhật ký" đã chốt ở `auth-roles` — lọc thêm theo loại hành động, trục trạng thái, loại đối tượng.
- Tải nhật ký theo phần để màn không nặng khi nhật ký lớn dần (khung mặc định + giới hạn — OQ-1).

### P2 — nice to have (ngoài v1)

- Bấm từ dòng nhật ký mở thẳng đối tượng liên quan (phòng/công việc).
- Export nhật ký, chính sách lưu trữ dài hạn, cảnh báo phát sinh từ nhật ký — PRD đã xếp "chưa làm".

## 5. Core Flows (Happy Path)

### 5.1 Ghi nhật ký tự động khi có thao tác ghi

1) Người dùng thực hiện thao tác ghi (đổi trạng thái, tạo/sửa dữ liệu) trên thiết bị của mình.
2) Máy chủ kiểm tra quyền theo vai trò; không đủ quyền → từ chối, không đổi dữ liệu, không sinh bản ghi.
3) Máy chủ lưu dữ liệu cùng bản ghi nhật ký như một kết quả duy nhất — không có thay đổi nào tồn tại mà thiếu vết.
4) Thay đổi được phát realtime tới các thiết bị khác (`realtime-sync`); bản ghi nhật ký sẵn sàng để truy vết.

```
NGƯỜI DÙNG          MÁY CHỦ                          NHẬT KÝ
   │                   │                                 │
   │ thao tác ghi      │                                 │
   │──────────────────▶│ kiểm quyền theo vai trò         │
   │                   │ ── không đủ quyền ──▶ từ chối,  │
   │                   │      không đổi dữ liệu,        │
   │                   │      không ghi nhật ký         │
   │                   │                                 │
   │                   │ lưu dữ liệu + bản ghi          │
   │                   │ (ai/khi/hành động/đối tượng/   │
   │                   │  trục/trước→sau) ─────────────▶│ append-only
   │                   │                                 │
   │                   │ ghi nhật ký thất bại ──▶ thao tác
   │                   │   báo "chưa hoàn tất"          │
   │                   │                                 │
   │                   │ phát cập nhật realtime         │
   ▼                   ▼                                 ▼
        Các thiết bị khác hiển thị trạng thái mới ≤3 giây
```

### 5.2 Quản lý truy vết theo phòng

1) Có nghi vấn/tranh chấp về một phòng (vd "ai đã chuyển phòng 305 sang sạch?").
2) Quản lý mở nhật ký của phòng đó → thấy danh sách bản ghi theo thời gian, mới nhất trước.
3) Mỗi dòng cho biết: ai — vai trò nào — lúc nào — hành động gì — trục/trường nào — từ giá trị nào sang giá trị nào.
4) Quản lý thu hẹp thêm bằng lọc khoảng thời gian hoặc người thao tác nếu cần.

### 5.3 Quản lý rà soát một khoảng thời gian / một người

1) Quản lý mở màn nhật ký, đặt lọc khoảng thời gian (từ–đến) và/hoặc vai trò/người thao tác.
2) Hệ thống hiển thị các bản ghi khớp lọc, gồm cả hành động tự động do "hệ thống" thực hiện.
3) Không có bản ghi nào khớp → trạng thái rỗng rõ ràng, không báo lỗi.

### 5.4 Nhật ký làm nguồn sự kiện cho ai-ops-summary

1) Cuối ca/ngày, `ai-ops-summary` đọc các bản ghi trong kỳ để tính số liệu tổng hợp (số lượt nhận/trả, số việc tạo/hoàn tất/quá hạn, số lần ngừng phục vụ...).
2) `audit-log` chỉ đảm bảo mỗi sự kiện có đủ loại hành động, đối tượng/phòng và thời điểm để đếm và nhóm; việc tính số liệu, khử định danh và nội dung tóm tắt thuộc `ai-ops-summary`.
3) Mỗi lượt tạo tóm tắt của `ai-ops-summary` tự nó cũng là một thao tác ghi được ghi nhật ký.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Ghi nhật ký | Thao tác ghi đã kiểm quyền và lưu thành công? | Tạo bản ghi đủ trường | Không sinh bản ghi (không có thay đổi để vết) |
| D2 | Hoàn tất thao tác | Bản ghi nhật ký lưu được cùng thay đổi dữ liệu? | Thao tác hoàn tất, phát realtime | Thao tác báo "chưa hoàn tất" — không để thay đổi mồ côi thiếu vết |
| D3 | Xem nhật ký | Người xem là vai trò quản lý? | Cho xem + lọc | Từ chối phía máy chủ |
| D4 | Hiển thị theo phòng | Bản ghi gắn đối tượng phòng? | Xuất hiện trong nhật ký của phòng đó | Chỉ xuất hiện ở nhật ký chung (vd sự kiện auth) |

### 6.2 Scenario Matrix — nhóm sự kiện được ghi

| Nhóm sự kiện | Nguồn sinh (feature) | Đối tượng ghi | Thay đổi được ghi |
|---|---|---|---|
| Nhận/trả phòng | `check-in-out` | Phòng | Trục lưu trú: trước → sau (khi trả kèm trục vệ sinh → "cần dọn") |
| Vòng đời việc dọn + trục vệ sinh | `housekeeping` | Công việc + Phòng | Trạng thái việc: trước → sau; trục vệ sinh: trước → sau |
| Báo hỏng/sửa xong/mở lại phục vụ | `maintenance` | Phòng + Công việc | Trục bảo trì: trước → sau; trạng thái việc sửa |
| Danh mục phòng (tạo/sửa) | `room-catalog` | Phòng | Thuộc tính phòng trước → sau, hoặc giá trị mới khi tạo |
| Tài khoản & phiên (tạo/khóa/mở/gán vai trò/đổi MK/đăng nhập/đăng xuất/hết phiên) | `auth-roles` | Tài khoản | Theo định nghĩa `auth-roles`; KHÔNG ghi giá trị mật khẩu |
| Hành động tự động (tự tạo việc dọn, cờ quá hạn, khóa TK sau 5 lần sai, hủy phiên) | hệ thống | Phòng/Công việc/Tài khoản | Thay đổi do hệ thống sinh; người thực hiện = "hệ thống" |
| Tạo tóm tắt AI (thành công/fallback/lỗi) | `ai-ops-summary` | Kỳ tóm tắt | Kết quả lượt tạo theo `ai-ops-summary` |

*Vai trò được phép thực hiện từng hành động theo ma trận quyền của `auth-roles` — audit-log chỉ ghi lại, không quyết định quyền.*

### 6.3 State Transitions

Bản ghi nhật ký không có vòng đời trạng thái: được thêm một lần và không bao giờ thay đổi (append-only, bất biến). Đây là điểm khác biệt cốt lõi so với entity nghiệp vụ — trong ứng dụng không tồn tại thao tác "sửa" hay "xóa" nhật ký.

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Mất mạng khi người dùng đang thao tác ghi | Dữ liệu chưa lưu → chưa có bản ghi | Có mạng lại → tải trạng thái mới, thao tác lại | Không có |
| Ghi nhật ký thất bại trong lúc lưu thao tác | Không cho phép trạng thái "đổi xong mà không vết" | Thao tác báo "chưa hoàn tất", người dùng thử lại | Không để thay đổi mồ côi |
| Quản lý mất mạng khi đang tải nhật ký | Màn giữ phần đã tải (nếu có) | Có mạng lại → tải lại | Không có |
| Thao tác bị từ chối (thiếu quyền/xung đột phiên bản) | Không có thay đổi → không có bản ghi | Người dùng thấy lỗi, tải lại trạng thái | Không có |

### 6.5 Other Edge Cases

- Một thao tác đổi nhiều trục cùng lúc (vd trả phòng đổi cả lưu trú lẫn vệ sinh): sinh một bản ghi hành động, liệt kê đủ từng thay đổi theo từng trục — không gộp thành một "trạng thái chung".
- Đối tượng bị đổi tên/xóa sau đó (vd sửa số phòng): bản ghi giữ nhãn đối tượng tại thời điểm ghi — nhật ký là bản chụp lịch sử, không mất vết khi đối tượng đổi.
- Phòng chưa có thay đổi nào: nhật ký theo phòng hiển thị trạng thái rỗng, không báo lỗi.
- Giờ thiết bị lệch giờ máy chủ: thời điểm bản ghi luôn là mốc máy chủ lưu thành công — tránh tranh chấp về giờ.
- Nhật ký tích lũy lớn dần trong thời gian demo: tải theo phần + khung thời gian mặc định — xem OQ-1.
- Bản ghi có thể chứa tên khách giả lập (khi nhận phòng): hiển thị bình thường trong app; việc khử định danh khi gửi AI thuộc `ai-ops-summary`.
- Người vận hành (WPCTeam) can thiệp dữ liệu trực tiếp ngoài app: nằm ngoài phạm vi nhật ký trong app — giảm thiểu bằng sao lưu và biên bản vận hành theo tôn chỉ.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Khoảng thời gian lọc | Tùy chọn; nếu nhập thì mốc "từ" phải trước hoặc bằng mốc "đến" |
| Người thao tác | Chọn từ danh sách tài khoản hiện có, kèm lựa chọn "hệ thống" |
| Vai trò | Một trong: quản lý / lễ tân / nv buồng phòng–bảo trì / hệ thống |
| Quyền xem | Chỉ vai trò quản lý — kiểm tra ở máy chủ, không chỉ ẩn trên giao diện |
| Nội dung bản ghi | Do hệ thống tự sinh — người dùng không nhập/sửa nội dung nhật ký |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Thời gian giữ nhật ký | Toàn bộ thời gian MVP | — | Không tự xóa, không giới hạn số dòng |
| Khung thời gian mặc định khi mở màn | TBD — OQ-1 | Mỗi lần mở | — |
| Số dòng mỗi lần tải | TBD — OQ-1 | Mỗi lần tải | Tải tiếp theo yêu cầu (cuộn/"xem thêm") |
| Thao tác sửa/xóa bản ghi | 0 — không tồn tại trong app | — | — |

### 7.3 Wording samples (exact strings)

#### Dạng hiển thị một dòng nhật ký

"{giờ:phút ngày/tháng} · {họ tên} ({vai trò}) · {hành động} · {đối tượng} · {trục/trường}: {giá trị trước} → {giá trị sau}"

- Ví dụ người dùng: "14:32 05/10 · Trần B (lễ tân) · Trả phòng · P.305 · lưu trú: đang ở → trống; vệ sinh: sạch → cần dọn"
- Ví dụ hệ thống: "09:15 05/10 · hệ thống · Tạo việc dọn · P.305 · việc dọn: — → chờ giao"

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| Vai trò không được xem nhật ký | "Bạn không có quyền xem nhật ký." | E-? |
| Khoảng thời gian không hợp lệ | "Khoảng thời gian chưa hợp lệ — mốc bắt đầu phải trước hoặc bằng mốc kết thúc." | E-? |
| Mất kết nối khi tải | "Mất kết nối — chưa tải được nhật ký. Thử lại khi có mạng." | E-? |
| Ghi nhật ký thất bại khi lưu | "Thao tác chưa hoàn tất — vui lòng thử lại." | E-? |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Không có bản ghi trong phạm vi | "Chưa có thay đổi nào trong phạm vi đã chọn." |
| Dòng do hệ thống sinh | Người thực hiện hiển thị là "hệ thống" |

## 8. Assumptions

- Chỉ thao tác ghi thành công (đã lưu) mới sinh bản ghi; thao tác bị từ chối không đổi dữ liệu nên không vào nhật ký — theo luồng tôn chỉ "kiểm quyền → lưu → ghi". Sự kiện bảo mật không gắn phòng (đăng nhập, khóa TK...) vẫn được ghi theo định nghĩa `auth-roles`.
- Xem nhật ký là thao tác đọc theo yêu cầu; không yêu cầu phát realtime tới màn nhật ký (PRD chỉ chốt realtime cho thay đổi trạng thái).
- Thứ tự hiển thị mặc định: mới nhất trước — phục vụ nhu cầu "xem lại".
- Màn nhật ký nằm trên web cho quản lý (quản lý dùng web dashboard); mobile không có màn nhật ký trong v1.
- Một thao tác đổi nhiều trục sinh một bản ghi liệt kê đủ từng thay đổi.
- Can thiệp của người vận hành ngoài app không nằm trong nhật ký.

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Bản ghi bị thiếu do lỗi khi lưu | thấp | Mất vết đúng lúc tranh chấp — mất giá trị cốt lõi | Nhật ký lưu cùng thay đổi; lỗi ghi = thao tác chưa hoàn tất; đối soát trong kịch bản nghiệm thu |
| Nhật ký phình theo thời gian demo | thường | Màn tải chậm, khó đọc | Tải theo phần + khung mặc định (OQ-1); lọc theo phòng/thời gian/người |
| Quản lý là người xem duy nhất | — | Nếu chính quản lý gây sai lệch thì không ai đối chứng trong app | Giới hạn chấp nhận của MVP; người vận hành giữ sao lưu CSDL theo tôn chỉ |
| Wording bản ghi quá kỹ thuật | thỉnh thoảng | Quản lý đọc không hiểu, bỏ không dùng | Format hiển thị nghiệp vụ ở mục 7.3; kiểm chứng qua kịch bản demo |

## 10. Success Criteria (preliminary)

- 100% thay đổi trạng thái có bản ghi đủ ai/khi/trục/từ→sang (đo thành công của PRD).
- 0 thay đổi dữ liệu tồn tại mà thiếu bản ghi tương ứng khi đối soát trong nghiệm thu.
- Quản lý tự trả lời được "ai đã đổi gì trên phòng X, lúc nào" trong kịch bản tranh chấp demo, không cần hỗ trợ kỹ thuật.
- Mọi loại sự kiện nghiệp vụ trong MVP đếm/nhóm được từ nhật ký theo phòng và khoảng thời gian — đủ làm nguồn cho `ai-ops-summary`.
- 0 vai trò ngoài quản lý xem được nhật ký trong bộ kịch bản phân quyền.

## 11. Open Questions

- [ ] OQ-1: Khung thời gian mặc định khi mở màn nhật ký (vd hôm nay / ca hiện tại / 7 ngày gần nhất) và số dòng tối đa mỗi lần tải là bao nhiêu?
- [ ] OQ-2: Có cần ghi cả lượt xem nhật ký của quản lý (ai tra cứu nhật ký nào, khi nào) để tự truy vết việc truy vết không? Tạm chốt: v1 chỉ ghi thao tác ghi theo PRD.

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd audit-log` — capture user perspective
- `/brd audit-log` — business case
- `/prd-epic audit-log` — product scope
- `/srs audit-log --spec-only` — Tầng 1 core spec
