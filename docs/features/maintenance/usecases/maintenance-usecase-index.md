---
type: usecase-index
feature: maintenance
status: draft
updated: 2026-09-17
links:
  - docs/features/maintenance/srs/maintenance-spec.md
---

# maintenance — Use Cases Index

## Use cases

> Bảng này là ma trận truy vết per-feature (UC↔FR↔Screen↔Error↔OQ).

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-bao-hong](uc-bao-hong.md) | sea | draft | Mọi vai trò | FR-maintenance-001, FR-maintenance-002, FR-maintenance-008, FR-maintenance-011 | form-bao-hong | E-maintenance-002, E-maintenance-003, E-maintenance-006 | — | P0 | 2026-09-17 |
| 2 | [uc-nhan-viec](uc-nhan-viec.md) | sea | draft | Nhân viên bảo trì | FR-maintenance-004, FR-maintenance-011 | danh-sach-viec, chi-tiet-viec | E-maintenance-001, E-maintenance-002, E-maintenance-004, E-maintenance-006 | — | P0 | 2026-09-17 |
| 3 | [uc-hoan-tat-viec](uc-hoan-tat-viec.md) | sea | draft | Nhân viên bảo trì | FR-maintenance-003, FR-maintenance-005, FR-maintenance-011 | chi-tiet-viec | E-maintenance-002, E-maintenance-004, E-maintenance-006 | — | P0 | 2026-09-17 |
| 4 | [uc-huy-viec](uc-huy-viec.md) | sea | draft | Người báo / Quản lý | FR-maintenance-003, FR-maintenance-006, FR-maintenance-011 | chi-tiet-viec | E-maintenance-002, E-maintenance-004, E-maintenance-006 | — | P0 | 2026-09-17 |
| 5 | [uc-dat-go-ngung](uc-dat-go-ngung.md) | sea | draft | Lễ tân / Quản lý | FR-maintenance-007, FR-maintenance-011 | dat-go-ngung | E-maintenance-002, E-maintenance-005, E-maintenance-006 | — | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | Phong | ViecBaoTri | NgungPhucVuTay | NguoiDung | NhatKy |
|---|---|---|---|---|---|
| [uc-bao-hong](uc-bao-hong.md) | RU | C | | R | C |
| [uc-nhan-viec](uc-nhan-viec.md) | R | RU | | R | C |
| [uc-hoan-tat-viec](uc-hoan-tat-viec.md) | RU | U | | R | C |
| [uc-huy-viec](uc-huy-viec.md) | RU | U | | R | C |
| [uc-dat-go-ngung](uc-dat-go-ngung.md) | RU | R | CU | R | C |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Mọi vai trò (người báo hỏng) | primary | Báo hỏng; hủy báo hỏng của mình khi chưa nhận | spec §2 |
| Nhân viên bảo trì | primary | Nhận việc, báo xong | spec §2 |
| Lễ tân | secondary | Báo hỏng; đặt/gỡ ngừng phục vụ tay | spec §2 |
| Quản lý | secondary | Giám sát; đặt/gỡ ngừng tay; hủy việc | spec §2 |
| Hệ thống | system | Tự đổi trục bảo trì, chặn nhận khách, phát realtime, ghi nhật ký | spec §2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-hoan-tat-viec | uc-bao-hong | Hoàn tất khép chu trình bắt đầu từ báo hỏng |
| extend | uc-huy-viec | uc-bao-hong | Hủy là nhánh kết thúc sớm khi báo nhầm |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/maintenance-spec.md|Maintenance SRS]]
- Screens: [[../ascii-wireframe/maintenance-wireframe-index.md|Screens index]]
- Open Questions: `srs/maintenance-spec.md` Mục Open Questions (canonical — chỉ trỏ ref `spec.md#OQ-N`)
