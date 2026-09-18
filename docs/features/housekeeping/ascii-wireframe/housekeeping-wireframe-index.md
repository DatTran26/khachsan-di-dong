---
type: screen-index
feature: housekeeping
status: draft
updated: 2026-09-17
links:
  - docs/features/housekeeping/srs/housekeeping-spec.md
  - docs/features/housekeeping/srs/housekeeping-userflow.md
  - docs/features/housekeeping/usecases/housekeeping-usecase-index.md
---

# housekeeping — Screens Index

> Chia flow theo `srs/housekeeping-userflow.md`. ASCII mobile.

## Screens

| # | Slug | Status | Thuộc flow | Used by functions | Figma | HTML prototype | HTML wireframe | Updated |
|---|------|--------|-----------|--------------------|-------|----------------|----------------|---------|
| 1 | viec-cua-toi | draft | [xu-ly-viec](xu-ly-viec.md) | uc-nhan-tu-choi-viec | — | — | — | 2026-09-17 |
| 2 | chi-tiet-viec | draft | [xu-ly-viec](xu-ly-viec.md#screen-chi-tiet-viec--chi-tiết-công-việc) | uc-nhan-tu-choi-viec, uc-bao-hoan-tat, uc-xac-nhan-tra-lai | — | — | — | 2026-09-17 |
| 3 | hang-cho-xac-nhan | draft | [xac-nhan](xac-nhan.md) | uc-xac-nhan-tra-lai | — | — | — | 2026-09-17 |
| 4 | danh-sach-cong-viec | draft | [quan-ly-viec](quan-ly-viec.md) | uc-phan-cong-lai-va-loc, uc-canh-bao-qua-han | — | — | — | 2026-09-17 |

## Descriptions

### viec-cua-toi
Danh sách việc của NV buồng phòng: đã giao / đang làm / chờ xác nhận; nút nhận, từ chối; cờ quá hạn.

### chi-tiet-viec
Chi tiết một việc: số phòng, trạng thái, ghi chú trả lại (nếu có), thao tác theo trạng thái.

### hang-cho-xac-nhan
Hàng việc chờ xác nhận của quản lý; xác nhận hoặc trả lại kèm ghi chú bắt buộc.

### danh-sach-cong-viec
Toàn bộ việc + lọc NV/trạng thái/phòng; phân công lại; cảnh báo quá hạn.

## Links upstream

* [[docs/features/housekeeping/srs/housekeeping-spec.md|SRS spec]]
* [[docs/features/housekeeping/srs/housekeeping-userflow.md|User flow]]
* [[docs/features/housekeeping/usecases/housekeeping-usecase-index.md|Use cases]]
