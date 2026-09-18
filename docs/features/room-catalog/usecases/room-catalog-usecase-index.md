---
type: usecase-index
feature: room-catalog
status: draft
updated: 2026-09-17
links:
  - docs/features/room-catalog/srs/room-catalog-spec.md
---

# Room Catalog — Use Cases Index

## Use cases

> Bảng này là ma trận truy vết per-feature (UC↔FR↔Screen↔Error↔OQ) đồng thời là metadata/lifecycle — 1 nguồn duy nhất.

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-them-sua-xoa-phong](uc-them-sua-xoa-phong.md) | sea | draft | Quản lý | FR-room-catalog-001, FR-room-catalog-002, FR-room-catalog-003, FR-room-catalog-004, FR-room-catalog-012 | room-list, room-form | E-room-catalog-001, E-room-catalog-002, E-room-catalog-003, E-room-catalog-005, E-room-catalog-006, E-room-catalog-007 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 2 | [uc-tra-cuu-loc-phong](uc-tra-cuu-loc-phong.md) | sea | draft | Mọi vai trò | FR-room-catalog-005, FR-room-catalog-006 | room-list | — | — | P0 | 2026-09-17 |
| 3 | [uc-dat-go-ngung-phuc-vu](uc-dat-go-ngung-phuc-vu.md) | sea | draft | Quản lý, Lễ tân | FR-room-catalog-007, FR-room-catalog-008, FR-room-catalog-012 | room-list, stop-service-confirm | E-room-catalog-004, E-room-catalog-005, E-room-catalog-006, E-room-catalog-007 | — | P1 | 2026-09-17 |
| 4 | [uc-tao-phong-theo-dai](uc-tao-phong-theo-dai.md) | sea | draft | Quản lý | FR-room-catalog-009, FR-room-catalog-002 | room-list, bulk-create | E-room-catalog-005, E-room-catalog-007 | spec.md#OQ-2, spec.md#OQ-3 | P1 | 2026-09-17 |
| 5 | [uc-quan-ly-loai-phong](uc-quan-ly-loai-phong.md) | sea | draft | Quản lý | FR-room-catalog-010 | room-type-list, room-type-form | E-room-catalog-005, E-room-catalog-007 | — | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | Phong | LoaiPhong | NhatKyDanhMuc |
|---|---|---|---|
| [uc-them-sua-xoa-phong](uc-them-sua-xoa-phong.md) | CRUD | R | C |
| [uc-tra-cuu-loc-phong](uc-tra-cuu-loc-phong.md) | R | R | |
| [uc-dat-go-ngung-phuc-vu](uc-dat-go-ngung-phuc-vu.md) | U | | C |
| [uc-tao-phong-theo-dai](uc-tao-phong-theo-dai.md) | C | R | C |
| [uc-quan-ly-loai-phong](uc-quan-ly-loai-phong.md) | | CU | C |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Quản lý | primary | Thêm/sửa/xóa phòng, quản lý loại, đặt/gỡ ngừng phục vụ, tạo theo dải | SRS |
| Lễ tân | supporting | Tra cứu; đặt/gỡ ngừng phục vụ; thêm/sửa phòng đang mở (OQ-1) | SRS |
| Nhân viên buồng–bảo trì | supporting | Tra cứu danh mục | SRS |
| Hệ thống | system | Mặc định trạng thái phòng mới; nhật ký; realtime | SRS |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-them-sua-xoa-phong | uc-tra-cuu-loc-phong | Form thêm/sửa quay về danh sách đã lọc |
| extend | uc-dat-go-ngung-phuc-vu | uc-tra-cuu-loc-phong | Đặt/gỡ từ danh sách phòng |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/room-catalog-spec.md|Room Catalog SRS]]
- Screens: [[../ascii-wireframe/room-catalog-wireframe-index.md|Screens index]]
- Open Questions: `srs/room-catalog-spec.md` Mục Open Questions (chỉ ref `spec.md#OQ-N`)
