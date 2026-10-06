---
type: brainstorm
feature: realtime-sync
status: draft
updated: 2026-09-23
links:
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# realtime-sync — Cơ chế đồng bộ thời gian thực

## 1. Idea Seed

Cơ chế nền khiến "một nguồn sự thật" thành hiện thực: thay đổi trạng thái được lưu ở máy chủ rồi phát tới mọi thiết bị trong ≤3 giây; khi hai người sửa cùng lúc thì kiểm tra phiên bản để không ghi đè; khi mất mạng, thiết bị báo trạng thái và khóa thao tác ghi, có mạng lại thì tải trạng thái mới từ máy chủ. Feature không chứa nghiệp vụ riêng — nó là đường truyền chung cho mọi sự kiện trạng thái của `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, 30 phiên đồng thời, dữ liệu giả lập. Tôn chỉ: "dữ liệu thay đổi được đồng bộ thời gian thực giữa các thiết bị" và "cập nhật trạng thái phải có kiểm tra phiên bản để tránh ghi đè". `realtime-sync` thuộc nhóm "Nền tảng chung" cùng `auth-roles`; Sprint 1 (tới 21/09) có mốc "kiểm chứng đồng bộ realtime" trước khi các luồng vận hành Sprint 2 dùng nó.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Mọi vai trò đang thao tác (lễ tân, nv buồng phòng–bảo trì, quản lý) | Cập nhật trên máy mình nhưng máy khác vẫn hiển thị cũ → thông tin lệch nhau | Màn hình của mọi thiết bị luôn phản ánh trạng thái mới nhất mà không cần tải lại tay |
| Nhân viên buồng phòng–bảo trì | Hiện trường wifi không ổn định; không biết thao tác đã lưu chưa | Được báo rõ khi mất kết nối; chắc chắn thao tác không ghi đè/mất lặng lẽ |
| Quản lý | Dashboard tổng chỉ đáng tin nếu dữ liệu lan đến kịp thời | Cái nhìn realtime đúng nghĩa (≤3s) để điều phối trong ca |
| Người vận hành hệ thống (dev/WPCTeam) | Mỗi feature tự làm cơ chế đồng bộ sẽ lệch nhau | Một cơ chế dùng chung: lưu trước phát sau, chống ghi đè, xử lý mất mạng nhất quán |

## 4. Capabilities Breakdown

### P0 — must have

- Lưu thay đổi ở máy chủ trước, chỉ phát sự kiện sau khi lưu thành công.
- Thiết bị khác nhận và hiển thị cập nhật trong ≤3 giây.
- Kiểm tra phiên bản trước khi ghi: phiên bản cũ bị từ chối, không ghi đè; người bị từ chối được tải lại trạng thái mới.
- Phát hiện mất kết nối → hiển thị trạng thái "mất kết nối" rõ ràng + khóa mọi thao tác ghi (vẫn xem được dữ liệu cuối).
- Tự kết nối lại khi có mạng → tải trạng thái mới từ máy chủ → mở khóa ghi; không yêu cầu đăng nhập lại.

### P1 — should have

- Chỉ báo trạng thái kết nối hiển thị thống nhất trên mọi màn hình (banner "Đang mất kết nối — đang thử lại…").
- Khi bị từ chối ghi đè: báo rõ "dữ liệu vừa được người khác cập nhật" + tự tải bản mới.
- Đo độ trễ phát sự kiện phục vụ nghiệm thu (giám sát nội bộ, không hiển thị nghiệp vụ).

### P2 — nice to have

- Hàng đợi offline cho thao tác ghi (ghi tạm, đẩy khi có mạng) — PRD "chưa làm".
- Đồng bộ nội dung đang soạn dở giữa thiết bị — PRD "chưa làm".
- Retry thông minh (backoff, ưu tiên sự kiện) — PRD "chưa làm".

## 5. Core Flows (Happy Path)

### 5.1 Lan truyền cập nhật trạng thái

1) Thiết bị A thực hiện thao tác ghi (vd nhân viên bảo trì báo xong việc phòng 305 — sự kiện thuộc `maintenance`).
2) Máy chủ kiểm tra quyền + phiên bản → lưu thành công → tăng phiên bản đối tượng.
3) Máy chủ phát cập nhật tới mọi thiết bị đang kết nối.
4) Thiết bị B (dashboard quản lý, màn lễ tân) nhận sự kiện → hiển thị trạng thái mới trong ≤3 giây.

```
THIẾT BỊ A              MÁY CHỦ                          THIẾT BỊ B/C/…
    │                      │                                  │
    │ ghi kèm phiên bản    │                                  │
    │─────────────────────▶│ kiểm quyền + phiên bản            │
    │                      │ lưu OK → tăng phiên bản          │
    │   xác nhận đã lưu    │                                  │
    │◀─────────────────────│                                  │
    │                      │ phát sự kiện cập nhật            │
    │                      │─────────────────────────────────▶│
    │                      │                                  │ hiển thị mới ≤3s
    ▼                      ▼                                  ▼
         Một nguồn sự thật ở máy chủ — mọi thiết bị nhìn cùng trạng thái
```

### 5.2 Xung đột phiên bản (hai thiết bị sửa cùng lúc)

1) Thiết bị A và B cùng mở đối tượng ở phiên bản n.
2) A ghi trước → máy chủ lưu, đối tượng thành phiên bản n+1 → phát cập nhật.
3) B ghi sau với phiên bản n (cũ) → máy chủ từ chối, không ghi đè.
4) B được báo "dữ liệu vừa được người khác cập nhật" → tải lại bản mới → thao tác lại nếu cần.

### 5.3 Mất kết nối

1) Thiết bị phát hiện mất kết nối tới máy chủ → hiển thị "Mất kết nối — đang thử kết nối lại…" + khóa ghi.
2) Người dùng vẫn xem được trạng thái cuối đã tải (chỉ đọc), mọi thao tác ghi đều báo "chưa được lưu".

### 5.4 Kết nối lại

1) Thiết bị tự kết nối lại khi có mạng (không cần đăng nhập lại trong phiên còn hạn).
2) Tải trạng thái mới nhất từ máy chủ (bù mọi sự kiện đã lỡ) → hiển thị "Đã kết nối lại — dữ liệu đã cập nhật."
3) Mở khóa ghi; người dùng thao tác tiếp trên dữ liệu mới.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Ghi trạng thái | Kết nối tới máy chủ đang sống? | Cho ghi | Khóa ghi + báo mất kết nối |
| D2 | Ghi trạng thái | Phiên bản gửi kèm khớp phiên bản máy chủ? | Lưu + tăng phiên bản + phát sự kiện | Từ chối ghi đè + báo tải lại |
| D3 | Phát sự kiện | Máy chủ đã lưu thành công? | Phát tới mọi thiết bị đang kết nối | Không phát (trạng thái không đổi) |
| D4 | Kết nối lại | Phiên đăng nhập còn hạn? | Tự kết nối lại + tải trạng thái mới | Yêu cầu đăng nhập lại (theo `auth-roles`) |
| D5 | Nghiệm thu | Sự kiện đến thiết bị khác trong ≤3s? | Tính vào 95% đạt | Ghi nhận lượt chậm cho đối soát |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| Trực tuyến | Mất kết nối | Mất liên lạc máy chủ (D1) | Báo trạng thái + khóa ghi | Chỉ đọc dữ liệu cuối |
| Mất kết nối | Trực tuyến | Kết nối lại thành công (D4) | Tải trạng thái mới + mở khóa ghi | Đồng bộ bù sự kiện lỡ |
| Ghi (phiên bản đúng) | Đã lưu | D2 YES | Lưu + phát | Thiết bị khác thấy ≤3s |
| Ghi (phiên bản cũ) | Bị từ chối | D2 NO | Không ghi đè + báo người ghi | Người ghi tải lại bản mới |
| Phát sự kiện | Đã hiển thị | Thiết bị đang trực tuyến | Áp cập nhật lên màn hình | Mọi thiết bị đồng nhất |

### 6.3 State Transitions

```
Kết nối thiết bị:
trực tuyến ⇄ mất kết nối
  ↑ trực tuyến → mất kết nối: mất liên lạc máy chủ
  ↑ mất kết nối → trực tuyến: kết nối lại tự động + tải trạng thái mới

Đối tượng trạng thái (phòng/việc — do feature nghiệp vụ sở hữu):
phiên bản n → phiên bản n+1 (mỗi lần lưu thành công; không lùi)
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Kết nối thiết bị | trực tuyến | mất kết nối | Mất liên lạc máy chủ | có (tự động) |
| Kết nối thiết bị | mất kết nối | trực tuyến | Kết nối lại + tải trạng thái mới | có (chu kỳ mới) |
| Đối tượng | phiên bản n | phiên bản n+1 | Ghi thành công tại máy chủ | không (phiên bản chỉ tăng) |

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Mất mạng ngay sau khi bấm lưu (chưa rõ đã lưu chưa) | Không chắc ghi thành công | Kết nối lại → tải trạng thái mới, đối chiếu trước khi thao tác lại | Không có |
| Mất mạng khi đang xem | Dữ liệu cuối vẫn hiển thị (chỉ đọc) | Kết nối lại → tải mới | Không có |
| Hai thiết bị ghi cùng đối tượng | Người ghi đầu thắng; người sau bị từ chối | Người sau tải lại bản mới, thao tác lại | Không có |
| Máy chủ lưu xong nhưng sự kiện chưa kịp tới một thiết bị (vừa rớt mạng) | Thiết bị đó lỡ sự kiện | Khi kết nối lại → tải trạng thái mới (bù sự kiện) | Không có |
| Phiên đăng nhập hết hạn trong lúc mất mạng | Kết nối lại được nhưng không ghi được | Chuyển sang đăng nhập lại (`auth-roles`) | Không có |

### 6.5 Other Edge Cases

- Hai thiết bị đổi **khác trục** trạng thái trên cùng phòng (vd một người đổi vệ sinh, một người đổi bảo trì): cho phép cả hai — kiểm tra phiên bản theo đối tượng/trường đổi, không khóa cả phòng.
- Thiết bị offline kéo dài (vd hết ca về nhà): khi mở lại, tải toàn bộ trạng thái mới — không cần phát lại từng sự kiện cũ.
- Sự kiện đến trễ hơn 3 giây do mạng demo chập chờn: vẫn hiển thị; lượt đó tính vào nhóm chậm khi đo nghiệm thu (không che giấu).
- Thiết bị nhận sự kiện cho đối tượng không còn trên màn hình đang xem: bỏ qua hiển thị, dữ liệu vẫn mới khi quay lại màn đó.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Phiên bản kèm theo thao tác ghi | Bắt buộc; khác phiên bản máy chủ → từ chối, không ghi đè |
| Nguồn sự kiện | Chỉ máy chủ phát sự kiện sau khi lưu; thiết bị không tự coi thay đổi của mình là đã đồng bộ cho tới khi máy chủ xác nhận |
| Thao tác ghi khi mất kết nối | Bị khóa ở thiết bị (không gửi), báo rõ cho người dùng |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Độ trễ lan truyền cập nhật | ≤ 3 giây | Từ lúc máy chủ lưu tới khi thiết bị khác hiển thị | Mục tiêu nghiệm thu ≥95% trong 100 lượt (50 phòng, 30 phiên đồng thời) |
| Ghi đè do xung đột phiên bản | 0 ca | Toàn hệ thống | Ghi cũ bị từ chối 100% |
| Ngưỡng thời gian báo "mất kết nối" cho người dùng | **OQ-1 — chưa chốt** | Kể từ khi mất liên lạc | Hiển thị cảnh báo + khóa ghi |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| Ghi khi mất kết nối | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | E-? |
| Bị từ chối ghi đè | "Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất." | E-? |
| Phiên hết hạn khi kết nối lại | "Phiên đăng nhập đã hết — vui lòng đăng nhập lại." | E-? |

#### Success messages

| Tình huống | Wording |
|---|---|
| Kết nối lại thành công | "Đã kết nối lại — dữ liệu đã cập nhật." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Banner mất kết nối | "Mất kết nối — đang thử kết nối lại…" |

## 8. Assumptions

- Một máy chủ duy nhất là nguồn sự thật (MVP không có nhiều nút máy chủ).
- Kênh realtime của stack đã chọn (Socket.IO theo tôn chỉ) đủ cho 30 phiên đồng thời.
- Khi mất kết nối, thiết bị vẫn cho **xem** dữ liệu cuối đã tải — chỉ khóa ghi.
- Sự kiện phát ra mang trạng thái mới của đối tượng; thiết bị lỡ sự kiện được bù bằng "tải trạng thái mới" khi kết nối lại — không cần hàng đợi sự kiện lưu trữ.
- Kiểm tra phiên bản áp theo đối tượng trạng thái (phòng theo trục, việc theo việc), không khóa toàn bộ phòng cho mọi loại thay đổi.

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Xung đột khi 2 người thao tác cùng đối tượng | thường | Nếu ghi đè lặng lẽ → dữ liệu sai trên toàn hệ thống (rủi ro chính PRD) | Kiểm tra phiên bản bắt buộc; người sau bị từ chối + tải lại |
| Mạng demo chập chờn làm lượt cập nhật >3s | thỉnh thoảng | Trượt mục tiêu nghiệm thu 95% | Đo và ghi nhận rõ lượt chậm; chuẩn bị mạng demo ổn định |
| Thiết bị kết nối lại nhưng màn hình không tải lại | thỉnh thoảng | Người dùng nhìn dữ liệu cũ mà tưởng mới | Bước "tải trạng thái mới" bắt buộc trong luồng kết nối lại |
| Người dùng không để ý banner mất kết nối, thao tác rồi tưởng đã lưu | thỉnh thoảng | Việc thật không được ghi | Khóa ghi cứng + thông báo rõ khi chạm vào thao tác ghi |

## 10. Success Criteria (preliminary)

- ≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác trong ≤3 giây (50 phòng, 30 phiên đồng thời — tiêu chí nghiệm thu PRD).
- 0 ca ghi đè trạng thái do xung đột phiên bản.
- 100% thời điểm mất kết nối: thiết bị báo trạng thái rõ và khóa ghi.
- 100% lần kết nối lại: tự tải trạng thái mới, không cần đăng nhập lại (nếu phiên còn hạn).

## 11. Open Questions

- [ ] OQ-1: Thiết bị báo "mất kết nối" cho người dùng sau tối đa bao lâu kể từ khi mất liên lạc máy chủ?
- [ ] OQ-2: Người bị từ chối ghi đè có cần giữ lại nội dung vừa nhập để nhập lại, hay chỉ tải bản mới và tự nhập lại?
- [ ] OQ-3: Khi kết nối lại, "tải trạng thái mới" là toàn bộ trạng thái đang xem hay chỉ các đối tượng đã đổi (ảnh hưởng thời gian chờ của người dùng)?

## 12. Next Steps

Sau brainstorm này (sau khi BA approve):
- `/urd realtime-sync` — capture user perspective
- `/brd realtime-sync` — business case
- `/prd-epic realtime-sync` — product scope
- `/srs realtime-sync` (Tầng 1 — Core spec)
