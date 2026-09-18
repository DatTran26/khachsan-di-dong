---
type: urd
feature: room-catalog
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/room-catalog/brainstorms/danh-muc-phong.md|Brainstorm — Danh mục phòng]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.2]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# URD — Room Catalog

## 1. Purpose

Tài liệu này ghi nhận nhu cầu phía người dùng cho feature `room-catalog` — danh mục phòng của khách sạn giả định 50 phòng, là dữ liệu gốc mà mọi trạng thái phòng và thao tác vận hành (`check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`) bám vào. Đây là tầng yêu cầu người dùng, không phải thiết kế kỹ thuật.

## 2. User Problem & Current Experience

| Vấn đề hiện tại | Hậu quả với người dùng |
|---|---|
| Danh mục phòng nằm rải trong sổ/Excel/đầu người quản lý, không có nguồn số hóa tập trung | Quản lý không kiểm soát được danh mục khớp thực tế; sai danh mục → mọi báo cáo, trạng thái, việc giao lệch theo |
| Lễ tân không có chỗ tra "phòng nào ở tầng nào, loại gì, đang ra sao" | Muốn nhận khách phải hỏi buồng phòng từng phòng; chậm và dễ nhận nhầm phòng chưa sẵn sàng |
| Nhân viên được giao việc nhưng không biết phòng ở đâu, loại gì | Đi nhầm phòng, mất thời gian hỏi lại, cập nhật sai phòng |
| Không có nhật ký khi danh mục bị sửa/xóa | Không truy vết được ai đổi gì, khi nào — mâu thuẫn với yêu cầu tôn chỉ |

## 3. User Types

| User Type | Vai trò trong feature | Quyền chính |
|---|---|---|
| Quản lý | Primary — chủ danh mục | Thêm/sửa/xóa phòng, đặt/gỡ ngừng phục vụ, tra cứu toàn bộ |
| Lễ tân | Secondary — tiêu thụ danh mục để nhận/trả phòng | Tra cứu theo tầng/trạng thái; đặt/gỡ ngừng phục vụ (project-profile); thêm/sửa phòng đang mở — OQ-1 |
| Nhân viên buồng phòng–bảo trì | Secondary — tiêu thụ danh mục khi nhận việc | Tra cứu thông tin phòng (tầng, loại, trạng thái) trên mobile |
| Hệ thống | Tham gia gián tiếp | Khởi tạo trạng thái mặc định cho phòng mới; ghi nhật ký; phát realtime |

## 4. Scope Boundaries

### In scope

- Danh mục phòng 50 phòng giả lập: số phòng (duy nhất), tầng, loại phòng.
- CRUD phòng bởi quản lý; xóa có điều kiện (không xóa phòng đang vận hành/đã có lịch sử — rút khỏi vận hành qua "ngừng phục vụ").
- Mỗi phòng hiển thị 3 trục trạng thái riêng: lưu trú (trống/đang ở), vệ sinh (cần dọn/đang dọn/chờ kiểm tra/sạch), bảo trì (bình thường/ngừng phục vụ); "sẵn sàng" là trạng thái suy ra, không lưu riêng.
- Tra cứu/lọc theo tầng, loại phòng, trạng thái từng trục — cho mọi vai trò.
- Đặt/gỡ "ngừng phục vụ" thủ công không qua báo hỏng (quản lý + lễ tân).
- Nhật ký mọi thay đổi danh mục; lan realtime tới mọi thiết bị.

### Out of scope

- Giá phòng, hình ảnh, tiện nghi chi tiết, sơ đồ mặt bằng (non-goal theo PRD).
- Thay đổi trục lưu trú/vệ sinh trong catalog — thuộc `check-in-out` và `housekeeping`.
- Ngừng phục vụ do báo hỏng/sửa chữa — thuộc `maintenance`.
- Sơ đồ trạng thái tổng quan toàn khách sạn — thuộc `room-dashboard`.
- Nhập danh mục hàng loạt từ file, đồng bộ PMS/OTA — ngoài phạm vi dự án.

## 5. User Needs

| ID | User Type | Need | Priority | Liên kết PRD |
|---|---|---|---|---|
| UN-room-catalog-01 | Quản lý | Nhập danh mục 50 phòng ban đầu một lần, chính xác | P0 | §7.2 |
| UN-room-catalog-02 | Quản lý | Sửa thông tin phòng (tầng, loại, số) khi thay đổi thực tế | P0 | §7.2 |
| UN-room-catalog-03 | Quản lý | Xóa phòng tạo nhầm; phòng đang vận hành/có lịch sử bị chặn xóa | P0 | §7.2 + tôn chỉ nhật ký |
| UN-room-catalog-04 | Quản lý/Lễ tân | Đặt/gỡ "ngừng phục vụ" khi phòng cần đóng ngoài báo hỏng | P1 | §7.2 + profile |
| UN-room-catalog-05 | Mọi vai trò | Tra cứu/lọc phòng theo tầng, loại, trạng thái từng trục | P0 | §7.2 |
| UN-room-catalog-06 | Mọi vai trò | Thấy cập nhật danh mục từ người khác ngay lập tức, không cần hỏi lại | P0 | Tôn chỉ realtime |
| UN-room-catalog-07 | Quản lý | Tạo nhanh nhiều phòng theo dải để nhập danh mục ban đầu | P1 | §7.2 (nhập 50 phòng) |
| UN-room-catalog-08 | Quản lý | Tự định nghĩa danh mục loại phòng | P1 | §7.2 (loại phòng) |
| UN-room-catalog-09 | Mọi vai trò | Truy vết ai đã thêm/sửa/xóa phòng nào, khi nào | P0 | Tôn chỉ nhật ký |

## 6. Prioritized User Journeys

### J1 — Nhập danh mục ban đầu (P0)

1. Quản lý mở Danh mục phòng lần đầu (danh mục rỗng).
2. Thêm phòng: nhập số phòng, chọn tầng, chọn loại phòng → lưu.
3. Hệ thống từ chối nếu số trùng; nếu hợp lệ → tạo phòng trống + sạch + bình thường.
4. Lặp lại (hoặc tạo theo dải P1) tới đủ 50 phòng.
5. Kết quả: danh mục khớp khách sạn giả lập; phòng "sẵn sàng" hiển thị cho lễ tân.

### J2 — Tra cứu phòng để vận hành (P0)

1. Lễ tân/nhân viên mở danh mục → lọc theo tầng và/hoặc trạng thái.
2. Thấy danh sách phòng khớp điều kiện kèm 3 trục trạng thái.
3. Thay đổi từ thiết bị khác lan vào danh sách realtime (≤3s).

### J3 — Sửa thông tin phòng (P0)

1. Quản lý chọn phòng → sửa tầng/loại/số phòng → lưu.
2. Hệ thống kiểm tra số mới không trùng → lưu + nhật ký trước→sau.
3. Mọi màn tra cứu/dashboard/việc đang mở hiển thị thông tin mới.

### J4 — Đưa phòng ra khỏi vận hành (P1)

1. Quản lý/lễ tân chọn phòng → "Ngừng phục vụ" → nhập lý do → xác nhận.
2. Trục bảo trì → "ngừng phục vụ"; phòng mất "sẵn sàng", bị `check-in-out` chặn nhận khách.
3. Khi cần mở lại → "Mở phục vụ lại" → trục về "bình thường".

## 7. User Exceptions & Edge Conditions

| Tình huống | Người dùng trông đợi |
|---|---|
| Nhập số phòng đã tồn tại | Báo lỗi trùng rõ ràng, giữ nguyên form để sửa |
| Bấm xóa phòng đang có khách/đang dọn/có việc mở | Bị từ chối kèm lý do trạng thái, hiểu được phải làm gì tiếp |
| Bấm xóa phòng đã có lịch sử | Bị từ chối xóa cứng, được hướng dẫn dùng "ngừng phục vụ" |
| Đặt ngừng phục vụ phòng đang có khách | Được cảnh báo; xác nhận thì phòng đóng nhận khách mới, khách vẫn ở hết kỳ |
| Lọc không có phòng nào khớp | Thấy trạng thái rỗng thay vì màn hình trống/lỗi |
| Mất mạng khi lưu | Thao tác chưa lưu, được báo rõ; có mạng lại thì nhập lại |
| Người khác sửa cùng phòng lúc đó | Người lưu sau bị từ chối "trạng thái đã đổi", phải tải lại |

## 8. User-side Constraints

- Thiết bị: web (quản lý, lễ tân) và Android (nhân viên) — tiếng Việt.
- ~10 phiên đồng thời; realtime là kỳ vọng mặc định, không phải "thỉnh thoảng kiểm tra lại".
- Dữ liệu giả lập 50 phòng — không dữ liệu khách thật.
- Lễ tân dùng trên quầy trong ca làm việc; nhân viên dùng trên mobile khi di chuyển.

## 9. Assumptions & Validation Needed

- Phòng mới mặc định trống + sạch + bình thường → "sẵn sàng" ngay. Cần xác nhận trong nghiệm thu.
- Loại phòng là danh mục quản lý tự định nghĩa (dữ liệu giả lập). Cần xác nhận.
- Phòng có lịch sử không xóa cứng — giả định từ yêu cầu nhật ký tôn chỉ; cần xác nhận nghiệm thu.
- Lễ tân đặt/gỡ ngừng phục vụ theo project-profile; quyền thêm/sửa phòng của lễ tân đang mở — OQ-1.

## 10. User Success Criteria

| ID | Tiêu chí | Đo bằng |
|---|---|---|
| USC-room-catalog-01 | Danh mục đủ 50 phòng khớp dữ liệu giả lập | Đối chiếu 1-1 số/tầng/loại lúc nghiệm thu |
| USC-room-catalog-02 | Cập nhật danh mục lan sang thiết bị khác ≤3 giây | Đo thực tế trong UAT, ≥95% lượt |
| USC-room-catalog-03 | 0 số phòng trùng, 0 xóa sai điều kiện | Kiểm thử dữ liệu |
| USC-room-catalog-04 | Mọi thay đổi có nhật ký ai/khi/trước→sau | Kiểm tra log máy chủ |
| USC-room-catalog-05 | Lễ tân tra được phòng "sẵn sàng" không cần hỏi buồng phòng | Kịch bản UAT |

## 11. Open Questions

- [ ] OQ-1: Quyền của lễ tân với danh mục phòng — chỉ tra cứu + đặt/gỡ ngừng phục vụ, hay cả thêm/sửa phòng? (mâu thuẫn giữa project-profile và PRD §7.2)
- [ ] OQ-2: Cách nạp danh mục ban đầu 50 phòng — nhập tay, theo dải, hay nạp sẵn giả lập? Cho phép vượt 50 phòng?
- [ ] OQ-3: Quy ước đánh số phòng có bắt buộc không, hay số phòng là chuỗi tự do chỉ cần duy nhất?

## 12. Next Steps

- `/brd room-catalog` — business case
- `/prd-epic room-catalog` — product scope
- `/srs room-catalog --spec-only` — core spec Tầng 1
