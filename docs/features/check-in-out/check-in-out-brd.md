---
type: brd
feature: check-in-out
status: draft
updated: 2026-09-17
links:
  - "[[docs/features/check-in-out/check-in-out-urd.md|URD — Check-in-out]]"
  - "[[docs/features/check-in-out/brainstorms/nhan-tra-phong.md|Brainstorm — Nhận/Trả phòng]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.3]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# BRD — Check-in-out

## 1. Executive Summary

`check-in-out` là hai hành động vận hành lõi của lễ tân: nhận phòng chỉ khi phòng sẵn sàng (trống + sạch + bình thường) và trả phòng để phòng về trống + cần dọn, tự phát sinh việc dọn cho `housekeeping`. Đây là điểm mà rủi ro cốt lõi của sản phẩm được loại bỏ — khách vào phòng chưa sẵn sàng — và là nguồn sự kiện khởi động chu trình dọn phòng. Nằm Sprint 2, phụ thuộc `room-catalog`.

## 2. Business Problems

| ID | Vấn đề | Hậu quả |
|---|---|---|
| BP-check-in-out-01 | Lễ tân nhận khách vào phòng chưa sẵn sàng vì không biết trạng thái thực (phải hỏi miệng buồng phòng) | Khách vào phòng bẩn/hỏng — rủi ro cốt lõi sản phẩm muốn loại bỏ; mất uy tín |
| BP-check-in-out-02 | Trả phòng xong phải báo miệng buồng phòng — hay quên | Phòng "treo" bẩn, không dọn kịp, không bán được cho khách sau |
| BP-check-in-out-03 | Không có ghi nhận khách đang ở phòng nào | Không tra được danh sách đang lưu trú; không truy vết ai nhận khách nào |
| BP-check-in-out-04 | Nhận nhầm phòng/khách không có cơ chế sửa gọn | Dữ liệu lưu trú sai; phải can thiệp tay |
| BP-check-in-out-05 | Hai lễ tân cùng nhận một phòng (đồng thời) | Double-booking — khách đụng phòng |

## 3. Current State vs Future State

| Khía cạnh | Hiện tại | Tương lai |
|---|---|---|
| Kiểm tra phòng sẵn sàng | Hỏi miệng buồng phòng | Hệ thống chặn cứng 3 điều kiện + lý do cụ thể |
| Ghi nhận khách | Sổ/giấy, nhập lại sau | Lượt lưu trú tạo ngay khi nhận — một nguồn sự thật |
| Báo buồng phòng sau trả | Báo miệng, hay quên | Trả phòng tự phát sự kiện → việc dọn tự tạo |
| Danh sách đang ở | Không có | Màn hình danh sách realtime cho lễ tân + quản lý |
| Nhận nhầm | Sửa tay, mất vết | Hủy nhận trong cửa sổ ngắn, giữ vết nhật ký |
| Đồng thời | Không kiểm soát | Kiểm tra điều kiện tại thời điểm ghi — chặn double-booking |

## 4. Gap Analysis

| Gap | Mô tả | Cách đóng |
|---|---|---|
| G1 | Không có cơ chế chặn nhận phòng chưa sẵn sàng | Kiểm tra 3 trục tại thời điểm ghi + chặn kèm lý do |
| G2 | Không có liên kết trả phòng → việc dọn | Trả phòng phát sự kiện → `housekeeping` tự tạo việc |
| G3 | Không có bản ghi lưu trú | Lượt lưu trú (phòng + khách + mốc nhận/trả) |
| G4 | Không có cách sửa nhận nhầm | Hủy nhận phòng trong cửa sổ (P1) |
| G5 | Không có nhật ký nhận/trả | Ghi ai/khi/phòng trên mọi lượt |

## 5. Stakeholders

| Stakeholder | Vai trò | Quan tâm chính |
|---|---|---|
| Lễ tân | Người thực hiện | Nhận/trả nhanh tại quầy; chặn đúng + lý do rõ |
| Quản lý | Giám sát | Danh sách đang ở, nhật ký lượt lưu trú; không thao tác nhận/trả |
| Nhân viên buồng–bảo trì | Downstream | Thấy việc dọn ngay sau trả phòng |
| Đội dự án | Người xây | Phụ thuộc `room-catalog` Sprint 1; scope đủ cho Sprint 2 |

## 6. Business Objectives

| ID | Mục tiêu | Đo lường |
|---|---|---|
| BO-check-in-out-01 | Không còn khách vào phòng chưa sẵn sàng | 100% lượt nhận vào phòng không sẵn sàng bị chặn |
| BO-check-in-out-02 | Không còn phòng "treo" bẩn sau trả | 100% trả phòng → việc dọn được tạo trong `housekeeping` |
| BO-check-in-out-03 | Một nguồn sự thật về lưu trú | Danh sách đang ở + nhật ký đầy đủ ai/khi/phòng |
| BO-check-in-out-04 | Không double-booking | 0 lượt lưu trú mở đôi trên cùng phòng |

## 7. Scope

### In scope

- Nhận phòng: kiểm tra 3 điều kiện tại thời điểm ghi; chặn kèm lý do cụ thể; ghi thông tin khách tối thiểu; tạo lượt lưu trú.
- Trả phòng: đóng lượt lưu trú; trống + cần dọn; phát sự kiện trả phòng cho `housekeeping`.
- Danh sách phòng đang ở + khách đang lưu trú theo phòng.
- Hủy nhận phòng nhầm trong cửa sổ ngắn (P1).
- Ghi chú khi nhận + ngày dự kiến trả chỉ-hiển-thị (P1).
- Kiểm quyền server (chỉ lễ tân ghi), nhật ký, realtime.

### Out of scope

- Thanh toán/đặt cọc/giá/hóa đơn; đặt trước; giờ nhận/trả quy định.
- Cảnh báo quá hạn — `room-dashboard`.
- Tạo/xử lý việc dọn — `housekeeping`; báo hỏng — `maintenance`; danh mục phòng — `room-catalog`.
- Giấy tờ khách thật — dữ liệu giả lập.

## 8. Business Requirements

| ID | Yêu cầu | Liên kết |
|---|---|---|
| BREQ-check-in-out-01 | Nhận phòng chỉ khi phòng trống + sạch + bình thường tại thời điểm ghi | BO-01, §7.3 |
| BREQ-check-in-out-02 | Khi chặn nhận phòng phải nêu lý do cụ thể theo trục vi phạm | BO-01 |
| BREQ-check-in-out-03 | Mỗi nhận phòng tạo 1 lượt lưu trú với thông tin khách tối thiểu + mốc thời gian | BO-03, §7.3 |
| BREQ-check-in-out-04 | Trả phòng → trống + cần dọn + phát sự kiện trả phòng cho `housekeeping` | BO-02, §7.3 |
| BREQ-check-in-out-05 | Không cho phép 2 lượt lưu trú mở trên cùng phòng | BO-04 |
| BREQ-check-in-out-06 | Chỉ lễ tân thực hiện nhận/trả/hủy; kiểm tra quyền ở máy chủ | Tôn chỉ phân quyền |
| BREQ-check-in-out-07 | Mọi nhận/trả/hủy ghi nhật ký ai/khi/phòng + lan realtime | Tôn chỉ |

## 9. Business Rules

- Điều kiện nhận phòng kiểm tra LẠI tại thời điểm ghi (không tin trạng thái hiển thị cũ) — chống double-booking và trạng thái vừa đổi.
- Lý do chặn phải cụ thể: "đang có khách" / "chưa dọn xong ({trạng thái})" / "ngừng phục vụ".
- Trả phòng LUÔN đưa vệ sinh về "cần dọn" và phát sự kiện — bất kể tình trạng thực tế.
- Hủy nhận phòng: chỉ trong cửa sổ ngắn + phòng chưa phát sinh hoạt động khác; không tạo việc dọn; giữ vết nhật ký.
- Phòng ngừng phục vụ nhưng đang có khách: trả phòng bình thường; sau trả vẫn ngừng phục vụ.
- Một phòng tối đa 1 lượt lưu trú mở tại mọi thời điểm.
- Quản lý không thực hiện nhận/trả phòng — chỉ giám sát.

## 10. Cost-Benefit

| Chi phí | Lợi ích |
|---|---|
| Sprint 2 của dự án 8 tuần — cùng housekeeping/maintenance | Loại bỏ rủi ro cốt lõi (khách vào phòng chưa sẵn sàng); tự động hóa bắt tay trả phòng → việc dọn; một nguồn sự thật lưu trú; nền cho `room-dashboard` + `room-dashboard` |

## 11. Risks

| Rủi ro | Khả năng | Tác động | Giảm thiểu |
|---|---|---|---|
| Khách vào phòng chưa sẵn sàng | thường | Cao — rủi ro cốt lõi | Chặn cứng 3 điều kiện tại thời điểm ghi |
| Trả phòng không tạo việc dọn | thỉnh thoảng | Cao — phòng treo bẩn | Phát sự kiện bắt buộc; kiểm chứng liên kết `housekeeping` |
| Double-booking | thỉnh thoảng | Cao | Kiểm tra lại điều kiện khi ghi; 1 lượt mở/phòng |
| Phụ thuộc `room-catalog` chưa kiểm chứng | thỉnh thoảng | Trung bình | `room-catalog` nghiệm thu Sprint 1 trước |
| Thông tin khách tối thiểu chưa chốt | thỉnh thoảng | Trung bình | OQ-1 chốt trước nghiệm thu |

## 12. Open Questions

- [ ] OQ-1: Thông tin khách tối thiểu khi nhận phòng?
- [ ] OQ-2: Cửa sổ hủy nhận phòng nhầm? Điều kiện "chưa phát sinh hoạt động khác"?
- [ ] OQ-3: Trả phòng có ghi chú tình trạng phòng không, hay hoàn toàn thuộc `maintenance`?
- [ ] OQ-4: Lễ tân xem được lịch sử lượt lưu trú đã đóng không, hay chỉ quản lý?

## 13. Next Steps

- `/prd-epic check-in-out` — product scope
- `/srs check-in-out --spec-only` — core spec Tầng 1
