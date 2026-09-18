---
type: usecase-index
feature: check-in-out
status: draft
updated: 2026-09-17
links:
  - docs/features/check-in-out/srs/check-in-out-spec.md
---

# Check-in-out — Use Cases Index

## Use cases

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-nhan-phong](uc-nhan-phong.md) | sea | draft | Lễ tân | FR-check-in-out-001, FR-check-in-out-002, FR-check-in-out-003, FR-check-in-out-007, FR-check-in-out-008 | occupied-list, check-in-form | E-check-in-out-001, E-check-in-out-002, E-check-in-out-003, E-check-in-out-004, E-check-in-out-007, E-check-in-out-008 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 2 | [uc-tra-phong](uc-tra-phong.md) | sea | draft | Lễ tân | FR-check-in-out-004, FR-check-in-out-008 | occupied-list, check-out-confirm | E-check-in-out-005, E-check-in-out-007, E-check-in-out-008 | spec.md#OQ-3 | P0 | 2026-09-17 |
| 3 | [uc-xem-danh-sach-dang-o](uc-xem-danh-sach-dang-o.md) | sea | draft | Lễ tân, Quản lý | FR-check-in-out-005 | occupied-list | — | spec.md#OQ-4 | P0 | 2026-09-17 |
| 4 | [uc-huy-nhan-phong](uc-huy-nhan-phong.md) | sea | draft | Lễ tân | FR-check-in-out-006 | occupied-list, cancel-check-in-confirm | E-check-in-out-006, E-check-in-out-007, E-check-in-out-008 | spec.md#OQ-2 | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | LuotLuuTru | Phong | NhatKyLuuTru |
|---|---|---|---|
| [uc-nhan-phong](uc-nhan-phong.md) | C | U | C |
| [uc-tra-phong](uc-tra-phong.md) | U | U | C |
| [uc-xem-danh-sach-dang-o](uc-xem-danh-sach-dang-o.md) | R | R | |
| [uc-huy-nhan-phong](uc-huy-nhan-phong.md) | U | U | C |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Lễ tân | primary | Nhận/trả/hủy nhận; xem danh sách đang ở | SRS |
| Quản lý | supporting | Chỉ xem danh sách đang ở + nhật ký — không nhận/trả | SRS |
| Hệ thống | system | Kiểm điều kiện; tạo/đóng/hủy lượt; đổi trục; sự kiện; nhật ký; realtime | SRS |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-nhan-phong | uc-xem-danh-sach-dang-o | Sau nhận, danh sách đang ở cập nhật |
| include | uc-tra-phong | uc-xem-danh-sach-dang-o | Chọn phòng từ danh sách đang ở |
| extend | uc-huy-nhan-phong | uc-nhan-phong | Hủy trong cửa sổ ngắn sau nhận |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/check-in-out-spec.md|Check-in-out SRS]]
- Open Questions: chỉ ref `spec.md#OQ-N`
