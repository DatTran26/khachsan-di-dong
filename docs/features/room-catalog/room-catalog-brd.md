---
type: brd
feature: room-catalog
status: draft
updated: 2026-09-25
links:
  - "[[docs/features/room-catalog/room-catalog-urd.md|URD — Room Catalog]]"
  - "[[docs/features/room-catalog/brainstorms/danh-muc-phong.md|Brainstorm — Danh mục phòng]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.2]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# BRD — Room Catalog

## 1. Executive Summary

`room-catalog` cung cấp danh mục phòng số hóa tập trung — nguồn dữ liệu gốc mà mọi trạng thái phòng và thao tác vận hành (`check-in-out`, `housekeeping`, `maintenance`, `room-dashboard`) bám vào. Không có danh mục này, không feature vận hành nào chạy được: không có phòng để nhận khách, không có phòng để giao việc, không có phòng để vẽ dashboard. Đây là feature Sprint 1, điều kiện tiên quyết cho toàn bộ MVP.

## 2. Business Problems

| ID | Vấn đề | Hậu quả |
|---|---|---|
| BP-room-catalog-01 | Danh mục phòng không tồn tại ở dạng số hóa tập trung; nằm rải trong sổ/Excel/đầu quản lý | Không có nguồn sự thật chung — mỗi vai trò làm việc trên bản danh mục khác nhau, lệch nhau |
| BP-room-catalog-02 | Thông tin phòng (tầng, loại, trạng thái) không tra được tập trung | Lễ tân phải hỏi buồng phòng để biết phòng sẵn sàng — quy trình báo miệng rời rạc mà sản phẩm muốn thay thế |
| BP-room-catalog-03 | Không có cấu trúc phòng chuẩn cho 3 trục trạng thái riêng | Trộn trạng thái → nhầm lẫn (phòng đang ở bị tưởng chưa dọn, v.v.) — vi phạm ràng buộc lõi tôn chỉ |
| BP-room-catalog-04 | Thay đổi danh mục không được ghi nhật ký | Không truy vết được ai đổi gì — vi phạm yêu cầu kiểm toán tôn chỉ |

## 3. Current State vs Future State

| Khía cạnh | Hiện tại | Tương lai (với feature này) |
|---|---|---|
| Danh mục phòng | Sổ/Excel rời, không nhất quán | Danh mục số hóa tập trung, 50 phòng giả lập, mọi vai trò cùng nhìn một nguồn |
| Thông tin phòng | Phải hỏi/kiểm tra thực tế | Tra cứu/lọc theo tầng, loại, trạng thái từng trục |
| Trạng thái phòng | Một trạng thái chung, dễ nhầm | 3 trục riêng (lưu trú/vệ sinh/bảo trì) trên mỗi phòng |
| Thay đổi danh mục | Không vết | Nhật ký ai/khi/trước→sau, lan realtime |
| Đóng phòng ngoài báo hỏng | Không có cơ chế | "Ngừng phục vụ" thủ công kèm lý do |

## 4. Gap Analysis

| Gap | Mô tả | Cách đóng |
|---|---|---|
| G1 | Chưa có danh mục số hóa | CRUD phòng + nhập danh mục ban đầu 50 phòng |
| G2 | Chưa có mô hình 3 trục | Mỗi phòng mang 3 trục riêng; "sẵn sàng" là composite suy ra |
| G3 | Chưa có tra cứu cho các vai trò | Lọc theo tầng/loại/trạng thái, realtime |
| G4 | Chưa có cơ chế đóng phòng thủ công | Đặt/gỡ "ngừng phục vụ" (P1) |
| G5 | Chưa có nhật ký danh mục | Ghi ai/khi/trước→sau trên mọi thay đổi |

## 5. Stakeholders

| Stakeholder | Vai trò | Quan tâm chính |
|---|---|---|
| Quản lý | Chủ danh mục | Danh mục khớp thực tế; truy vết thay đổi |
| Lễ tân | Người dùng hàng ngày | Tra phòng "sẵn sàng" nhanh để nhận khách |
| Nhân viên buồng–bảo trì | Người dùng hàng ngày | Biết phòng ở đâu, loại gì khi nhận việc |
| Đội dự án (3 người) | Người xây | Scope đủ nhỏ cho Sprint 1; là nền cho 4 feature sau |

## 6. Business Objectives

| ID | Mục tiêu | Đo lường |
|---|---|---|
| BO-room-catalog-01 | Danh mục phòng khớp thực tế khách sạn giả lập | 50/50 phòng đúng số/tầng/loại khi nghiệm thu |
| BO-room-catalog-02 | Mọi vai trò làm việc trên một nguồn danh mục chung | Cập nhật lan realtime ≤3s trên mọi màn |
| BO-room-catalog-03 | Không còn sai lệch danh mục gây lệch nghiệp vụ | 0 số phòng trùng; 0 xóa sai điều kiện; 100% thay đổi có nhật ký |
| BO-room-catalog-04 | Nền dữ liệu sẵn sàng cho `check-in-out` | Sprint 2 nhận phòng trên danh mục này không phát sinh lỗi dữ liệu |

## 7. Scope

### In scope

- Danh mục 50 phòng giả lập: số phòng (duy nhất), tầng, loại phòng (từ danh mục loại quản lý định nghĩa).
- CRUD phòng bởi quản lý; xóa có điều kiện (chặn khi đang ở/đang dọn/có việc mở/đã có lịch sử → hướng dẫn "ngừng phục vụ").
- 3 trục trạng thái riêng trên mỗi phòng; "sẵn sàng" là composite.
- Tra cứu/lọc theo tầng/loại/trạng thái cho mọi vai trò.
- Đặt/gỡ "ngừng phục vụ" thủ công (quản lý + lễ tân).
- Tạo nhanh theo dải (P1); nhật ký mọi thay đổi; realtime.

### Out of scope

- Giá phòng, hình ảnh, tiện nghi, sơ đồ mặt bằng (non-goal PRD).
- Nhập từ file, đồng bộ PMS/OTA, nhiều khách sạn (non-goal dự án).
- Thay đổi trục lưu trú/vệ sinh — thuộc `check-in-out`/`housekeeping`.
- Báo hỏng → ngừng phục vụ — thuộc `maintenance`.
- Dashboard tổng quan — thuộc `room-dashboard`.

## 8. Business Requirements

| ID | Yêu cầu | Liên kết |
|---|---|---|
| BREQ-room-catalog-01 | Danh mục phải đủ 50 phòng khớp dữ liệu giả lập trước khi vận hành demo | BO-01, §7.2 |
| BREQ-room-catalog-02 | Số phòng duy nhất toàn danh mục, kiểm tra cả khi sửa | BO-03 |
| BREQ-room-catalog-03 | Không xóa phòng đang vận hành hoặc đã có lịch sử; rút khỏi vận hành qua "ngừng phục vụ" | BO-03, tôn chỉ nhật ký |
| BREQ-room-catalog-04 | 3 trục trạng thái lưu trú/vệ sinh/bảo trì riêng biệt trên mỗi phòng — không trộn | BO-02, tôn chỉ |
| BREQ-room-catalog-05 | Mọi thay đổi danh mục ghi nhật ký ai/khi/trước→sau | BO-03, tôn chỉ |
| BREQ-room-catalog-06 | Cập nhật danh mục lan realtime tới mọi thiết bị ≤3s | BO-02, tôn chỉ realtime |
| BREQ-room-catalog-07 | Quyền ghi danh mục theo vai trò (quản lý; lễ tân theo OQ-1) | Tôn chỉ phân quyền |

## 9. Business Rules

- Số phòng là định danh hiển thị duy nhất — bắt buộc, không trùng, kiểm tra cả khi sửa.
- Phòng mới tạo mặc định trống + sạch + bình thường → hiển thị "sẵn sàng" ngay.
- Phòng đang ở / đang dọn / có việc mở: không xóa được.
- Phòng đã có lịch sử hoạt động: không xóa cứng; rút khỏi vận hành qua "ngừng phục vụ" kèm lý do bắt buộc.
- Trục lưu trú và vệ sinh không sửa tay trong catalog — chỉ đổi qua `check-in-out` và `housekeeping`.
- "Ngừng phục vụ" đặt tay kèm lý do; phòng ngừng phục vụ bị `check-in-out` chặn nhận khách.
- Đặt ngừng phục vụ phòng đang có khách: cho phép sau cảnh báo — khách ở hết kỳ, phòng chỉ đóng nhận khách mới.
- Mọi thay đổi danh mục kiểm tra quyền server và ghi nhật ký.

## 10. Cost-Benefit

| Chi phí | Lợi ích |
|---|---|
| Sprint 1 của dự án 8 tuần, 3 người ~20h/người/tuần — feature nền tảng bắt buộc | Là điều kiện để 4 feature vận hành sau chạy; thay thế danh mục giấy rời rạc bằng nguồn chung; bảo toàn nhật ký truy vết |

## 11. Risks

| Rủi ro | Khả năng | Tác động | Giảm thiểu |
|---|---|---|---|
| Danh mục nhập sai → mọi trạng thái/việc/dashboard lệch | thường | Cao — rủi ro chính theo PRD | Kiểm tra trùng số; nghiệm thu đối chiếu đủ 50 phòng |
| Nhập tay 50 phòng chậm/dễ sai | thường | Trung bình | Tạo theo dải (P1); đối soát danh mục |
| Quyền catalog của lễ tân chưa đồng nhất giữa tài liệu | thỉnh thoảng | Trung bình — lễ tân sửa danh mục ngoài ý quản lý | OQ-1 chốt trước nghiệm thu |
| Vòng đời xóa phòng chưa rõ (xóa cứng vs ngừng phục vụ) | thỉnh thoảng | Trung bình — mất vết nếu xóa cứng tùy ý | Rule chặn xóa cứng khi có lịch sử |

## 12. Open Questions

- [x] OQ-1: Quyền của lễ tân với danh mục phòng — ✅ Resolved 2026-09-25 (chốt nhóm): chỉ **quản lý** thêm/sửa/xóa phòng và loại phòng; lễ tân tra cứu + đặt/gỡ ngừng phục vụ (FR-007/008).
- [ ] OQ-2: Cách nạp danh mục ban đầu 50 phòng — nhập tay, theo dải, hay nạp sẵn giả lập? Cho phép vượt 50?
- [ ] OQ-3: Quy ước đánh số phòng có bắt buộc không?

## 13. Next Steps

- `/prd-epic room-catalog` — product scope
- `/srs room-catalog --spec-only` — core spec Tầng 1
