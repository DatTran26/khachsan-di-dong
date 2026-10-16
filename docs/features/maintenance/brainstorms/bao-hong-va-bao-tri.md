---
type: brainstorm
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# Maintenance — Báo hỏng & chu trình bảo trì

## 1. Idea Seed

Bất kỳ vai trò nào phát hiện hỏng hóc đều báo hỏng kèm phòng + mô tả (+ vị trí/hạng mục nếu có); phòng tự chuyển "ngừng phục vụ" trên trục bảo trì riêng để `check-in-out` không nhận nhầm; nhân viên bảo trì nhận việc từ danh sách chung, cập nhật tiến độ tại hiện trường, báo sửa xong → phòng mở lại phục vụ khi không còn việc bảo trì đang mở; mọi thay đổi lan realtime và ghi nhật ký máy chủ. Lễ tân/quản lý có thể đặt/gỡ "ngừng phục vụ" thủ công. Việc bảo trì quá hạn được cảnh báo bằng quy tắc (ngưỡng chưa chốt — OQ-1).

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: trạng thái lưu trú, vệ sinh và bảo trì theo dõi riêng để tránh nhầm lẫn; chỉ nhận phòng khi phòng trống + đã sạch + không ngừng phục vụ; mọi thay đổi kiểm tra quyền và ghi nhật ký ở máy chủ. `maintenance` nằm Sprint 2 (22/09–05/10): "công việc buồng phòng/báo hỏng; nhật ký, đồng bộ". Phụ thuộc `room-catalog` (danh mục phòng) và `auth-roles` (vai trò); nguồn hiển thị cho `room-dashboard` (phòng ngừng phục vụ, việc quá hạn) ở Sprint 3.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Nhân viên bảo trì *(vai trò gộp "buồng phòng–bảo trì" trong MVP — theo project-profile/auth-roles)* | Báo hỏng đến bằng miệng/điện thoại, thiếu phòng/vị trí cụ thể; không cập nhật được tiến độ cho quầy | Danh sách việc bảo trì rõ phòng + mô tả; nhận việc và báo xong ngay trên mobile tại hiện trường |
| Nhân viên buồng phòng / lễ tân / quản lý (người báo hỏng) | Phát hiện hỏng nhưng phải tìm đúng người để báo; không biết báo xong ai đang xử lý | Báo hỏng nhanh với phòng + mô tả; theo dõi được trạng thái xử lý của báo hỏng mình đã gửi |
| Quản lý | Phòng hỏng vẫn bị lễ tân nhận khách nhầm; không biết việc sửa nào đang trễ | Phòng hỏng tự "ngừng phục vụ" chặn nhận khách; thấy việc bảo trì đang mở/quá hạn để điều phối |
| Lễ tân | Không chắc phòng nào đang sửa, dễ nhận khách vào phòng chưa an toàn | Trạng thái "ngừng phục vụ" hiển thị realtime và bị chặn khi nhận phòng |

## 4. Capabilities Breakdown

### P0 — must have

- Báo hỏng kèm phòng + mô tả từ mọi vai trò đã đăng nhập (tùy chọn vị trí/hạng mục trong phòng).
- Phòng tự chuyển "ngừng phục vụ" trên trục bảo trì khi có việc bảo trì mở; `check-in-out` bị chặn nhận phòng này (ràng buộc chéo, không trộn 3 trục).
- Danh sách việc bảo trì cho nhân viên bảo trì; nhân viên tự nhận việc → "đang sửa"; báo sửa xong → việc "hoàn tất".
- Phòng tự mở lại phục vụ khi không còn việc bảo trì đang mở (bình thường hóa trục bảo trì).
- Trạng thái bảo trì phòng + trạng thái việc đồng bộ realtime giữa các thiết bị; mọi thay đổi ghi nhật ký máy chủ.

### P1 — should have

- Lễ tân/quản lý đặt/gỡ "ngừng phục vụ" thủ công (không qua việc sửa, vd ngừng vì lý do vận hành).
- Hủy báo hỏng báo nhầm (người báo hoặc quản lý, khi việc chưa được nhận).
- Quản lý/lễ tân chỉ định việc cho nhân viên bảo trì cụ thể; lọc danh sách việc theo trạng thái/phòng/người xử lý.
- Cảnh báo việc bảo trì quá hạn bằng quy tắc (ngưỡng theo OQ-1).

### P2 — nice to have

- Mức độ ưu tiên cho báo hỏng (gấp/bình thường); sắp xếp danh sách theo ưu tiên.
- Ảnh hiện trường đính kèm báo hỏng.
- Lịch bảo trì định kỳ; kho vật tư; chi phí sửa chữa (ngoài phạm vi MVP theo PRD).

## 5. Core Flows (Happy Path)

### 5.1 Báo hỏng → sửa xong → mở lại phục vụ

1) Một vai trò bất kỳ (vd nhân viên buồng phòng đang dọn) phát hiện hỏng → chọn phòng → nhập mô tả (bắt buộc) + vị trí/hạng mục (tùy chọn) → gửi báo hỏng.
2) Hệ thống tạo việc bảo trì ở trạng thái "chờ nhận"; trục bảo trì của phòng chuyển "ngừng phục vụ"; ghi nhật ký máy chủ.
3) `check-in-out` chặn nhận khách vào phòng này (dù trống + sạch); thay đổi lan realtime tới mọi thiết bị.
4) Nhân viên bảo trì thấy việc trong danh sách "chờ nhận" → bấm nhận → việc "đang sửa", gắn tên người xử lý.
5) Sửa xong → bấm báo hoàn tất → việc "hoàn tất" (đóng).
6) Nếu phòng không còn việc bảo trì đang mở nào khác → trục bảo trì về "bình thường" — phòng đủ điều kiện phục vụ trở lại (trống + sạch + phục vụ → "sẵn sàng").

```
NGƯỜI BÁO          HỆ THỐNG                     NV BẢO TRÌ              LỄ TÂN / CHECK-IN-OUT
   │                  │                             │                         │
   │ báo hỏng         │                             │                         │
   │ (phòng+mô tả)    │                             │                         │
   │─────────────────▶│ tạo việc "chờ nhận"         │                         │
   │                  │ phòng → "ngừng phục vụ"     │                         │
   │                  │ ghi nhật ký                 │                         │
   │                  │──────────────────────────────────────────────────────▶│
   │                  │                             │                    chặn nhận khách
   │                  │ việc mới trong danh sách    │                         │
   │                  │────────────────────────────▶│                         │
   │                  │                             │ bấm nhận việc           │
   │                  │◀────────────────────────────│                         │
   │                  │ việc → "đang sửa"           │                         │
   │                  │                             │ sửa xong, báo hoàn tất  │
   │                  │◀────────────────────────────│                         │
   │                  │ việc → "hoàn tất"           │                         │
   │                  │ còn việc mở khác? ──NO──▶ phòng → "bình thường"       │
   │                  │                             │                    phòng mở lại
   │                  │──────────────────────────────────────────────────────▶│
   ▼                  ▼                             ▼                         ▼
              Dashboard cập nhật realtime tới mọi thiết bị đang mở
```

### 5.2 Báo hỏng trên phòng đang có khách ở

1) Khách đang ở báo/lễ tân ghi nhận hỏng hóc → báo hỏng bình thường (phòng + mô tả).
2) Phòng vẫn chuyển "ngừng phục vụ" trên trục bảo trì — nghĩa là sau khi khách trả, phòng không thể nhận khách mới cho tới khi sửa xong; **không ảnh hưởng khách đang ở**.
3) Việc bảo trì "chờ nhận"; xử lý ngay giữa kỳ lưu trú hay chờ khách trả là quyết định vận hành (OQ-3).

### 5.3 Nhiều báo hỏng trên cùng một phòng

1) Phòng A đã có việc "đang sửa" → vẫn cho phép báo hỏng mới (tạo việc "chờ nhận" thứ hai), kèm cảnh báo nhẹ "phòng đang có việc bảo trì mở" để tránh trùng lặp vô tình.
2) Phòng ở "ngừng phục vụ" cho tới khi **không còn việc bảo trì nào đang mở** (mọi việc đều "hoàn tất" hoặc "đã hủy").

### 5.4 Hủy báo hỏng báo nhầm

1) Người báo (hoặc quản lý) mở việc "chờ nhận" → chọn hủy → nhập lý do ngắn (tùy chọn).
2) Việc chuyển "đã hủy", ghi nhật ký; nếu phòng không còn việc mở → trục bảo trì về "bình thường".
3) Việc đã "đang sửa" không tự hủy — phải do quản lý xử lý (tránh mất vết công việc đang làm).

### 5.5 Đặt/gỡ "ngừng phục vụ" thủ công

1) Lễ tân/quản lý chọn phòng → "Ngừng phục vụ" → nhập lý do → phòng chuyển "ngừng phục vụ" (đặt tay, không kèm việc).
2) `check-in-out` chặn nhận khách; ghi nhật ký.
3) "Mở lại phục vụ" → chỉ được khi phòng không còn việc bảo trì đang mở; nếu đang có việc mở → báo phải xử lý việc trước.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Báo hỏng | Mô tả hợp lệ (không rỗng, ≤500 ký tự)? | Tạo việc "chờ nhận", phòng "ngừng phục vụ" | Từ chối, yêu cầu nhập mô tả |
| D2 | Báo hỏng | Phòng đã có việc bảo trì đang mở? | Vẫn tạo việc mới + cảnh báo nhẹ "đang có việc mở" | Tạo việc bình thường |
| D3 | Nhận việc | Việc còn ở "chờ nhận"? | Người nhận đầu tiên giữ việc → "đang sửa" | Người sau nhận báo "đã có người nhận" + tải lại |
| D4 | Hoàn tất việc | Phòng còn việc bảo trì mở khác? | Giữ "ngừng phục vụ" | Trục bảo trì về "bình thường" |
| D5 | Gỡ ngừng phục vụ thủ công | Phòng còn việc bảo trì đang mở? | Từ chối gỡ — phải hoàn tất/hủy việc trước | Cho gỡ → "bình thường" |
| D6 | Hủy việc | Việc đang "chờ nhận" và người hủy là người báo hoặc quản lý? | Cho hủy → "đã hủy" | Từ chối (việc đã nhận thì chỉ quản lý xử lý) |
| D7 | Cảnh báo quá hạn | Việc mở vượt ngưỡng OQ-1 mà chưa "hoàn tất"? | Đánh cờ "quá hạn" + cảnh báo quản lý/nhân viên | Không làm gì |
| D8 | Nhận khách (check-in-out) | Phòng "ngừng phục vụ"? | Chặn nhận khách | Cho nhận nếu trống + sạch |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| Phòng bình thường | Ngừng phục vụ | Báo hỏng hợp lệ (D1) | Tạo việc + đổi trục bảo trì | Việc "chờ nhận", chặn check-in |
| Phòng bình thường | Ngừng phục vụ | Lễ tân/QL đặt tay + lý do | Đổi trục bảo trì, không tạo việc | Chặn check-in, có nhật ký |
| Việc chờ nhận | Đang sửa | NV bảo trì nhận (D3) | Đổi trạng thái + gán người xử lý | Người khác thấy việc đã có chủ |
| Việc chờ nhận | Đã hủy | Người báo/QL hủy (D6) | Đổi trạng thái + ghi lý do | Phòng mở lại nếu hết việc mở |
| Việc đang sửa | Hoàn tất | NV bảo trì báo xong | Đổi trạng thái, kiểm tra D4 | Việc đóng; phòng mở lại nếu hết việc mở |
| Phòng ngừng phục vụ | Bình thường | Hết việc mở (tự động) hoặc gỡ tay hợp lệ (D5) | Đổi trục bảo trì | Đủ điều kiện "sẵn sàng" nếu trống + sạch |
| Việc đang mở (chờ nhận/đang sửa) | +cờ quá hạn | Vượt ngưỡng OQ-1 | Cảnh báo quy tắc | Hiển thị trên dashboard |

### 6.3 State Transitions

```
Phòng — trục bảo trì (riêng, không trộn lưu trú/vệ sinh):
bình thường ⇄ ngừng phục vụ
  ↑ bình thường → ngừng phục vụ: có việc bảo trì mở / đặt tay
  ↑ ngừng phục vụ → bình thường: hết việc mở (tự động) / gỡ tay hợp lệ

Việc bảo trì:
chờ nhận → đang sửa → hoàn tất (đóng)
    ↘ đã hủy (người báo/QL, khi chưa nhận)
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Phòng (bảo trì) | bình thường | ngừng phục vụ | Báo hỏng hợp lệ / đặt tay | có |
| Phòng (bảo trì) | ngừng phục vụ | bình thường | Hết việc mở / gỡ tay hợp lệ | có (chu kỳ mới) |
| Việc bảo trì | chờ nhận | đang sửa | NV bảo trì nhận | không |
| Việc bảo trì | chờ nhận | đã hủy | Người báo/QL hủy | không (kết thúc) |
| Việc bảo trì | đang sửa | hoàn tất | NV bảo trì báo xong | không (kết thúc) |

*Cờ "quá hạn" là thuộc tính suy ra từ thời gian (ngưỡng OQ-1), không phải trạng thái riêng.*

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| NV mất mạng khi báo xong | Việc vẫn "đang sửa"; thao tác chưa lưu | Kết nối lại → tải trạng thái mới, báo lại | Không có |
| 2 NV/thiết bị cùng nhận 1 việc | Người nhận đầu tiên giữ việc | Người sau nhận "đã có người nhận" + tải lại danh sách | Không có |
| 2 người cùng báo hỏng 1 phòng | Cả 2 việc đều tồn tại (D2 cho phép kèm cảnh báo) | QL/người báo hủy việc trùng | Không có |
| NV hết ca khi việc đang sửa | Việc vẫn gán người cũ, trạng thái giữ nguyên | Quản lý chỉ định lại thủ công (P1) | Không có |
| Mất mạng khi báo hỏng | Báo hỏng chưa lưu | Có mạng → gửi lại (mất mạng khóa ghi — realtime-sync) | Không có |

### 6.5 Other Edge Cases

- Báo hỏng phòng đang ở: cho phép; "ngừng phục vụ" chỉ chặn nhận khách mới, không đá khách đang ở (xử lý khi nào — OQ-3).
- Báo xong nhầm việc của người khác: thao tác chỉ áp cho việc do chính mình đang "đang sửa"; việc không thuộc quyền → từ chối.
- Phòng "ngừng phục vụ" đặt tay rồi phát sinh báo hỏng: cho phép tạo việc; khi việc xong mà cờ đặt tay vẫn còn → phòng vẫn "ngừng phục vụ" tới khi được gỡ tay (nguồn ngừng khác nhau, không tự gỡ nhầm).
- NV báo xong nhầm rồi phát hiện chưa xong: việc đã "hoàn tất" không mở lại — phải tạo báo hỏng mới (giữ vết lịch sử).
- Phòng hỏng nhưng lễ tân đã lỡ xếp khách trước khi realtime kịp lan: kiểm tra phiên bản + trạng thái tại máy chủ khi nhận phòng vẫn chặn (check-in-out kiểm server-side, không tin cache máy).

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Phòng | Bắt buộc, thuộc danh mục phòng (`room-catalog`) |
| Mô tả hỏng | Bắt buộc, không rỗng, tối đa 500 ký tự |
| Vị trí/hạng mục trong phòng | Tùy chọn, tối đa 100 ký tự (vd "điều hòa", "vòi sen") |
| Lý do đặt/gỡ ngừng phục vụ tay | Bắt buộc khi đặt tay, không rỗng, tối đa 200 ký tự |
| Lý do hủy việc | Tùy chọn, tối đa 200 ký tự |
| Thao tác nhận/báo xong | Chỉ vai trò buồng phòng–bảo trì; báo xong chỉ trên việc do chính mình "đang sửa" |
| Thao tác đặt/gỡ ngừng tay, hủy việc | Lễ tân/quản lý (đặt/gỡ tay); người báo hoặc quản lý (hủy việc "chờ nhận") |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Ngưỡng quá hạn việc bảo trì | **OQ-1 — chưa chốt** | Tính từ lúc tạo việc | Đánh cờ "quá hạn" + cảnh báo quản lý và nhân viên phụ trách |
| Số việc bảo trì mở trên 1 phòng | Không giới hạn | — | Báo hỏng mới kèm cảnh báo nhẹ (D2) |
| Thời gian hiển thị cập nhật | ≤ 3 giây | Từ lúc máy chủ lưu thành công | Mục tiêu nghiệm thu ≥95% lượt (tôn chỉ) |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| 2 người cùng nhận 1 việc | "Công việc này đã có người khác nhận." | E-? |
| Mất mạng khi thao tác | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | E-? |
| Báo hỏng thiếu mô tả | "Vui lòng nhập mô tả hỏng hóc." | E-? |
| Thao tác sai trạng thái | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." | E-? |
| Gỡ ngừng khi còn việc mở | "Phòng còn việc bảo trì đang xử lý — hãy hoàn tất hoặc hủy việc trước." | E-? |
| Sai quyền | "Bạn không có quyền thực hiện thao tác này." | E-? |

#### Success messages

| Tình huống | Wording |
|---|---|
| Gửi báo hỏng | "Đã gửi báo hỏng phòng {số phòng} — phòng tạm ngừng phục vụ." |
| NV nhận việc | "Đã nhận việc sửa phòng {số phòng}." |
| NV báo xong | "Đã báo hoàn tất việc phòng {số phòng}." |
| Gỡ ngừng tay | "Phòng {số phòng} đã mở lại phục vụ." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Việc bảo trì mới | "Có báo hỏng mới ở phòng {số phòng}." |
| Phòng đã có việc mở | "Phòng này đang có việc bảo trì khác đang xử lý — báo hỏng vẫn được tạo." |
| Việc quá hạn | "Việc bảo trì phòng {số phòng} đã quá hạn xử lý." |
| Phòng mở lại | "Phòng {số phòng} đã hết việc bảo trì — trở lại phục vụ." |

## 8. Assumptions

- Cơ chế mặc định MVP: việc bảo trì vào **danh sách chung**, nhân viên bảo trì **tự nhận** (không phụ thuộc danh sách trực như housekeeping); chỉ định tay là P1 — xác nhận tại OQ-2.
- Báo xong → việc "hoàn tất" và phòng mở lại **ngay**, không có bước xác nhận chất lượng (PRD: "sửa xong thì phòng mở lại phục vụ" — khác housekeeping có xác nhận của quản lý).
- "Ngừng phục vụ" có 2 nguồn: do việc bảo trì (tự gỡ khi hết việc) và do đặt tay (chỉ gỡ tay); hai nguồn độc lập, không tự gỡ lẫn nhau.
- Thông báo việc mới/cảnh báo đi qua kênh realtime trong app (đồng bộ theo tôn chỉ), không SMS/push ngoài.
- Mọi vai trò đã đăng nhập đều báo hỏng được (PRD: "bất kỳ vai trò nào"); khách không dùng hệ thống — khách báo qua lễ tân/nhân viên.

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Nhân viên bảo trì không mở app → không thấy việc mới | thường | Việc hỏng treo, phòng ngừng lâu, mất cơ hội bán | Cảnh báo quá hạn (OQ-1) lên dashboard quản lý; demo kèm quy trình |
| Phòng sửa xong mở lại ngay không qua kiểm tra | thỉnh thoảng | Phòng chưa thật sự xong đã bán lại → khách khiếu nại | PRD đã chốt mở lại trực tiếp; rủi ro chấp nhận ở MVP, có nhật ký truy vết người báo xong |
| Báo hỏng trùng/spam trên cùng phòng | thỉnh thoảng | Danh sách việc nhiễu, khó theo dõi | Cảnh báo "đang có việc mở" (D2) + hủy được khi chưa nhận |
| Không ai rõ trách nhiệm khi việc "chờ nhận" lâu | thỉnh thoảng | Phòng ngừng phục vụ kéo dài | Cờ quá hạn + dashboard; P1 cho quản lý chỉ định tay |

## 10. Success Criteria (preliminary)

- 100% phòng "ngừng phục vụ" bị chặn nhận khách trong kịch bản nghiệm thu (bao gồm cả trường hợp cache thiết bị chưa kịp cập nhật).
- 100% báo hỏng có trạng thái xử lý rõ ràng (chờ nhận / đang sửa / hoàn tất / đã hủy) cho tới khi đóng.
- 100% phòng chỉ mở lại phục vụ khi không còn việc bảo trì đang mở (hoặc gỡ tay hợp lệ).
- ≥95% thay đổi trạng thái hiển thị trên thiết bị khác trong ≤3 giây (tiêu chí nghiệm thu tôn chỉ).

## 11. Open Questions

- [ ] OQ-1: Ngưỡng thời gian tính "quá hạn" cho việc bảo trì (bao nhiêu phút/giờ)? Cảnh báo phát 1 lần hay lặp lại?

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd maintenance` — capture user perspective
- `/brd maintenance` — business case
- `/prd-epic maintenance` — product scope
- `/srs maintenance` (Tầng 1 — Core spec)
