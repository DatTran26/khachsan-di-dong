---
type: screen-index
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - docs/features/audit-log/srs/audit-log-spec.md
  - docs/features/audit-log/srs/audit-log-userflow.md
  - docs/features/audit-log/usecases/audit-log-usecase-index.md
---

# audit-log — Screens Index

## Screens

| # | Slug | Status | Thuộc flow | Used by functions | Figma | HTML prototype | HTML wireframe | Updated |
|---|------|--------|-----------|--------------------|-------|----------------|----------------|---------|
| 1 | nhat-ky-theo-phong | draft | [xem-theo-phong](xem-theo-phong.md#screen-nhat-ky-theo-phong--nhật-ký-theo-phòng) | uc-xem-nhat-ky-theo-phong, uc-loc-nhat-ky | — | — | — | 2026-09-17 |
| 2 | nhat-ky-chung | draft | [xem-nhat-ky-chung](xem-nhat-ky-chung.md#screen-nhat-ky-chung--nhật-ký-chung) | uc-xem-nhat-ky-chung, uc-loc-nhat-ky | — | — | — | 2026-09-17 |

## Descriptions

### nhat-ky-theo-phong

Dòng thời gian bản ghi của một phòng (mới nhất trước); mỗi dòng đủ ai/khi/hành động/trục/trước→sau; bộ lọc thời gian và vai trò/người (gồm "hệ thống"). Quản lý thấy khi mở nhật ký từ phòng.

### nhat-ky-chung

Nhật ký toàn hệ thống gồm sự kiện không gắn phòng; lọc thêm loại hành động, trục, loại đối tượng. Quản lý thấy khi mở mục Nhật ký chung (P1 / FR-audit-log-010).

## Links upstream

* [[../srs/audit-log-spec.md|SRS spec]]
* [[../srs/audit-log-userflow.md|User flow]]
* [[../usecases/audit-log-usecase-index.md|Use cases]]
