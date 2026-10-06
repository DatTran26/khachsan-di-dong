---
type: prd
feature: room-catalog
status: draft
updated: 2026-09-25
links:
  - "[[docs/features/room-catalog/room-catalog-brd.md|BRD — Room Catalog]]"
  - "[[docs/features/room-catalog/room-catalog-urd.md|URD — Room Catalog]]"
  - "[[docs/_product/prd.md|PRD sản phẩm — Mục 7.2]]"
  - "[[Ton_Chi_Du_An_WPCTeam.txt|Tôn chỉ dự án]]"
---

# PRD — Room Catalog

## 1. Overview

`room-catalog` là danh mục phòng số hóa tập trung của khách sạn giả định 50 phòng — nguồn dữ liệu gốc cho mọi feature vận hành. Mỗi phòng mang 3 trục trạng thái riêng (lưu trú, vệ sinh, bảo trì); "sẵn sàng" là composite suy ra khi phòng trống + sạch + bình thường. Quản lý nhập và chỉnh danh mục; mọi vai trò tra cứu theo tầng/loại/trạng thái; thay đổi lan realtime và ghi nhật ký.

### Gap covered

Danh mục phòng hiện nằm rải trong sổ/Excel, không có nguồn số hóa tập trung — mọi cập nhật trạng thái và việc giao không có gì để bám vào. Feature này đóng gap đó trong Sprint 1.

## 2. Goals & Non-Goals

### Goals

- Danh mục 50 phòng giả lập đúng số/tầng/loại, một nguồn chung cho mọi vai trò.
- 3 trục trạng thái riêng biệt trên mỗi phòng — không trộn trục.
- Tra cứu/lọc nhanh theo tầng, loại, trạng thái — lễ tân thấy phòng "sẵn sàng" không cần hỏi buồng phòng.
- Mọi thay đổi danh mục có nhật ký truy vết và lan realtime.

### Non-Goals

- Giá phòng, hình ảnh, tiện nghi chi tiết, sơ đồ mặt bằng.
- Nhập từ file, đồng bộ PMS/OTA, nhiều khách sạn.
- Đổi trục lưu trú/vệ sinh trong catalog — thuộc `check-in-out`/`housekeeping`.
- Báo hỏng → ngừng phục vụ — thuộc `maintenance`.
- Dashboard trạng thái tổng quan — thuộc `room-dashboard`.

## 3. Personas

| Persona | Vai trò | Cần gì từ feature |
|---|---|---|
| Quản lý | Chủ danh mục | Nhập/chỉnh 50 phòng, đặt/gỡ ngừng phục vụ, truy vết thay đổi |
| Lễ tân | Người dùng hàng ngày | Tra cứu phòng theo tầng/trạng thái để nhận khách; đặt/gỡ ngừng phục vụ |
| Nhân viên buồng–bảo trì | Người dùng mobile | Tra thông tin phòng khi nhận việc |

## 4. Capabilities

| ID | Capability | P | Lý do | Sizing | Trace | Done when |
|---|---|---|---|---|---|---|
| CAP-room-catalog-01 | CRUD phòng (số duy nhất, tầng, loại) bởi quản lý | P0 | Nền tảng danh mục — không có thì không có feature nào | M | BO-01..03, UN-01..03 | Thêm/sửa/xóa phòng hoạt động; số trùng bị chặn; xóa sai điều kiện bị chặn kèm lý do |
| CAP-room-catalog-02 | 3 trục trạng thái riêng trên mỗi phòng + "sẵn sàng" composite | P0 | Ràng buộc lõi tôn chỉ — tránh nhầm lẫn trạng thái | M | BREQ-04, BP-03 | Mỗi phòng hiển thị 3 trục độc lập; "sẵn sàng" đúng khi trống+sạch+bình thường |
| CAP-room-catalog-03 | Tra cứu/lọc theo tầng, loại, trạng thái từng trục | P0 | Nhu cầu hàng ngày của lễ tân và nhân viên | M | UN-05, USC-05 | Lọc đúng điều kiện, hiển thị 3 trục, lọc rỗng có trạng thái rỗng |
| CAP-room-catalog-04 | Nhập danh mục ban đầu 50 phòng | P0 | Setup demo — không đủ phòng thì không nghiệm thu được | M | BO-01, UN-01 | Danh mục khớp dữ liệu giả lập 1-1 |
| CAP-room-catalog-05 | Realtime lan thay đổi + nhật ký mọi thay đổi | P0 | Yêu cầu tôn chỉ: một nguồn sự thật, kiểm toán được | M | BREQ-05..06, UN-06/09 | Thay đổi ≤3s trên thiết bị khác; nhật ký có ai/khi/trước→sau |
| CAP-room-catalog-06 | Đặt/gỡ "ngừng phục vụ" thủ công (quản lý + lễ tân) | P1 | Đóng phòng ngoài báo hỏng — thực tế vận hành | S | UN-04, BREQ-07 | Đặt được kèm lý do; phòng bị check-in chặn; gỡ được trở lại |
| CAP-room-catalog-07 | Tạo nhanh phòng theo dải | P1 | Giảm thời gian/sai sót nhập 50 phòng | S | UN-07, Risk-2 | Tạo dải hợp lệ, bỏ qua số trùng, báo rõ kết quả |
| CAP-room-catalog-08 | Danh mục loại phòng tự định nghĩa | P1 | Loại phòng là dữ liệu giả lập linh hoạt | S | UN-08, Assumption | Quản lý thêm/sửa/tắt loại; phòng chọn loại từ danh sách |

## 5. Success Metrics

| Metric | Target | Cách đo |
|---|---|---|
| Danh mục khớp dữ liệu giả lập | 50/50 phòng đúng số/tầng/loại | Đối chiếu nghiệm thu |
| Realtime lan thay đổi | ≥95% lượt ≤3s trên thiết bị khác | Đo trong UAT |
| Toàn vẹn danh mục | 0 số trùng, 0 xóa sai điều kiện | Kiểm thử dữ liệu |
| Nhật ký đầy đủ | 100% thay đổi có ai/khi/trước→sau | Kiểm tra log |
| Tra cứu thay hỏi buồng phòng | Lễ tân tra phòng "sẵn sàng" trong UAT không cần hỏi | Kịch bản UAT |

## 6. Dependencies (business only)

| Dependency | Feature phụ thuộc | Vai trò |
|---|---|---|
| `auth-roles` | — | Đăng nhập + phân quyền là điều kiện kiểm tra quyền ghi danh mục |
| `room-catalog` (feature này) | `check-in-out`, `housekeeping`, `maintenance`, `room-dashboard` | Mọi feature vận hành đọc danh mục phòng từ đây |

## 7. Assumptions

- Phòng mới mặc định trống + sạch + bình thường → "sẵn sàng" ngay.
- Loại phòng là danh mục quản lý tự định nghĩa (dữ liệu giả lập).
- Phòng có lịch sử không xóa cứng — rút khỏi vận hành qua "ngừng phục vụ".
- Lễ tân đặt/gỡ ngừng phục vụ theo project-profile; quyền thêm/sửa phòng của lễ tân đang mở (OQ-1).

## 8. Risks

| Rủi ro | Mức | Giảm thiểu |
|---|---|---|
| Danh mục sai → mọi nghiệp vụ lệch | Cao | Kiểm tra trùng số; nghiệm thu đối chiếu 50 phòng |
| Nhập 50 phòng chậm/sai | Trung bình | Tạo theo dải (CAP-07) |
| Quyền lễ tân chưa chốt | Trung bình | OQ-1 chốt trước nghiệm thu |

## 9. Release Plan

| Mốc | Nội dung |
|---|---|
| Sprint 1 (08/09–21/09) | Toàn bộ P0 + P1 — `room-catalog` nằm trong Sprint 1 theo tôn chỉ, cùng `auth-roles` và kiểm chứng realtime |
| Sau Sprint 1 | `check-in-out` và các feature sau dùng danh mục này |

## 10. Launch Readiness

- Danh mục 50 phòng nạp xong và đối chiếu khớp dữ liệu giả lập.
- Realtime kiểm chứng: thay đổi trên 1 thiết bị thấy trên thiết bị khác ≤3s.
- Nhật ký kiểm chứng: mọi thay đổi có vết trên máy chủ.
- OQ-1 chốt trước nghiệm thu phân quyền catalog.

## 11. Open Questions

- [x] OQ-1: Quyền của lễ tân với danh mục phòng — ✅ Resolved 2026-09-25 (chốt nhóm): chỉ **quản lý** thêm/sửa/xóa phòng và loại phòng; lễ tân tra cứu + đặt/gỡ ngừng phục vụ (FR-007/008).
- [ ] OQ-2: Cách nạp danh mục ban đầu 50 phòng — nhập tay, theo dải, hay nạp sẵn giả lập? Cho phép vượt 50?
- [ ] OQ-3: Quy ước đánh số phòng có bắt buộc không?
