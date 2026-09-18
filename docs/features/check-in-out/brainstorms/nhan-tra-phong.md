---
type: brainstorm
feature: check-in-out
status: draft
updated: 2026-09-17
links:
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.3]]"
---

# Check-in-out — Nhận phòng / Trả phòng

## 1. Idea Seed

Nhận phòng (check-in) và trả phòng (check-out) là hai hành động vận hành lõi của lễ tân. Nhận phòng CHỈ được khi phòng trống + sạch + bình thường ("sẵn sàng") — nếu không thỏa thì bị chặn kèm lý do cụ thể; khi nhận phải ghi thông tin khách tối thiểu và tạo lượt lưu trú. Trả phòng chuyển phòng sang trống + cần dọn và phát sự kiện trả phòng để `housekeeping` tự tạo việc dọn. Mọi thao tác kiểm tra quyền, ghi nhật ký, lan realtime — thay thế quy trình "báo miệng rồi nhập lại sau".

## 2. Context

MVP 8 tuần, 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập (không dữ liệu khách thật). `check-in-out` nằm Sprint 2 theo tôn chỉ ("Nhận/trả phòng, công việc buồng phòng/báo hỏng"), phụ thuộc `room-catalog` (danh mục phòng + 3 trục trạng thái) và `auth-roles` (phân quyền). Trả phòng là nguồn sự kiện "khách checkout" cho `housekeeping`. Quản lý không thực hiện nhận/trả phòng — chỉ giám sát.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Lễ tân | Nhận khách vào phòng chưa dọn/ngừng phục vụ vì không biết trạng thái thực | Nhận phòng chỉ khi phòng sẵn sàng; hệ thống chặn + nói rõ lý do khi không được |
| Lễ tân | Trả phòng xong quên báo buồng phòng → phòng "treo" bẩn | Trả phòng một thao tác — hệ thống tự báo việc dọn |
| Quản lý | Không biết phòng nào đang có khách, ai đã nhận | Giám sát danh sách phòng đang ở + nhật ký lượt lưu trú |
| Nhân viên buồng phòng–bảo trì | Không biết khi nào có phòng cần dọn | Thấy ngay phòng cần dọn sau trả phòng (qua `housekeeping`) |

## 4. Capabilities Breakdown

### P0 — must have

- Nhận phòng: kiểm tra 3 điều kiện (trống + sạch + bình thường); thỏa → nhận, không thỏa → chặn kèm lý do cụ thể (phòng đang ở / chưa sạch / ngừng phục vụ).
- Ghi thông tin khách tối thiểu khi nhận phòng (giả định: tên khách bắt buộc + số người — xem OQ-1); tạo lượt lưu trú (phòng, khách, mốc nhận).
- Trả phòng: phòng đang ở → trống + vệ sinh "cần dọn"; phát sự kiện trả phòng cho `housekeeping` tự tạo việc dọn; đóng lượt lưu trú (mốc trả).
- Xem danh sách phòng đang ở (để chọn phòng trả) và khách đang lưu trú theo phòng.
- Mọi thao tác kiểm tra quyền server (chỉ lễ tân), ghi nhật ký, lan realtime ≤3s.

### P1 — should have

- Hủy nhận phòng nhầm trong cửa sổ ngắn sau khi nhận (trước khi phát sinh hoạt động khác) — lượt lưu trú hủy vẫn giữ vết trong nhật ký.
- Ghi chú tự do khi nhận phòng (vd yêu cầu của khách) — văn bản tối đa giới hạn.
- Ngày dự kiến trả khi nhận phòng (tùy chọn, chỉ để hiển thị — không xử lý quá hạn; quá hạn thuộc `room-dashboard`).

### P2 — nice to have

- Tìm lượt lưu trú theo tên khách/phòng trong ca.
- Gợi ý phòng "sẵn sàng" khi nhận khách (đã có ở `room-catalog` tra cứu — chỉ cần dùng chung).

*Không làm (theo PRD): thanh toán, đặt cọc, giá tiền, booking/đặt trước, OTA/PMS, giờ nhận/trả quy định, quản lý quá hạn.*

## 5. Core Flows (Happy Path)

### 5.1 Nhận phòng thành công

1) Lễ tân chọn phòng "sẵn sàng" → bấm "Nhận phòng".
2) Nhập thông tin khách tối thiểu (tên khách + số người; ghi chú/ngày dự kiến trả tùy chọn P1) → xác nhận.
3) Hệ thống kiểm tra lại 3 điều kiện tại thời điểm ghi → tạo lượt lưu trú → trục lưu trú chuyển "đang ở" → ghi nhật ký → phát realtime.
4) Phòng hiển thị "đang ở" trên mọi màn hình; khách xuất hiện trong danh sách đang lưu trú.

```
LỄ TÂN                  HỆ THỐNG                       CÁC THIẾT BỊ KHÁC
   │                       │                                │
   │── Chọn phòng sẵn sàng,│                                │
   │   "Nhận phòng" ──────▶│                                │
   │                       ├─ tải lại trạng thái 3 trục     │
   │                       ├─ trống? sạch? bình thường?     │
   │                       │    ├─ KHÔNG ─▶ chặn, báo lý do cụ thể
   │                       │    │         (đang ở / chưa sạch /
   │                       │    │          ngừng phục vụ), giữ form
   │                       │    └─ CÓ
   │◀── Form khách ────────┤                                │
   │── tên khách + số người│                                │
   │   (tối thiểu) ───────▶│                                │
   │                       ├─ tạo lượt lưu trú              │
   │                       ├─ lưu trú: trống → đang ở       │
   │                       ├─ ghi nhật ký + phát realtime ─▶│ mọi màn đổi
   │◀── "Đã nhận phòng X" ──┤                                ≤3s
   ▼                       ▼                                ▼
```

### 5.2 Nhận phòng bị chặn

1) Lễ tân chọn phòng KHÔNG sẵn sàng → bấm "Nhận phòng".
2) Hệ thống từ chối + nêu rõ lý do: "Phòng đang có khách" / "Phòng chưa dọn xong (đang ở trạng thái {cần dọn/đang dọn/chờ kiểm tra})" / "Phòng đang ngừng phục vụ".
3) Không tạo lượt lưu trú, trạng thái phòng không đổi; lễ tân chọn phòng khác hoặc chờ trạng thái đổi.

### 5.3 Trả phòng

1) Lễ tân mở danh sách phòng đang ở → chọn phòng → "Trả phòng" → xác nhận.
2) Hệ thống đóng lượt lưu trú (ghi mốc trả) → trục lưu trú → "trống", trục vệ sinh → "cần dọn" → phát sự kiện trả phòng → `housekeeping` tự tạo việc dọn.
3) Ghi nhật ký + realtime; phòng xuất khỏi danh sách đang ở, xuất hiện ở nhóm cần dọn.

### 5.4 Hủy nhận phòng nhầm (P1)

1) Lễ tân nhận nhầm phòng/khách → trong cửa sổ ngắn sau nhận, chọn "Hủy nhận phòng" → xác nhận.
2) Lượt lưu trú đánh dấu hủy → trục lưu trú về "trống"; trục vệ sinh giữ nguyên trạng thái trước nhận (sạch) — KHÔNG tạo việc dọn.
3) Ghi nhật ký rõ là hủy nhầm; phòng lại "sẵn sàng".

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES | NO |
|---|---|---|---|---|
| D1 | Nhận phòng | Phòng trống? | Kiểm tra tiếp | Chặn: "Phòng đang có khách" |
| D2 | Nhận phòng | Vệ sinh = sạch? | Kiểm tra tiếp | Chặn: "Phòng chưa dọn xong ({trạng thái})" |
| D3 | Nhận phòng | Bảo trì = bình thường? | Cho nhận (tạo lượt lưu trú) | Chặn: "Phòng đang ngừng phục vụ" |
| D4 | Nhận phòng | Thông tin khách tối thiểu đủ? | Tạo lượt lưu trú | Từ chối lưu, chỉ rõ trường thiếu, giữ form |
| D5 | Trả phòng | Phòng đang "đang ở" với lượt lưu trú mở? | Cho trả → trống + cần dọn + sự kiện | Từ chối + yêu cầu tải lại trạng thái |
| D6 | Hủy nhận phòng (P1) | Trong cửa sổ cho phép + chưa phát sinh hoạt động khác trên phòng? | Hủy lượt, phòng về trống | Từ chối — phải dùng "Trả phòng" bình thường |
| D7 | Bất kỳ thao tác ghi | Trạng thái phòng vừa đổi bởi người khác (realtime) | Từ chối "trạng thái đã đổi", tải lại | Ghi bình thường |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| trống + sạch + bình thường | đang ở (lưu trú) | Nhận phòng, thông tin khách đủ | Tạo lượt lưu trú + nhật ký + realtime | Phòng "đang ở", khách trong danh sách lưu trú |
| đang ở | — | Nhận phòng | Chặn + lý do "đang có khách" | Không đổi |
| trống + (cần dọn/đang dọn/chờ kiểm tra) | — | Nhận phòng | Chặn + lý do "chưa dọn xong" | Không đổi |
| trống + sạch + ngừng phục vụ | — | Nhận phòng | Chặn + lý do "ngừng phục vụ" | Không đổi |
| đang ở | trống + cần dọn | Trả phòng | Đóng lượt lưu trú + phát sự kiện → `housekeeping` tạo việc | Phòng "cần dọn", việc dọn xuất hiện |
| đang ở (vừa nhận nhầm) | trống + trạng thái vệ sinh như trước | Hủy nhận phòng trong cửa sổ (P1) | Hủy lượt + nhật ký hủy | Phòng lại "sẵn sàng", KHÔNG việc dọn |
| trống (không lượt mở) | — | Trả phòng | Từ chối "trạng thái đã đổi", tải lại | Không đổi |

### 6.3 State Transitions

```
Trục lưu trú (feature này sở hữu):
trống ── nhận phòng (đủ điều kiện) ──▶ đang ở
đang ở ── trả phòng ──▶ trống
đang ở ── hủy nhận phòng (P1) ──▶ trống

Trục vệ sinh (sở hữu: housekeeping — feature này CHỈ gây chuyển
sạch → cần dọn khi trả phòng):
sạch ── trả phòng ──▶ cần dọn → (chu trình dọn của housekeeping)

Trục bảo trì: feature này KHÔNG đổi; chỉ đọc để chặn nhận phòng
khi "ngừng phục vụ".

Lượt lưu trú (entity của feature):
mở (nhận) → đóng (trả) | hủy (hủy nhận nhầm)
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Phòng (lưu trú) | trống | đang ở | Nhận phòng | có (trả/hủy) |
| Phòng (lưu trú) | đang ở | trống | Trả phòng / hủy nhận | có (chu kỳ) |
| Phòng (vệ sinh) | sạch | cần dọn | Trả phòng | có (qua `housekeeping`) |
| Lượt lưu trú | — | mở | Nhận phòng | — |
| Lượt lưu trú | mở | đóng | Trả phòng | không |
| Lượt lưu trú | mở | hủy | Hủy nhận phòng (P1) | không |

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Mất mạng khi xác nhận nhận/trả phòng | Thao tác chưa lưu; trạng thái giữ nguyên | Có mạng → tải trạng thái mới, làm lại | Không có |
| 2 lễ tân cùng nhận 1 phòng gần đồng thời | Lượt đầu được lưu | Người sau bị chặn "đang có khách" khi tải lại | Không có — kiểm tra lại điều kiện tại thời điểm ghi |
| Trả phòng xong nhưng thiết bị của nhân viên offline | Việc dọn đã tạo ở máy chủ | Nhân viên có mạng lại → thấy việc | Không có |
| Nhận phòng khi phòng vừa bị đặt ngừng phục vụ | Bản ghi nhật ký đổi bảo trì trước | Lễ tân bị chặn "ngừng phục vụ" khi ghi | Không có |

### 6.5 Other Edge Cases

- Phòng vừa sạch (housekeeping vừa xác nhận) — nhận phòng ngay: cho phép, điều kiện thỏa.
- Phòng ngừng phục vụ NHƯNG đang có khách (đặt tay khi khách đang ở — `room-catalog`): trả phòng bình thường; sau trả phòng vẫn ngừng phục vụ, không nhận khách mới.
- Hủy nhận phòng sau khi đã phát sinh hoạt động khác trên phòng (vd đã báo hỏng): không cho hủy — phải trả phòng bình thường.
- Trả phòng 2 lần (double-click / 2 thiết bị): lần sau bị từ chối "trạng thái đã đổi".
- Khách trả phòng nhưng phòng vệ sinh chưa "sạch" từ đợt trước (dữ liệu bất thường): trả phòng vẫn ghi vệ sinh = "cần dọn" — hành vi đúng nghiệp vụ.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Tên khách | Bắt buộc, không rỗng (giả định — OQ-1) |
| Số người | Bắt buộc, số nguyên dương (giả định — OQ-1) |
| Ghi chú khi nhận (P1) | Tùy chọn, ≤ 500 ký tự |
| Ngày dự kiến trả (P1) | Tùy chọn, chỉ hiển thị |
| Nhận phòng | Phòng phải trống + sạch + bình thường tại thời điểm ghi |
| Trả phòng | Phòng phải đang ở với lượt lưu trú đang mở |
| Hủy nhận phòng (P1) | Trong cửa sổ ngắn sau nhận + phòng chưa phát sinh hoạt động khác — độ dài cửa sổ xem OQ-2 |
| Thao tác nhận/trả/hủy | Chỉ vai trò lễ tân (kiểm tra server) |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Thời gian hiển thị cập nhật | ≤ 3 giây | Từ lúc máy chủ lưu | Mục tiêu ≥95% lượt (tôn chỉ) |
| Ghi chú nhận phòng | ≤ 500 ký tự | Mỗi lượt | Từ chối lưu khi vượt |
| Cửa sổ hủy nhận phòng | Chưa chốt — OQ-2 | Từ mốc nhận | Ngoài cửa sổ phải dùng trả phòng |
| Một lượt lưu trú mở / phòng | 1 | Tại mọi thời điểm | Nhận thêm bị chặn "đang có khách" |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording |
|---|---|
| Nhận phòng đang ở | "Phòng đang có khách — không thể nhận." |
| Nhận phòng chưa sạch | "Phòng chưa dọn xong ({trạng thái}) — không thể nhận." |
| Nhận phòng ngừng phục vụ | "Phòng đang ngừng phục vụ — không thể nhận." |
| Thiếu tên khách | "Vui lòng nhập tên khách." |
| Trả phòng không đang ở | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." |
| Hủy nhận quá cửa sổ | "Đã quá thời gian hủy nhận phòng — vui lòng dùng 'Trả phòng'." |
| Mất mạng | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." |
| Sai quyền | "Bạn không có quyền thực hiện thao tác này." |

#### Success messages

| Tình huống | Wording |
|---|---|
| Nhận phòng | "Đã nhận phòng {số phòng} cho khách {tên khách}." |
| Trả phòng | "Đã trả phòng {số phòng} — việc dọn đã được tạo." |
| Hủy nhận | "Đã hủy nhận phòng {số phòng}." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Danh sách đang ở rỗng | "Chưa có phòng nào đang có khách." |
| Xác nhận trả phòng | "Xác nhận trả phòng {số phòng}? Phòng sẽ chuyển sang 'cần dọn'." |

## 8. Assumptions

- Thông tin khách tối thiểu khi nhận: tên khách (bắt buộc) + số người (bắt buộc); không thu thập giấy tờ/CCCD, liên hệ — dữ liệu giả lập, không phải khách thật (OQ-1).
- Mỗi lần nhận phòng tạo 1 lượt lưu trú (stay) gồm phòng + khách + mốc nhận/trả — phục vụ nhật ký và danh sách đang ở.
- Trả phòng LUÔN đưa vệ sinh về "cần dọn" và phát sự kiện cho `housekeeping` — bất kể phòng sạch hay bẩn thực tế (nghiệp vụ: trả phòng phải dọn lại).
- Không có giờ nhận/trả quy định, không tính tiền, không đặt trước — ngoài phạm vi PRD.
- Hủy nhận phòng chỉ trong cửa sổ ngắn và chưa phát sinh hoạt động khác; lượt hủy giữ vết trong nhật ký, không tạo việc dọn.
- Ngày dự kiến trả (nếu có, P1) chỉ để hiển thị — cảnh báo quá hạn thuộc `room-dashboard`.

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Nhận khách vào phòng chưa sẵn sàng | thường | Khách vào phòng bẩn/hỏng — rủi ro cốt lõi sản phẩm muốn loại bỏ | Chặn cứng 3 điều kiện tại thời điểm ghi + lý do cụ thể |
| Trả phòng nhưng buồng phòng không biết | thường | Phòng "treo" bẩn, không dọn kịp cho khách sau | Trả phòng tự phát sự kiện → `housekeeping` tạo việc |
| 2 lễ tân cùng nhận 1 phòng | thỉnh thoảng | Double-booking | Kiểm tra điều kiện lại tại thời điểm ghi + nhật ký |
| Nhận nhầm phòng/khách | thỉnh thoảng | Dữ liệu lưu trú sai | Hủy nhận phòng trong cửa sổ (P1) |
| Danh mục phòng lệch (dependency `room-catalog`) | thỉnh thoảng | Trạng thái nhận/trả bám dữ liệu sai | Kiểm chứng `room-catalog` Sprint 1 |

## 10. Success Criteria (preliminary)

- 100% lượt nhận phòng vào phòng KHÔNG sẵn sàng bị chặn kèm lý do cụ thể — 0 khách vào phòng chưa sẵn sàng.
- 100% lượt trả phòng tạo việc dọn trong `housekeeping` (qua sự kiện) — 0 phòng "treo" bẩn.
- 0 double-booking (hai lượt lưu trú mở trên cùng một phòng).
- Mọi lượt nhận/trả/hủy có nhật ký ai/khi/phòng nào; cập nhật lan realtime ≤3s.

## 11. Open Questions

- [ ] OQ-1: Thông tin khách tối thiểu khi nhận phòng gồm những gì? (giả định: tên khách + số người bắt buộc; có cần số điện thoại/CCCD giả lập không?)
- [ ] OQ-2: Cửa sổ cho phép hủy nhận phòng nhầm dài bao lâu (vd 15–30 phút)? Và điều kiện "chưa phát sinh hoạt động khác" gồm những gì?
- [ ] OQ-3: Trả phòng có cần ghi chú tình trạng phòng (vd khách làm hỏng) không, hay việc đó hoàn toàn thuộc báo hỏng trong `maintenance`?
- [ ] OQ-4: Lễ tân có được phép xem lịch sử lượt lưu trú đã đóng, hay chỉ quản lý? (nhật ký lượt lưu trú trong `audit-logs` vs màn tra cứu)

## 12. Next Steps

- `/urd check-in-out` — capture user perspective
- `/brd check-in-out` — business case
- `/prd-epic check-in-out` — product scope
- `/srs check-in-out --spec-only` — core spec Tầng 1
