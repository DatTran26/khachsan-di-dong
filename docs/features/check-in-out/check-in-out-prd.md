---
type: prd
feature: check-in-out
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/check-in-out/check-in-out-brd.md|BRD — Check-in-out]]"
  - "[[docs/features/check-in-out/check-in-out-urd.md|URD — Check-in-out]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.3]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# PRD — Check-in-out

## 1. Overview

`check-in-out` là hai hành động vận hành lõi của lễ tân. Nhận phòng chỉ khi phòng sẵn sàng (trống + sạch + bình thường) — chặn kèm lý do cụ thể khi không thỏa; ghi thông tin khách tối thiểu và tạo lượt lưu trú. Trả phòng đóng lượt lưu trú, đưa phòng về trống + cần dọn, phát sự kiện trả phòng để `housekeeping` tự tạo việc dọn. Sprint 2, phụ thuộc `room-catalog` và `auth-roles`.

### Gap covered

Hôm nay lễ tân nhận khách vào phòng chưa chắc sẵn sàng (phải hỏi miệng buồng phòng) và trả phòng xong phải báo miệng để dọn — hay quên, phòng "treo" bẩn. Feature này thay thế quy trình báo miệng bằng chặn-điều-kiện + sự kiện tự động trên một nguồn trạng thái chung.

## 2. Goals & Non-Goals

### Goals

- 0 khách được nhận vào phòng không sẵn sàng — chặn cứng 3 điều kiện tại thời điểm ghi, lý do cụ thể.
- 100% trả phòng phát sinh việc dọn trong `housekeeping` — không phòng "treo" bẩn.
- Một nguồn sự thật lưu trú: lượt lưu trú + danh sách đang ở + nhật ký.
- 0 double-booking trên cùng phòng.

### Non-Goals

- Thanh toán/đặt cọc/giá/hóa đơn; đặt trước; giờ nhận/trả quy định.
- Cảnh báo quá hạn — `room-dashboard`; tạo/xử lý việc dọn — `housekeeping`; báo hỏng — `maintenance`; danh mục phòng — `room-catalog`.
- Giấy tờ khách thật — dữ liệu giả lập.
- AI quyết định nhận/trả phòng — AI chỉ tư vấn, không chạm dữ liệu nghiệp vụ.

## 3. Personas

| Persona | Vai trò | Cần gì từ feature |
|---|---|---|
| Lễ tân | Primary — người thực hiện | Nhận/trả nhanh tại quầy; chặn đúng + lý do rõ; hủy nhầm gọn |
| Quản lý | Giám sát | Danh sách đang ở + nhật ký lượt lưu trú; không thao tác nhận/trả |
| Nhân viên buồng–bảo trì | Downstream | Thấy việc dọn ngay sau trả phòng (qua `housekeeping`) |

## 4. Capabilities

| ID | Capability | P | Lý do | Sizing | Trace | Done when |
|---|---|---|---|---|---|---|
| CAP-check-in-out-01 | Nhận phòng: kiểm tra 3 điều kiện tại thời điểm ghi, chặn kèm lý do cụ thể | P0 | Loại bỏ rủi ro cốt lõi | M | BO-01, UN-01 | Mọi nhánh chặn (đang ở/chưa sạch/ngừng phục vụ) báo lý do đúng; phòng sẵn sàng nhận được |
| CAP-check-in-out-02 | Ghi thông tin khách tối thiểu + tạo lượt lưu trú | P0 | Một nguồn sự thật lưu trú | S | BO-03, UN-02 | Lượt lưu trú có phòng + khách (tên + số người) + mốc nhận; thiếu trường bị chặn |
| CAP-check-in-out-03 | Trả phòng: đóng lượt, trống + cần dọn, phát sự kiện trả phòng | P0 | Tự động bắt tay việc dọn | M | BO-02, UN-03 | Mỗi trả phòng → lượt đóng + vệ sinh "cần dọn" + sự kiện đến `housekeeping` |
| CAP-check-in-out-04 | Danh sách phòng đang ở + khách đang lưu trú | P0 | Cần để chọn phòng trả và giám sát | S | UN-04/06 | Danh sách realtime, rỗng có trạng thái rỗng |
| CAP-check-in-out-05 | Kiểm quyền server (chỉ lễ tân ghi) + nhật ký + realtime | P0 | Tôn chỉ | S | BREQ-06/07 | Quản lý/NV không ghi được; mọi lượt có vết; lan ≤3s |
| CAP-check-in-out-06 | Hủy nhận phòng nhầm trong cửa sổ ngắn | P1 | Sửa sai gọn có vết | S | UN-05, BO-03 | Trong cửa sổ + chưa phát sinh hoạt động → hủy được; không tạo việc dọn; nhật ký rõ hủy |
| CAP-check-in-out-07 | Ghi chú nhận phòng + ngày dự kiến trả (chỉ hiển thị) | P1 | Thông tin phụ cho quầy | S | P1 brainstorm | Lưu được, hiển thị trên lượt lưu trú; không xử lý quá hạn |

## 5. Success Metrics

| Metric | Target | Cách đo |
|---|---|---|
| Chặn nhận phòng không sẵn sàng | 100% lượt, lý do đúng trục | UAT mọi nhánh chặn |
| Trả phòng → việc dọn | 100% lượt | Kiểm tra `housekeeping` sau mỗi trả |
| Double-booking | 0 lượt mở đôi/phòng | Kiểm thử đồng thời |
| Realtime | ≥95% lượt ≤3s | Đo trong UAT |
| Nhật ký | 100% nhận/trả/hủy có vết | Kiểm tra log |

## 6. Dependencies (business only)

| Dependency | Chiều | Vai trò |
|---|---|---|
| `room-catalog` | Phụ thuộc | Đọc danh mục + 3 trục; nhận phòng kiểm tra trạng thái từ đây |
| `auth-roles` | Phụ thuộc | Kiểm tra quyền lễ tân cho mọi thao tác ghi |
| `housekeeping` | Bị phụ thuộc | Nhận sự kiện trả phòng để tự tạo việc dọn; chu trình dọn đưa phòng về "sạch" |
| `maintenance` | Liên quan | Đọc trục bảo trì để chặn nhận phòng khi "ngừng phục vụ" — không đổi trục này |
| `room-dashboard` | Downstream | Tiêu thụ trạng thái lưu trú + lượt lưu trú |

## 7. Assumptions

- Thông tin khách tối thiểu: tên khách + số người bắt buộc (OQ-1).
- Mỗi nhận phòng tạo 1 lượt lưu trú; trả phòng đóng lượt; hủy nhận đánh dấu hủy.
- Trả phòng luôn đưa vệ sinh về "cần dọn" + phát sự kiện — bất kể tình trạng thực tế.
- Hủy nhận chỉ trong cửa sổ ngắn + chưa phát sinh hoạt động khác; không tạo việc dọn.
- Ngày dự kiến trả chỉ hiển thị — quá hạn thuộc `room-dashboard`.

## 8. Risks

| Rủi ro | Mức | Giảm thiểu |
|---|---|---|
| Khách vào phòng chưa sẵn sàng | Cao | Chặn cứng 3 điều kiện tại thời điểm ghi + lý do |
| Trả phòng không tạo việc | Cao | Sự kiện bắt buộc; kiểm chứng liên kết `housekeeping` |
| Double-booking | Cao | Kiểm tra lại khi ghi; 1 lượt mở/phòng |
| Phụ thuộc `room-catalog` | Trung bình | Nghiệm thu Sprint 1 trước |

## 9. Release Plan

| Mốc | Nội dung |
|---|---|
| Sprint 2 (22/09–05/10) | Toàn bộ P0 + P1 — `check-in-out` cùng `housekeeping`/`maintenance` theo tôn chỉ |
| Sau Sprint 2 | `room-dashboard` + `room-dashboard` tiêu thụ trạng thái/lượt lưu trú |

## 10. Launch Readiness

- `room-catalog` + `auth-roles` đã nghiệm thu Sprint 1.
- UAT: mọi nhánh chặn báo lý do đúng; trả phòng → việc dọn xuất hiện; 0 double-booking.
- Liên kết `housekeeping` kiểm chứng: sự kiện trả phòng tạo việc dọn.
- OQ-1 chốt trước nghiệm thu thông tin khách tối thiểu.

## 11. Open Questions

- [ ] OQ-1: Thông tin khách tối thiểu khi nhận phòng?
- [ ] OQ-2: Cửa sổ hủy nhận phòng nhầm? Điều kiện "chưa phát sinh hoạt động khác"?
- [ ] OQ-3: Trả phòng có ghi chú tình trạng phòng không, hay hoàn toàn thuộc `maintenance`?
- [ ] OQ-4: Lễ tân xem được lịch sử lượt lưu trú đã đóng không, hay chỉ quản lý?
