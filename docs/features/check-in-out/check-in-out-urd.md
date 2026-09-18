---
type: urd
feature: check-in-out
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/check-in-out/brainstorms/nhan-tra-phong.md|Brainstorm — Nhận/Trả phòng]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.3]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# URD — Check-in-out

## 1. Purpose

Ghi nhận nhu cầu phía người dùng cho `check-in-out` — hai hành động vận hành lõi của lễ tân: nhận phòng chỉ khi phòng sẵn sàng (trống + sạch + bình thường) và trả phòng để phòng về trống + cần dọn, tự phát sinh việc dọn cho `housekeeping`. Tầng yêu cầu người dùng, không phải thiết kế kỹ thuật.

## 2. User Problem & Current Experience

| Vấn đề hiện tại | Hậu quả với người dùng |
|---|---|
| Lễ tân không biết chắc phòng đã sẵn sàng chưa — phải hỏi buồng phòng | Nhận nhầm khách vào phòng chưa dọn/ngừng phục vụ — rủi ro cốt lõi sản phẩm muốn loại bỏ |
| Không có chỗ ghi nhận khách đang ở phòng nào | Không tra được "phòng nào đang có khách", khách nào đang lưu trú |
| Trả phòng xong phải báo miệng buồng phòng — hay quên | Phòng "treo" bẩn, không dọn kịp, không bán được cho khách sau |
| Nhận nhầm phòng/khách không có cách sửa gọn | Phải xin quản lý sửa tay — chậm, mất vết |
| Không có nhật ký nhận/trả | Không truy vết được ai nhận khách nào vào phòng nào, khi nào |

## 3. User Types

| User Type | Vai trò trong feature | Quyền chính |
|---|---|---|
| Lễ tân | Primary — người thực hiện | Nhận phòng, trả phòng, hủy nhận phòng (P1), xem danh sách đang ở |
| Quản lý | Secondary — giám sát | Xem danh sách phòng đang ở, khách đang lưu trú, nhật ký lượt lưu trú; KHÔNG thực hiện nhận/trả |
| Nhân viên buồng–bảo trì | Secondary — downstream | Thấy phòng cần dọn/việc mới sau trả phòng (qua `housekeeping`) |
| Hệ thống | Tham gia trực tiếp | Kiểm tra điều kiện nhận phòng; đóng/mở lượt lưu trú; đổi trục lưu trú + vệ sinh khi trả; phát sự kiện trả phòng; ghi nhật ký; realtime |

## 4. Scope Boundaries

### In scope

- Nhận phòng với kiểm tra cứng 3 điều kiện: trống + sạch + bình thường; chặn kèm lý do cụ thể khi không thỏa.
- Ghi thông tin khách tối thiểu (giả định: tên khách + số người — OQ-1); tạo và đóng lượt lưu trú.
- Trả phòng: trống + cần dọn; phát sự kiện trả phòng để `housekeeping` tự tạo việc dọn.
- Danh sách phòng đang ở + khách đang lưu trú theo phòng.
- Hủy nhận phòng nhầm trong cửa sổ ngắn (P1) — giữ vết nhật ký, không tạo việc dọn.
- Kiểm tra quyền server (chỉ lễ tân ghi), nhật ký mọi lượt nhận/trả/hủy, realtime.

### Out of scope

- Thanh toán, đặt cọc, giá tiền, hóa đơn (non-goal dự án).
- Đặt trước/booking, quản lý giờ nhận/trả quy định.
- Cảnh báo quá hạn lưu trú — thuộc `room-dashboard`.
- Tạo/xử lý việc dọn — thuộc `housekeeping` (feature này chỉ phát sự kiện trả phòng).
- Báo hỏng/ngừng phục vụ — thuộc `maintenance` và `room-catalog`.
- Quản lý danh mục phòng — thuộc `room-catalog`.
- Giấy tờ khách thật (CCCD, hộ chiếu) — dữ liệu giả lập.

## 5. User Needs

| ID | User Type | Need | Priority | Liên kết PRD |
|---|---|---|---|---|
| UN-check-in-out-01 | Lễ tân | Nhận phòng chỉ khi phòng sẵn sàng; bị chặn thì biết rõ lý do | P0 | §7.3 |
| UN-check-in-out-02 | Lễ tân | Ghi thông tin khách tối thiểu khi nhận, không rườm rà | P0 | §7.3 |
| UN-check-in-out-03 | Lễ tân | Trả phòng một thao tác — hệ thống tự báo việc dọn | P0 | §7.3 |
| UN-check-in-out-04 | Lễ tân | Xem danh sách phòng đang ở để chọn phòng trả | P0 | §7.3 |
| UN-check-in-out-05 | Lễ tân | Hủy nhận phòng nhầm trong cửa sổ ngắn, có vết nhật ký | P1 | §7.3 |
| UN-check-in-out-06 | Quản lý | Giám sát phòng đang ở + ai đã nhận/trả, khi nào | P0 | §7.3 + tôn chỉ nhật ký |
| UN-check-in-out-07 | Nhân viên buồng | Thấy phòng cần dọn ngay sau trả phòng | P0 | §7.3 (qua `housekeeping`) |
| UN-check-in-out-08 | Mọi vai trò | Trạng thái phòng cập nhật realtime — không cần hỏi lại | P0 | Tôn chỉ realtime |

## 6. Prioritized User Journeys

### J1 — Nhận phòng thành công (P0)

1. Lễ tân chọn phòng "sẵn sàng" → "Nhận phòng" → nhập tên khách + số người → xác nhận.
2. Hệ thống kiểm tra lại 3 điều kiện tại thời điểm ghi → tạo lượt lưu trú → lưu trú = "đang ở" → nhật ký + realtime.
3. Kết quả: phòng "đang ở" trên mọi màn; khách trong danh sách lưu trú.

### J2 — Nhận phòng bị chặn (P0)

1. Lễ tân chọn phòng không sẵn sàng → "Nhận phòng".
2. Hệ thống từ chối + lý do cụ thể: đang có khách / chưa dọn xong ({trạng thái}) / ngừng phục vụ.
3. Lễ tân chọn phòng khác hoặc chờ trạng thái đổi (realtime cập nhật).

### J3 — Trả phòng (P0)

1. Lễ tân mở danh sách đang ở → chọn phòng → "Trả phòng" → xác nhận.
2. Hệ thống đóng lượt lưu trú (mốc trả) → lưu trú = trống, vệ sinh = cần dọn → phát sự kiện trả phòng.
3. `housekeeping` tự tạo việc dọn; phòng xuất hiện ở nhóm cần dọn; nhân viên thấy việc mới.

### J4 — Hủy nhận phòng nhầm (P1)

1. Lễ tân nhận nhầm → trong cửa sổ ngắn chọn "Hủy nhận phòng" → xác nhận.
2. Lượt lưu trú đánh dấu hủy → lưu trú về trống, vệ sinh giữ trạng thái trước nhận — không việc dọn.
3. Nhật ký ghi rõ hủy nhầm; phòng lại "sẵn sàng".

## 7. User Exceptions & Edge Conditions

| Tình huống | Người dùng trông đợi |
|---|---|
| Nhận phòng đang ở / chưa sạch / ngừng phục vụ | Bị chặn với lý do cụ thể, không mơ hồ "không được" |
| Nhập thiếu tên khách/số người | Báo rõ trường thiếu, giữ form |
| Hai lễ tân cùng nhận một phòng | Một người thành công; người sau bị chặn khi tải lại — không double-booking |
| Trả phòng trên phòng không đang ở (trạng thái vừa đổi) | Bị từ chối + yêu cầu tải lại |
| Hủy nhận sau cửa sổ cho phép | Bị từ chối, hướng dẫn dùng "Trả phòng" |
| Phòng ngừng phục vụ nhưng đang có khách | Trả phòng bình thường; sau trả phòng vẫn ngừng phục vụ |
| Mất mạng khi xác nhận | Thao tác chưa lưu, được báo rõ; làm lại khi có mạng |
| Danh sách đang ở rỗng | Thấy trạng thái rỗng, không lỗi |

## 8. User-side Constraints

- Thiết bị: web tại quầy lễ tân; quản lý giám sát trên web; nhân viên thấy việc trên Android (qua `housekeeping`).
- Tiếng Việt; ~10 phiên đồng thời; realtime là kỳ vọng mặc định.
- Dữ liệu khách giả lập — không thu giấy tờ thật.
- Lễ tân cần thao tác nhanh tại quầy — nhận/trả phải là 1–2 bước xác nhận, không form dài.

## 9. Assumptions & Validation Needed

- Thông tin khách tối thiểu: tên khách + số người bắt buộc (OQ-1).
- Mỗi nhận phòng tạo 1 lượt lưu trú (phòng + khách + mốc nhận/trả).
- Trả phòng LUÔN đưa vệ sinh về "cần dọn" và phát sự kiện — bất kể tình trạng thực tế.
- Hủy nhận chỉ trong cửa sổ ngắn + chưa phát sinh hoạt động khác; không tạo việc dọn.
- Ngày dự kiến trả (P1) chỉ hiển thị — quá hạn thuộc `room-dashboard`.

## 10. User Success Criteria

| ID | Tiêu chí | Đo bằng |
|---|---|---|
| USC-check-in-out-01 | 0 khách được nhận vào phòng không sẵn sàng | UAT: mọi nhánh chặn đều báo lý do đúng |
| USC-check-in-out-02 | 100% trả phòng tạo việc dọn trong `housekeeping` | Kiểm tra sau mỗi lượt trả trong UAT |
| USC-check-in-out-03 | 0 double-booking trên cùng phòng | Kiểm thử đồng thời |
| USC-check-in-out-04 | Cập nhật trạng thái lan ≤3s sang thiết bị khác | Đo trong UAT, ≥95% lượt |
| USC-check-in-out-05 | Mọi nhận/trả/hủy có nhật ký ai/khi/phòng | Kiểm tra log máy chủ |

## 11. Open Questions

- [ ] OQ-1: Thông tin khách tối thiểu khi nhận phòng? (giả định: tên khách + số người; có cần liên hệ/CCCD giả lập không?)
- [ ] OQ-2: Cửa sổ hủy nhận phòng nhầm dài bao lâu? "Chưa phát sinh hoạt động khác" gồm những gì?
- [ ] OQ-3: Trả phòng có cần ghi chú tình trạng phòng không, hay hỏng hóc hoàn toàn thuộc `maintenance`?
- [ ] OQ-4: Lễ tân có xem được lịch sử lượt lưu trú đã đóng không, hay chỉ quản lý?

## 12. Next Steps

- `/brd check-in-out` — business case
- `/prd-epic check-in-out` — product scope
- `/srs check-in-out --spec-only` — core spec Tầng 1
