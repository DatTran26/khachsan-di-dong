---
type: screen-index
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - docs/features/maintenance/srs/maintenance-spec.md
  - docs/features/maintenance/srs/maintenance-userflow.md
  - docs/features/maintenance/usecases/maintenance-usecase-index.md
---

# maintenance — Screens Index

> Chia flow theo `srs/maintenance-userflow.md`. ASCII mobile.

## Screens

| # | Slug | Status | Thuộc flow | Used by functions | Figma | HTML prototype | HTML wireframe | Updated |
|---|------|--------|-----------|--------------------|-------|----------------|----------------|---------|
| 1 | form-bao-hong | draft | [bao-hong](bao-hong.md) | uc-bao-hong | — | — | — | 2026-09-17 |
| 2 | danh-sach-viec | draft | [xu-ly-viec](xu-ly-viec.md) | uc-nhan-viec | — | — | — | 2026-09-17 |
| 3 | chi-tiet-viec | draft | [xu-ly-viec](xu-ly-viec.md) | uc-nhan-viec, uc-hoan-tat-viec, uc-huy-viec | — | — | — | 2026-09-17 |
| 4 | dat-go-ngung | draft | [dat-go-ngung](dat-go-ngung.md) | uc-dat-go-ngung | — | — | — | 2026-09-17 |

## Descriptions

### form-bao-hong
Form chọn phòng + mô tả bắt buộc + vị trí tùy chọn để gửi báo hỏng. Mọi vai trò đã đăng nhập dùng khi phát hiện hỏng.

### danh-sach-viec
Danh sách việc bảo trì theo trạng thái/phòng/người xử lý. NV bảo trì và quản lý dùng để chọn việc cần xử lý.

### chi-tiet-viec
Chi tiết một việc: nhận việc, báo xong, hủy (khi chờ nhận). NV bảo trì / người báo / quản lý tùy quyền.

### dat-go-ngung
Đặt ngừng phục vụ tay kèm lý do, hoặc gỡ tay khi hết việc mở. Lễ tân/quản lý dùng.

## Links upstream

* [[docs/features/maintenance/srs/maintenance-spec.md|SRS spec]]
* [[docs/features/maintenance/srs/maintenance-userflow.md|User flow]]
* [[docs/features/maintenance/usecases/maintenance-usecase-index.md|Use cases]]
