---
type: screen-index
feature: room-catalog
status: draft
updated: 2026-09-17
links:
  - docs/features/room-catalog/srs/room-catalog-spec.md
  - docs/features/room-catalog/srs/room-catalog-userflow.md
  - docs/features/room-catalog/usecases/room-catalog-usecase-index.md
---

# room-catalog — Screens Index

## Screens

| # | Slug | Status | Thuộc flow | Used by functions | Figma | HTML prototype | HTML wireframe | Updated |
|---|------|--------|-----------|--------------------|-------|----------------|----------------|---------|
| 1 | room-list | draft | [browse-rooms](browse-rooms.md), [manage-room](manage-room.md), [stop-service](stop-service.md), [bulk-create](bulk-create.md) | uc-tra-cuu-loc-phong, uc-them-sua-xoa-phong | — | — | — | 2026-09-17 |
| 2 | room-form | draft | [manage-room](manage-room.md) | uc-them-sua-xoa-phong | — | — | — | 2026-09-17 |
| 3 | stop-service-confirm | draft | [stop-service](stop-service.md) | uc-dat-go-ngung-phuc-vu | — | — | — | 2026-09-17 |
| 4 | bulk-create | draft | [bulk-create](bulk-create.md) | uc-tao-phong-theo-dai | — | — | — | 2026-09-17 |
| 5 | room-type-list | draft | [manage-room-type](manage-room-type.md) | uc-quan-ly-loai-phong | — | — | — | 2026-09-17 |
| 6 | room-type-form | draft | [manage-room-type](manage-room-type.md) | uc-quan-ly-loai-phong | — | — | — | 2026-09-17 |

## Descriptions

### room-list
Danh sách phòng + bộ lọc tầng/loại/3 trục; hiển thị "sẵn sàng" composite. Mọi vai trò.

### room-form
Form số phòng, tầng, loại phòng khi thêm/sửa. Quản lý (lễ tân — OQ-1).

### stop-service-confirm
Nhập lý do ngừng phục vụ; cảnh báo nếu phòng đang ở. Quản lý, lễ tân.

### bulk-create
Form tầng + khoảng số + loại để tạo nhiều phòng. Quản lý.

### room-type-list
Danh sách loại phòng đang dùng/ngừng. Quản lý.

### room-type-form
Thêm/sửa tên loại phòng. Quản lý.

## Links upstream

* [[../srs/room-catalog-spec.md|SRS spec]]
* [[../srs/room-catalog-userflow.md|User flow]]
* [[../usecases/room-catalog-usecase-index.md|Use cases]]
