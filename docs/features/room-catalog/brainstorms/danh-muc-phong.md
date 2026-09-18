---
type: brainstorm
feature: room-catalog
status: draft
updated: 2026-09-17
links:
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.2]]"
---

# Room Catalog — Danh mục phòng

## 1. Idea Seed

Danh mục phòng là dữ liệu gốc mà mọi trạng thái và thao tác vận hành bám vào: 50 phòng giả lập với số phòng, tầng, loại phòng. Quản lý nhập và chỉnh danh mục; lễ tân và nhân viên tra cứu phòng theo tầng/trạng thái. Mỗi phòng mang 3 trục trạng thái riêng biệt — lưu trú (trống/đang ở), vệ sinh (cần dọn/đang dọn/chờ kiểm tra/sạch), bảo trì (bình thường/ngừng phục vụ) — và "sẵn sàng" chỉ là trạng thái suy ra khi phòng trống + sạch + bình thường. Mọi thay đổi danh mục lan realtime tới các màn hình khác và ghi nhật ký máy chủ.

## 2. Context

MVP 8 tuần (08/09–02/11/2026), 1 khách sạn giả định 50 phòng, tiếng Việt, dữ liệu giả lập. Tôn chỉ yêu cầu: "Trạng thái lưu trú, vệ sinh và bảo trì được theo dõi riêng để tránh nhầm lẫn"; mọi thay đổi kiểm tra quyền và ghi nhật ký ở máy chủ. `room-catalog` nằm Sprint 1 (08/09–21/09: "đăng nhập, phân quyền, phòng") — là điều kiện để `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard` có dữ liệu để chạy.

## 3. User Types (preliminary)

| User Type | Pain Point | Primary Need |
|-----------|-----------|--------------|
| Quản lý | Danh mục phòng nằm rải trong sổ/Excel, sai lệch thì mọi báo cáo lệch theo | Nhập và chỉnh danh mục 50 phòng một lần, chính xác, mọi màn hình tự cập nhật theo |
| Lễ tân | Muốn nhận khách phải hỏi buồng phòng từng phòng một | Tra cứu nhanh phòng theo tầng/trạng thái, thấy ngay phòng nào "sẵn sàng" |
| Nhân viên buồng phòng–bảo trì | Không biết phòng ở tầng nào, loại gì khi được giao việc | Tra cứu thông tin phòng (tầng, loại, trạng thái) ngay trên mobile |

## 4. Capabilities Breakdown

### P0 — must have

- CRUD phòng bởi quản lý: thêm/sửa/xóa phòng với số phòng (duy nhất), tầng, loại phòng.
- Nhập danh mục ban đầu 50 phòng của khách sạn giả lập.
- Mỗi phòng mang 3 trục trạng thái riêng: lưu trú (trống/đang ở), vệ sinh (cần dọn/đang dọn/chờ kiểm tra/sạch), bảo trì (bình thường/ngừng phục vụ). Trục trạng thái chỉ đổi bởi các feature nghiệp vụ tương ứng — catalog KHÔNG cho sửa tay trục lưu trú/vệ sinh.
- Tra cứu và lọc danh mục theo tầng, loại phòng, trạng thái từng trục — cho mọi vai trò.
- Thay đổi danh mục lan realtime tới mọi thiết bị đang mở; mọi thao tác ghi kiểm tra quyền server và ghi nhật ký.

### P1 — should have

- Tạo nhanh nhiều phòng theo dải (chọn tầng + khoảng số phòng + loại phòng) để nhập danh mục ban đầu nhanh.
- Đặt/gỡ "ngừng phục vụ" thủ công (trục bảo trì) khi phòng cần đóng vì lý do khác ngoài báo hỏng — cho quản lý và lễ tân.
- Danh mục loại phòng quản lý tự định nghĩa (thêm/sửa/tắt loại), phòng chọn loại từ danh sách này.

### P2 — nice to have

- Thống kê nhanh theo tầng (số phòng mỗi loại, số phòng đang ngừng phục vụ).
- Sắp xếp/tìm kiếm nâng cao (theo số phòng, nhiều điều kiện kết hợp).

*Không làm (theo PRD): giá phòng, hình ảnh, tiện nghi chi tiết, sơ đồ mặt bằng.*

## 5. Core Flows (Happy Path)

### 5.1 Nhập danh mục ban đầu

1) Quản lý mở màn Danh mục phòng → bấm "Thêm phòng".
2) Nhập số phòng, chọn tầng, chọn loại phòng → bấm lưu.
3) Hệ thống kiểm tra số phòng chưa tồn tại → tạo phòng với trạng thái mặc định: trống + sạch + bình thường → ghi nhật ký → phát realtime.
4) Phòng xuất hiện trong danh mục và trạng thái "sẵn sàng" trên các màn hình tra cứu.
5) Lặp lại (hoặc dùng tạo theo dải P1) cho tới đủ 50 phòng.

```
QUẢN LÝ                HỆ THỐNG                       CÁC THIẾT BỊ KHÁC
   │                       │                                │
   │── Thêm phòng:         │                                │
   │   số/tầng/loại ──────▶│                                │
   │                       ├─ số phòng đã tồn tại? ── YES ──▶ báo lỗi trùng,
   │                       │                                giữ nguyên form
   │                       │           NO
   │                       ├─ tạo phòng: trống + sạch
   │                       │  + bình thường
   │                       ├─ ghi nhật ký (ai, khi, tạo gì)
   │                       ├─ phát realtime ───────────────▶ danh mục + dashboard
   │◀── "Đã thêm phòng X" ──┤                                cập nhật ≤3s
   ▼                       ▼                                ▼
```

### 5.2 Tra cứu phòng để vận hành

1) Lễ tân/nhân viên/quản lý mở danh mục → chọn lọc theo tầng và/hoặc trạng thái (vd "sẵn sàng", "cần dọn", "ngừng phục vụ").
2) Hệ thống hiển thị danh sách phòng khớp điều kiện, kèm trạng thái 3 trục tại thời điểm xem.
3) Mọi thay đổi từ thiết bị khác lan vào danh sách realtime.

### 5.3 Sửa thông tin phòng

1) Quản lý chọn phòng → sửa tầng/loại/số phòng → lưu.
2) Hệ thống kiểm tra số phòng mới không trùng phòng khác → lưu + ghi nhật ký (giá trị trước→sau) → phát realtime.
3) Các màn tra cứu/dashboard/việc đang mở hiển thị thông tin mới.

### 5.4 Xóa phòng / đưa phòng ra khỏi vận hành

1) Quản lý chọn "Xóa" trên một phòng → hệ thống kiểm tra điều kiện.
2) Nếu phòng đang có khách (trục lưu trú "đang ở"), đang dọn, hoặc có việc đang mở → từ chối xóa kèm lý do.
3) Nếu phòng đã có lịch sử hoạt động → từ chối xóa cứng; hướng dẫn đặt "ngừng phục vụ" để rút khỏi vận hành (bảo toàn nhật ký truy vết).
4) Nếu phòng mới tạo, chưa phát sinh hoạt động → cho xóa hẳn sau xác nhận; ghi nhật ký.

### 5.5 Đặt/gỡ "ngừng phục vụ" thủ công (P1)

1) Quản lý/lễ tân chọn phòng → "Ngừng phục vụ" → nhập lý do → xác nhận.
2) Trục bảo trì chuyển "ngừng phục vụ" → phòng không còn "sẵn sàng", `check-in-out` không thể nhận phòng này.
3) "Mở phục vụ lại" → trục bảo trì về "bình thường" → phòng lại "sẵn sàng" nếu trống + sạch.
4) Ngừng phục vụ do báo hỏng/sửa chữa thuộc feature `maintenance` — luồng này chỉ cho trường hợp đóng phòng không qua báo hỏng.

## 6. System Behavior Deep Dive

### 6.1 Decision Points

| ID | Flow | Khi nào | YES (nhánh đồng ý) | NO (nhánh từ chối) |
|---|---|---|---|---|
| D1 | Thêm/sửa phòng | Số phòng đã tồn tại trong danh mục? | Từ chối lưu, báo lỗi trùng, giữ form | Cho lưu, ghi nhật ký, phát realtime |
| D2 | Xóa phòng | Phòng đang ở / đang dọn / có việc mở? | Từ chối xóa, nêu rõ lý do trạng thái | Kiểm tra tiếp lịch sử |
| D3 | Xóa phòng | Phòng đã có lịch sử hoạt động? | Từ chối xóa cứng, hướng dẫn "ngừng phục vụ" | Cho xóa hẳn sau xác nhận |
| D4 | Đặt ngừng phục vụ | Phòng đang có khách? | Cảnh báo + bắt buộc xác nhận lại (phòng vẫn đóng được, khách vẫn ở tới khi trả) | Đặt ngừng phục vụ bình thường |
| D5 | Tra cứu/lọc | Có phòng khớp điều kiện lọc? | Hiển thị danh sách + trạng thái 3 trục | Hiển thị trạng thái rỗng "Không có phòng phù hợp" |

### 6.2 Scenario Matrix

| From State | To State | Rule | Action | Result |
|------------|----------|------|--------|--------|
| (chưa có) | Phòng mới: trống + sạch + bình thường | Quản lý thêm phòng, số chưa trùng | Tạo phòng + ghi nhật ký | Phòng hiện "sẵn sàng" trên mọi màn |
| Thông tin phòng | Thông tin mới | Số phòng sửa đổi không trùng | Lưu + nhật ký trước→sau | Mọi màn hình cập nhật realtime |
| Phòng trống, không việc mở, chưa lịch sử | Xóa hẳn | Quản lý xác nhận xóa | Xóa + ghi nhật ký | Phòng biến mất khỏi danh mục |
| Phòng đang ở/đang dọn/có việc mở | (giữ nguyên) | Quản lý bấm xóa | Từ chối + nêu lý do | Danh mục không đổi |
| Phòng có lịch sử | (giữ nguyên) | Quản lý bấm xóa | Từ chối xóa cứng, gợi ý ngừng phục vụ | Danh mục không đổi |
| Bảo trì: bình thường | ngừng phục vụ | Đặt thủ công (P1) hoặc báo hỏng (`maintenance`) | Đổi trục bảo trì + nhật ký | Phòng mất "sẵn sàng", bị chặn nhận khách |
| Bảo trì: ngừng phục vụ | bình thường | Gỡ thủ công (P1) hoặc sửa xong (`maintenance`) | Đổi trục + nhật ký | Phòng "sẵn sàng" lại nếu trống + sạch |

### 6.3 State Transitions

```
Phòng — trục lưu trú (đổi bởi check-in-out):
trống ⇄ đang ở

Phòng — trục vệ sinh (đổi bởi housekeeping):
sạch → cần dọn → đang dọn → chờ kiểm tra → sạch

Phòng — trục bảo trì (đổi bởi maintenance + đặt tay):
bình thường ⇄ ngừng phục vụ

"Sẵn sàng" = trống + sạch + bình thường (composite, KHÔNG lưu riêng).
Vòng đời phòng trong danh mục: tạo mới → hoạt động → (xóa hẳn nếu
chưa có lịch sử | ngừng phục vụ nếu rút khỏi vận hành).
```

| Entity | Từ | Sang | Trigger | Quay lại được? |
|--------|------|----|---------|-------------|
| Phòng (lưu trú) | trống | đang ở | Nhận phòng (`check-in-out`) | có |
| Phòng (lưu trú) | đang ở | trống | Trả phòng (`check-in-out`) | có (chu kỳ) |
| Phòng (vệ sinh) | sạch | cần dọn | Trả phòng (`check-in-out` → `housekeeping`) | có (chu kỳ) |
| Phòng (vệ sinh) | cần dọn → sạch | qua đang dọn, chờ kiểm tra | Chu trình dọn (`housekeeping`) | có |
| Phòng (bảo trì) | bình thường | ngừng phục vụ | Báo hỏng (`maintenance`) / đặt tay | có |
| Phòng (bảo trì) | ngừng phục vụ | bình thường | Sửa xong (`maintenance`) / gỡ tay | có |
| Phòng (danh mục) | tồn tại | xóa hẳn | Quản lý xóa khi chưa có lịch sử | không |

*Catalog chỉ định nghĩa và hiển thị 3 trục — trigger đổi trục thuộc feature tương ứng, không nhân bản.*

### 6.4 Interrupted Transactions

| Tình huống | Hệ thống còn lại gì | Resume | Cleanup |
|---|---|---|---|
| Quản lý mất mạng khi lưu thêm/sửa phòng | Thao tác chưa lưu; danh mục giữ nguyên | Có mạng lại → tải trạng thái mới, nhập lại | Không có |
| 2 quản lý/lễ tân cùng sửa 1 phòng | Bản ghi đầu được lưu | Người sau bị từ chối "trạng thái đã đổi", tải lại | Không có |
| Nhập 50 phòng dở giữa chừng | Phòng đã lưu giữ nguyên | Tiếp tục thêm phần còn lại; không nhân đôi nhờ kiểm tra trùng số | Không có |
| Tạo theo dải gặp số phòng đã tồn tại | Phòng hợp lệ trong dải đã tạo | Báo rõ số nào bị bỏ qua vì trùng | Không có |

### 6.5 Other Edge Cases

- Phòng vừa tạo xong lập tức "sẵn sàng": cho phép — phòng mới mặc định trống + sạch + bình thường.
- Đặt ngừng phục vụ phòng đang có khách: cho phép kèm cảnh báo (khách ở hết kỳ, phòng không nhận khách mới) — quyết định nghiệp vụ của quản lý.
- Lễ tân đặt/gỡ ngừng phục vụ: theo project-profile lễ tân có quyền này; quyền thêm/sửa phòng của lễ tân đang mở — xem OQ-1.
- Số phòng trùng sau khi sửa: kiểm tra duy nhất cả khi sửa, không chỉ khi thêm.

## 7. Validation, Limits & Wording

### 7.1 Validation rules

| Field | Rule |
|---|---|
| Số phòng | Bắt buộc, không rỗng, duy nhất toàn danh mục (kể cả khi sửa) |
| Tầng | Bắt buộc, số nguyên dương |
| Loại phòng | Bắt buộc, chọn từ danh mục loại phòng hiện có |
| Lý do ngừng phục vụ (đặt tay) | Bắt buộc, không rỗng, tối đa 500 ký tự |
| Thao tác thêm/sửa/xóa phòng | Chỉ vai trò quản lý (lễ tân theo OQ-1) |
| Thao tác đặt/gỡ ngừng phục vụ | Quản lý và lễ tân (theo project-profile) |

### 7.2 Limits & Quotas (exact values)

| Tham số | Giá trị | Window | Behavior khi vượt |
|---|---|---|---|
| Quy mô danh mục | 50 phòng | Khách sạn giả lập | Ngoài 50 vẫn cho thêm nhưng cảnh báo lệch dữ liệu giả lập — xem OQ-2 |
| Thời gian hiển thị cập nhật | ≤ 3 giây | Từ lúc máy chủ lưu thành công | Mục tiêu nghiệm thu ≥95% lượt (tôn chỉ) |
| Lý do ngừng phục vụ | ≤ 500 ký tự | Mỗi lần đặt | Từ chối lưu khi vượt |

### 7.3 Wording samples (exact strings)

#### Error messages

| Tình huống | Wording | Code |
|---|---|---|
| Số phòng trùng | "Số phòng {số} đã tồn tại trong danh mục." | E-? |
| Xóa phòng đang ở/có việc | "Không thể xóa — phòng đang có khách / có việc đang mở." | E-? |
| Xóa phòng có lịch sử | "Phòng đã có lịch sử hoạt động — không xóa được. Hãy đặt 'Ngừng phục vụ' nếu muốn rút khỏi vận hành." | E-? |
| Thiếu lý do ngừng phục vụ | "Vui lòng nhập lý do ngừng phục vụ." | E-? |
| Mất mạng khi lưu | "Mất kết nối — thao tác chưa được lưu. Thử lại khi có mạng." | E-? |
| Thao tác sai trạng thái | "Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất." | E-? |
| Sai quyền | "Bạn không có quyền thực hiện thao tác này." | E-? |

#### Success messages

| Tình huống | Wording |
|---|---|
| Thêm phòng | "Đã thêm phòng {số phòng}." |
| Sửa phòng | "Đã cập nhật thông tin phòng {số phòng}." |
| Xóa phòng | "Đã xóa phòng {số phòng}." |
| Tạo theo dải | "Đã tạo {n} phòng; bỏ qua {m} số đã tồn tại." |
| Ngừng phục vụ | "Phòng {số phòng} đã ngừng phục vụ." |
| Mở phục vụ lại | "Phòng {số phòng} đã mở phục vụ lại." |

#### Info / neutral messages

| Tình huống | Wording |
|---|---|
| Lọc không có kết quả | "Không có phòng phù hợp với điều kiện đã chọn." |
| Ngừng phục vụ phòng đang ở | "Phòng đang có khách — phòng sẽ ngừng nhận khách mới, khách vẫn ở tới khi trả phòng." |

## 8. Assumptions

- Phòng mới tạo mặc định trống + sạch + bình thường → hiển thị "sẵn sàng" ngay.
- Loại phòng là danh sách quản lý tự định nghĩa (vd Standard/Deluxe/VIP — dữ liệu giả lập); phòng phải chọn 1 loại từ danh sách.
- Phòng đã phát sinh hoạt động không xóa cứng (bảo toàn nhật ký truy vết theo tôn chỉ) — rút khỏi vận hành qua "ngừng phục vụ".
- Trục lưu trú và vệ sinh không sửa tay trong catalog — chỉ đổi qua nghiệp vụ (`check-in-out`, `housekeeping`); trục bảo trì ngoài báo hỏng còn cho đặt/gỡ tay.
- Số phòng là định danh hiển thị duy nhất; cho phép sửa nhưng luôn kiểm tra trùng.
- Thông báo/cập nhật đi qua kênh realtime trong app (theo tôn chỉ), không SMS/push ngoài.

## 9. Risks

| Rủi ro | Khả năng | Hậu quả nghiệp vụ | Cách phòng |
|--------|----------|-------------------|-----------|
| Danh mục nhập sai/không khớp thực tế | thường | Mọi trạng thái, việc và dashboard lệch theo (rủi ro chính theo PRD) | Kiểm tra trùng số phòng; nghiệm thu đối chiếu đủ 50 phòng với dữ liệu giả lập |
| Nhập tay 50 phòng mất thời gian, dễ nhầm | thường | Setup demo chậm, sai sót nhập liệu | Tạo theo dải (P1); nghiệm thu đối soát danh mục |
| Xóa/sửa phòng đang vận hành làm mất vết | thỉnh thoảng | Nhật ký lệch thực tế, không truy vết được | Chặn xóa khi đang ở/có việc/có lịch sử; mọi sửa ghi giá trị trước→sau |
| Quyền catalog của lễ tân chưa đồng nhất giữa tài liệu | thỉnh thoảng | Lễ tân sửa danh mục ngoài ý quản lý | OQ-1 chốt trước khi nghiệm thu |

## 10. Success Criteria (preliminary)

- Danh mục đủ 50 phòng khớp dữ liệu giả lập của khách sạn (đối chiếu 1-1 số phòng/tầng/loại).
- 100% thay đổi danh mục (thêm/sửa/xóa/ngừng phục vụ) phản ánh trên màn tra cứu của thiết bị khác trong ≤3 giây.
- 0 phòng bị xóa khi đang ở, đang dọn hoặc đã có lịch sử; 0 số phòng trùng trong danh mục.
- Mọi thay đổi danh mục có bản ghi ai/khi/giá trị trước→sau trong nhật ký máy chủ.

## 11. Open Questions

- [ ] OQ-1: Lễ tân có quyền thêm/sửa phòng (số/tầng/loại) hay chỉ tra cứu + đặt/gỡ ngừng phục vụ? (project-profile ghi lễ tân "quản lý danh mục phòng"; PRD §7.2 ghi "CRUD phòng bởi quản lý")
- [ ] OQ-2: Nạp danh mục ban đầu 50 phòng bằng cách nào — nhập tay từng phòng, tạo theo dải, hay nạp sẵn dữ liệu giả lập? Vượt 50 phòng có cho phép?
- [ ] OQ-3: Quy ước đánh số phòng (vd số = tầng × 100 + thứ tự) có bắt buộc không, hay số phòng là chuỗi tự do chỉ cần duy nhất?

## 12. Next Steps

- `/urd room-catalog` — capture user perspective
- `/brd room-catalog` — business case
- `/prd-epic room-catalog` — product scope
- `/srs room-catalog --spec-only` — core spec Tầng 1
