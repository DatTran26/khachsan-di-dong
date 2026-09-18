---
type: usecase-index
feature: audit-log
status: draft
updated: 2026-09-17
links:
  - docs/features/audit-log/srs/audit-log-spec.md
---

# audit-log — Use Cases Index

## Use cases

> Ma trận truy vết per-feature (UC↔FR↔Screen↔Error↔OQ). OQ canonical ở `srs/audit-log-spec.md`.

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-ghi-ban-ghi-nhat-ky](uc-ghi-ban-ghi-nhat-ky.md) | sea | draft | Hệ thống | FR-audit-log-001, FR-audit-log-002, FR-audit-log-003, FR-audit-log-004, FR-audit-log-005, FR-audit-log-006, FR-audit-log-012 | — | E-audit-log-005 | — | P0 | 2026-09-17 |
| 2 | [uc-xem-nhat-ky-theo-phong](uc-xem-nhat-ky-theo-phong.md) | sea | draft | Quản lý | FR-audit-log-007, FR-audit-log-009, FR-audit-log-011 | nhat-ky-theo-phong | E-audit-log-001, E-audit-log-003, E-audit-log-004 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 3 | [uc-loc-nhat-ky](uc-loc-nhat-ky.md) | sea | draft | Quản lý | FR-audit-log-008, FR-audit-log-011 | nhat-ky-theo-phong, nhat-ky-chung | E-audit-log-001, E-audit-log-002, E-audit-log-003, E-audit-log-004 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 4 | [uc-xem-nhat-ky-chung](uc-xem-nhat-ky-chung.md) | sea | draft | Quản lý | FR-audit-log-010, FR-audit-log-011 | nhat-ky-chung | E-audit-log-001, E-audit-log-003, E-audit-log-004 | spec.md#OQ-1 | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | BanGhiNhatKy | ChiTietThayDoi |
|---|---|---|
| [uc-ghi-ban-ghi-nhat-ky](uc-ghi-ban-ghi-nhat-ky.md) | C | C |
| [uc-xem-nhat-ky-theo-phong](uc-xem-nhat-ky-theo-phong.md) | R | R |
| [uc-loc-nhat-ky](uc-loc-nhat-ky.md) | R | R |
| [uc-xem-nhat-ky-chung](uc-xem-nhat-ky-chung.md) | R | R |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Quản lý | primary | Xem/lọc nhật ký theo phòng và toàn hệ thống; truy vết khi tranh chấp | SRS Mục 2 |
| Nhân viên các vai trò | supporting | Chủ thể được ghi khi thao tác ghi — không có màn nhật ký | SRS Mục 2 |
| Hệ thống | system | Tự sinh bản ghi khi thao tác ghi hoàn tất; actor "hệ thống" cho hành động tự động | SRS Mục 2 |
| ai-ops-summary | system | Đọc bản ghi để tổng hợp theo kỳ (ngoài phạm vi ghi/xem của feature này) | SRS Mục 2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-loc-nhat-ky | uc-xem-nhat-ky-theo-phong | Lọc thu hẹp kết quả trên cùng màn nhật ký theo phòng |
| include | uc-loc-nhat-ky | uc-xem-nhat-ky-chung | Lọc mở rộng áp dụng trên màn nhật ký chung (P1) |
| extend | uc-xem-nhat-ky-chung | uc-xem-nhat-ky-theo-phong | Nhật ký chung mở rộng phạm vi ngoài phòng (auth, đối tượng khác) |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/audit-log-spec.md|audit-log SRS]]
- Screens: [[../ascii-wireframe/audit-log-wireframe-index.md|Screens index]]
- Open Questions: `srs/audit-log-spec.md` Mục 12 (OQ-1, OQ-2)
- Ranh giới với `auth-roles`: FR-auth-roles-013/014 định nghĩa ghi sự kiện auth + màn xem cơ bản; feature này là nhật ký vận hành chuyên sâu (trục trạng thái, bất biến, nguồn cho `ai-ops-summary`) — không mâu thuẫn quyền chỉ quản lý / không ghi mật khẩu.
