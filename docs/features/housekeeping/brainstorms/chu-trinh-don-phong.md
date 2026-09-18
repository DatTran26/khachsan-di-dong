---
type: brainstorm
feature: housekeeping
status: draft
updated: 2026-09-15
links:
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# Housekeeping — Chu trình dọn phòng

## 1. Idea Seed

Công việc dọn phòng: lễ tân trả phòng → phòng chuyển "cần dọn" → hệ thống tự phân công theo thời gian phòng trả, chia đều cho số nhân viên buồng phòng đang trực → nhân viên nhận việc và báo hoàn tất → quản lý xác nhận phòng "sẵn sàng" → dashboard cập nhật. Công việc quá 60 phút chưa hoàn tất được cảnh báo bằng quy tắc, không phụ thuộc AI.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: trạng thái lưu trú, vệ sinh và bảo trì được theo dõi riêng để tránh nhầm lẫn; mọi thay đổi kiểm tra quyền và ghi nhật ký ở máy chủ; chỉ nhận phòng khi phòng trống, đã sạch và không ngừng phục vụ. Housekeeping là luồng vận hành lõi của sản phẩm (Sprint 2).

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Nhân viên buồng phòng | Nhận việc qua điện thoại/giấy, không biết việc nào của mình, dễ sót hoặc trùng | Có việc được giao tự động, thao tác nhanh trên điện thoại ngay tại phòng |
| Quản lý | Không biết phòng nào đã dọn xong thật; phòng sạch "bị kẹt" không bán lại kịp | Xác nhận chất lượng trước khi phòng mở bán lại; thấy việc quá hạn để can thiệp |
| Lễ tân | Phải gọi điện hỏi phòng đã sạch chưa trước khi nhận khách | Thấy ngay phòng nào "sẵn sàng" theo thời gian thực |

## 4. Capabilities Breakdown

### P0 — must have

- Tự tạo công việc dọn khi có sự kiện trả phòng; phòng chuyển "cần dọn".
- Tự phân công việc cho nhân viên buồng phòng đang trực, chia đều theo thời gian phòng trả.
- Nhân viên nhận việc / báo hoàn tất trên mobile; từ chối thì hệ thống giao lại.
- Quản lý xác nhận "sẵn sàng" hoặc trả lại việc kèm ghi chú.
- Trạng thái vệ sinh phòng + trạng thái công việc đồng bộ realtime giữa các thiết bị.
- Cảnh báo công việc quá hạn 60 phút bằng quy tắc (không qua AI).

### P1 — should have

- Quản lý phân công lại thủ công việc đang mở cho nhân viên trực khác.
- Lọc danh sách công việc theo nhân viên / trạng thái / phòng.

### P2 — nice to have

- Thống kê hiệu suất dọn (thời gian trung bình, số việc mỗi nhân viên, tỷ lệ bị trả lại).
- Ngưỡng quá hạn riêng theo loại phòng.

## 5. Core Flows (Happy Path)

### 5.1 Chu trình dọn phòng chuẩn

1) Lễ tân xác nhận trả phòng (sự kiện từ feature nhận/trả phòng).
2) Hệ thống tạo công việc dọn mới; trục vệ sinh của phòng chuyển sang "cần dọn"; ghi nhật ký máy chủ.
3) Hệ thống giao việc cho nhân viên buồng phòng đang trực có ít việc đang mở nhất; nhân viên nhận thông báo trong app.
4) Nhân viên bấm nhận việc → công việc "đang làm", phòng "đang dọn".
5) Nhân viên dọn xong, báo hoàn tất → công việc "chờ xác nhận", phòng "chờ kiểm tra"; quản lý nhận thông báo.
6) Quản lý xác nhận → công việc "hoàn tất", phòng "sạch".
7) Nếu phòng đang trống và đang phục vụ → hiển thị "sẵn sàng"; dashboard cập nhật trên mọi thiết bị.

```
LỄ TÂN            HỆ THỐNG                      NHÂN VIÊN BP            QUẢN LÝ
   │                  │                             │                     │
   │ xác nhận         │                             │                     │
   │ trả phòng        │                             │                     │
   │─────────────────▶│ tạo công việc dọn           │                     │
   │                  │ phòng → "cần dọn"           │                     │
   │                  │ ghi nhật ký                 │                     │
   │                  │                             │                     │
   │                  │ giao cho NV trực            │ thông báo việc mới  │
   │                  │ ít việc mở nhất             │                     │
   │                  │────────────────────────────▶│                     │
   │                  │                             │ bấm nhận việc       │
   │                  │◀────────────────────────────│                     │
   │                  │ việc → "đang làm"           │                     │
   │                  │ phòng → "đang dọn"          │                     │
   │                  │                             │                     │
   │                  │                             │ dọn xong,           │
   │                  │                             │ báo hoàn tất        │
   │                  │◀────────────────────────────│                     │
   │                  │ việc → "chờ xác nhận"       │                     │
   │                  │ phòng → "chờ kiểm tra"      │                     │
   │                  │ thông báo quản lý           │                     │
   │                  │                             │                     │
   │                  │                             │                     │ xác nhận
   │                  │◀─────────────────────────────────────────────────│
   │                  │ việc → "hoàn tất"           │                     │
   │                  │ phòng → "sạch"              │                     │
   │                  │ trống + sạch + phục vụ      │                     │
   │                  │ → hiển thị "sẵn sàng"       │                     │
   ▼                  ▼                             ▼                     ▼
              Dashboard cập nhật realtime tới mọi thiết bị đang mở
```

### 5.2 Công việc quá hạn

1) Công việc được tạo lúc phòng trả (mốc T0).
2) Khi đồng hồ hệ thống vượt T0 + 60 phút mà công việc chưa "hoàn tất" → đánh cờ "quá hạn".
3) Hệ thống cảnh báo cho quản lý (dashboard) và nhân viên phụ trách (trong app).
4) Cờ "quá hạn" tự gỡ khi công việc chuyển "hoàn tất".

### 5.3 Quản lý trả lại việc chưa đạt

1) Nhân viên báo hoàn tất → công việc "chờ xác nhận", phòng "chờ kiểm tra".
2) Quản lý kiểm tra, thấy chưa đạt → bấm trả lại, bắt buộc nhập ghi chú.
3) Công việc quay về "đang làm" kèm ghi chú cho nhân viên; phòng quay về "đang dọn".
4) Nhân viên dọn lại, báo hoàn tất lần nữa → vòng xác nhận lặp lại.

### 5.4 Không có nhân viên đang trực / nhân viên từ chối việc

1) Có việc mới nhưng không có nhân viên buồng phòng nào đang trực → công việc ở "chờ giao", hệ thống cảnh báo quản lý; khi có người vào trực → tự giao theo quy tắc chia đều.
2) Nhân viên từ chối việc được giao → hệ thống giao lại cho người trực ít việc mở kế tiếp; mỗi lần giao lại được ghi nhật ký. Nếu hết người để giao → công việc về "chờ giao" + cảnh báo quản lý.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Tạo việc sau trả phòng | Có nhân viên buồng phòng đang trực? | Giao cho người ít việc đang mở nhất | Việc "chờ giao" + cảnh báo quản lý |
| D2 | Nhân viên phản hồi việc được giao | Nhân viên bấm nhận? | Việc "đang làm", phòng "đang dọn" | Giao lại người trực kế tiếp; hết người → "chờ giao" + cảnh báo |
| D3 | Theo dõi thời gian | Việc đã quá 60 phút kể từ tạo mà chưa hoàn tất? | Đánh cờ "quá hạn" + cảnh báo quản lý và nhân viên phụ trách | Không làm gì |
| D4 | Quản lý kiểm tra | Quản lý xác nhận đạt? | Việc "hoàn tất", phòng "sạch" | Trả lại: bắt buộc ghi chú, việc về "đang làm", phòng về "đang dọn" |
| D5 | Hiển thị sẵn sàng | Phòng trống + sạch + đang phục vụ? | Hiển thị "sẵn sàng" trên dashboard | Không hiển thị "sẵn sàng" |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| Phòng đang ở | Cần dọn | Lễ tân xác nhận trả phòng | Hệ thống tạo việc + đổi trục vệ sinh | Việc "chờ giao"/"đã giao", phòng "cần dọn" |
| Việc chờ giao | Đã giao | Có ≥1 nhân viên đang trực | Tự giao người ít việc mở nhất | Nhân viên nhận thông báo |
| Việc đã giao | Đang làm | Nhân viên bấm nhận | Đổi trạng thái việc + phòng | Phòng "đang dọn" |
| Việc đã giao | Đã giao (người khác) | Nhân viên từ chối hoặc quản lý phân công lại | Giao lại, ghi nhật ký | Người mới nhận thông báo |
| Việc đang làm | Chờ xác nhận | Nhân viên báo hoàn tất | Đổi trạng thái + thông báo quản lý | Phòng "chờ kiểm tra" |
| Việc chờ xác nhận | Hoàn tất | Quản lý xác nhận | Đổi trạng thái | Phòng "sạch", có thể "sẵn sàng" |
| Việc chờ xác nhận | Đang làm | Quản lý trả lại + ghi chú | Đổi trạng thái + gửi ghi chú | Phòng "đang dọn" |
| Việc đang mở (mọi trạng thái trừ hoàn tất) | +cờ quá hạn | Quá 60 phút kể từ tạo | Bắn cảnh báo quy tắc | Cờ "quá hạn" hiển thị dashboard |

### 6.3 State Transitions

```
Phòng — trục vệ sinh:
cần dọn → đang dọn → chờ kiểm tra → sạch
                          ↘ (quản lý trả lại) → đang dọn

Công việc dọn:
chờ giao → đã giao → đang làm → chờ xác nhận → hoàn tất
              ↘ từ chối → đã giao (người khác)
                          ↘ trả lại → đang làm
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Phòng (vệ sinh) | cần dọn | đang dọn | Nhân viên nhận việc | không |
| Phòng (vệ sinh) | đang dọn | chờ kiểm tra | Nhân viên báo hoàn tất | không |
| Phòng (vệ sinh) | chờ kiểm tra | sạch | Quản lý xác nhận | không |
| Phòng (vệ sinh) | chờ kiểm tra | đang dọn | Quản lý trả lại | có |
| Phòng (vệ sinh) | sạch | cần dọn | Trả phòng lần sau / khách dùng xong | có (chu kỳ mới) |
| Công việc | chờ giao | đã giao | Hệ thống giao tự động | không |
| Công việc | đã giao | đã giao | Từ chối / phân công lại | có (đổi người) |
| Công việc | đã giao | đang làm | Nhân viên nhận | không |
| Công việc | đang làm | chờ xác nhận | Báo hoàn tất | không |
| Công việc | chờ xác nhận | hoàn tất | Quản lý xác nhận | không (kết thúc) |
| Công việc | chờ xác nhận | đang làm | Quản lý trả lại | có |

*Cờ "quá hạn" là thuộc tính suy ra từ thời gian, không phải trạng thái riêng.*

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Nhân viên mất mạng khi báo hoàn tất | Việc vẫn "đang làm"; thao tác chưa lưu | Kết nối lại → tải trạng thái mới, nhân viên báo lại | Không có |
| 2 nhân viên/thiết bị cùng nhận 1 việc | Người nhận đầu tiên giữ việc | Người sau nhận thông báo "đã có người nhận" + tải lại danh sách | Không có |
| Quản lý trả lại trong lúc nhân viên đang sửa/báo | Việc về "đang làm" kèm ghi chú | Nhân viên thấy ghi chú khi tải lại | Không có |
| Nhân viên hết ca khi việc đang làm | Việc vẫn gán người cũ, trạng thái giữ nguyên | Quản lý phân công lại thủ công (P1) | Không có |
| Nhiều phòng trả cùng lúc (giờ cao điểm) | Hàng loạt việc được tạo | Tự giao lần lượt theo giờ trả, chia đều | Không có |

### 6.5 Other Edge Cases

- Nhân viên báo hoàn tất nhầm phòng: thao tác chỉ áp cho việc của chính mình đang "đang làm"; việc không thuộc quyền → bị từ chối.
- Phòng vừa "sạch" lập tức được nhận khách: cho phép — "sẵn sàng" đúng nghĩa là có thể bán lại ngay.
- Quản lý vắng mặt lâu: việc "chờ xác nhận" không tính vào ngưỡng quá hạn 60 phút (quá hạn đo tới lúc nhân viên báo hoàn tất), nhưng vẫn hiển thị nổi bật trên dashboard — xem OQ-3.
- Nhân viên báo hoàn tất rồi phát hiện sót việc trước khi quản lý xác nhận: nhân viên chủ động báo lại / quản lý trả lại — MVP dùng nhánh "trả lại" của quản lý.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Ghi chú khi trả lại | Bắt buộc, không rỗng, tối đa 500 ký tự |
| Nhân viên được giao | Phải thuộc danh sách nhân viên buồng phòng đang trực |
| Thao tác nhận/báo hoàn tất | Chỉ nhân viên đang được giao việc đó, đúng trạng thái hiện tại |
| Thao tác xác nhận/trả lại | Chỉ vai trò quản lý |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Ngưỡng quá hạn việc dọn | 60 phút | Tính từ lúc tạo việc (giờ trả phòng) đến lúc nhân viên báo hoàn tất | Đánh cờ "quá hạn" + cảnh báo quản lý và nhân viên phụ trách |
| Số lần giao lại 1 việc | Không giới hạn | — | Mỗi lần giao lại đều ghi nhật ký |
| Thời gian hiển thị cập nhật | ≤ 3 giây | Từ lúc máy chủ lưu thành công | Mục tiêu nghiệm thu ≥95% lượt (tôn chỉ) |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| 2 người cùng nhận 1 việc | "Công việc này đã có người khác nhận." | E-? |
| Mất mạng khi thao tác | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | E-? |
| Trả lại thiếu ghi chú | "Vui lòng nhập ghi chú khi trả lại công việc." | E-? |
| Thao tác sai trạng thái | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." | E-? |

#### Success messages

| Tình huống | Wording |
|---|---|
| Nhân viên nhận việc | "Đã nhận việc dọn phòng {số phòng}." |
| Nhân viên báo hoàn tất | "Đã báo hoàn tất — chờ quản lý xác nhận." |
| Quản lý xác nhận | "Phòng {số phòng} đã sẵn sàng." |
| Quản lý trả lại | "Đã trả lại công việc phòng {số phòng} kèm ghi chú." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Được giao việc mới | "Bạn được giao việc dọn phòng {số phòng}." |
| Việc quá hạn | "Công việc phòng {số phòng} đã quá 60 phút chưa hoàn tất." |
| Không có ai trực | "Chưa có nhân viên buồng phòng đang trực — công việc đang chờ giao." |
| Việc bị trả lại | "Công việc phòng {số phòng} bị trả lại: {ghi chú}." |

## 8. Assumptions

- "Đang trực" = nhân viên buồng phòng có trong danh sách trực do hệ thống giữ (MVP: dữ liệu giả lập / quản lý đánh dấu) — cần xác nhận nguồn danh sách, xem OQ-1.
- "Chia đều" = giao cho người có ít việc đang mở nhất; nếu hòa nhau → người lâu nhất chưa được giao việc.
- Mọi phòng dùng chung ngưỡng quá hạn 60 phút, không theo loại phòng.
- Thông báo việc mới/cảnh báo đi qua kênh realtime trong app (đồng bộ theo tôn chỉ), không gửi SMS/push ra ngoài.
- Việc đang "chờ xác nhận" không tính vào ngưỡng quá hạn (quá hạn đo tới lúc nhân viên báo hoàn tất).

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Nhân viên bỏ qua/không đọc thông báo việc mới | thường | Việc treo, phòng sạch chậm, mất cơ hội bán lại | Cảnh báo quá hạn 60 phút + quản lý thấy trên dashboard |
| Quản lý bận/vắng → không xác nhận kịp | thỉnh thoảng | Phòng sạch nhưng chưa "sẵn sàng", lễ tân không dám nhận khách | Danh sách "chờ kiểm tra" nổi bật trên dashboard (OQ-3 cân nhắc ngưỡng nhắc) |
| Chia đều theo số việc không tính vị trí tầng/phòng xa nhau | thỉnh thoảng | Nhân viên chạy xa, thời gian dọn thực tế dài | MVP chấp nhận; P2 thống kê để quản lý điều chỉnh |
| Dữ liệu giả lập không phản ánh giờ cao điểm trả phòng dồn | thỉnh thoảng | Demo đẹp nhưng thực tế nghẽn | Kịch bản giả lập có ca đỉnh; giới hạn xác thực ghi rõ |

## 10. Success Criteria (preliminary)

- 100% sự kiện trả phòng sinh công việc dọn và được giao (hoặc cảnh báo thiếu người trực) trong ≤ 1 phút.
- ≥ 95% thay đổi trạng thái hiển thị trên thiết bị khác trong ≤ 3 giây (theo tiêu chí nghiệm thu tôn chỉ).
- 0 phòng đạt trạng thái "sẵn sàng" khi chưa qua xác nhận của quản lý.
- Thời gian trung bình từ trả phòng đến "sẵn sàng" đo được trên dashboard để làm baseline.

## 11. Open Questions

- [ ] OQ-1: Danh sách "nhân viên buồng phòng đang trực" lấy từ đâu trong MVP — giả lập cố định, hay quản lý đánh dấu theo ca?
- [ ] OQ-2: Cảnh báo quá hạn phát 1 lần khi vượt ngưỡng, hay lặp lại định kỳ (vd mỗi 15 phút) tới khi hoàn tất?
- [ ] OQ-3: Việc "chờ xác nhận" quá lâu (quản lý không phản hồi) có cần ngưỡng nhắc riêng không? Bao nhiêu phút?

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd housekeeping` — capture user perspective
- `/brd housekeeping` — business case
- `/prd-epic housekeeping` — product scope
