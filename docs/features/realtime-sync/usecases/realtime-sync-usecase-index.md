---
type: usecase-index
feature: realtime-sync
status: draft
updated: 2026-09-17
links:
  - docs/features/realtime-sync/srs/realtime-sync-spec.md
---

# realtime-sync — Use Cases Index

## Use cases

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-lan-truyen-cap-nhat](uc-lan-truyen-cap-nhat.md) | sea | draft | Máy chủ / Thiết bị | FR-realtime-sync-001, FR-realtime-sync-002, FR-realtime-sync-009 | — | E-realtime-sync-004 | — | P0 | 2026-09-17 |
| 2 | [uc-xu-ly-xung-dot](uc-xu-ly-xung-dot.md) | sea | draft | Thiết bị người dùng | FR-realtime-sync-003, FR-realtime-sync-004 | thong-bao-xung-dot | E-realtime-sync-002 | spec.md#OQ-2 | P0 | 2026-09-17 |
| 3 | [uc-xu-ly-mat-ket-noi](uc-xu-ly-mat-ket-noi.md) | sea | draft | Thiết bị người dùng | FR-realtime-sync-005, FR-realtime-sync-006, FR-realtime-sync-007, FR-realtime-sync-010 | banner-ket-noi | E-realtime-sync-001, E-realtime-sync-003 | spec.md#OQ-1, spec.md#OQ-3 | P0 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | KetNoiThietBi | SuKienCapNhat | PhienBanDoiTuong | TrangThaiDoiTuong |
|---|---|---|---|---|
| [uc-lan-truyen-cap-nhat](uc-lan-truyen-cap-nhat.md) | R | C | U | RU |
| [uc-xu-ly-xung-dot](uc-xu-ly-xung-dot.md) | R | | R | R |
| [uc-xu-ly-mat-ket-noi](uc-xu-ly-mat-ket-noi.md) | RU | | | R |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Thiết bị người dùng | primary | Ghi kèm phiên bản; nhận sự kiện; báo mất kết nối; tải lại khi reconnect | spec §2 |
| Máy chủ | system | Kiểm quyền + phiên bản; lưu; tăng phiên bản; phát sự kiện | spec §2 |
| Mọi vai trò | secondary | Thụ hưởng cập nhật; được báo offline/xung đột | spec §2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| extend | uc-xu-ly-xung-dot | uc-lan-truyen-cap-nhat | Xung đột xảy ra khi ghi trước khi lan truyền bản mới |
| extend | uc-xu-ly-mat-ket-noi | uc-lan-truyen-cap-nhat | Mất kết nối tạm dừng nhận/ghi trong lúc lan truyền |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/realtime-sync-spec.md|Realtime-sync SRS]]
- Open Questions: `srs/realtime-sync-spec.md` Mục Open Questions (chỉ ref OQ-N)
