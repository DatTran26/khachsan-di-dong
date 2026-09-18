---
type: usecase-index
feature: room-dashboard
status: draft
updated: 2026-09-17
links:
  - docs/features/room-dashboard/srs/room-dashboard-spec.md
---

# room-dashboard — Use Cases Index

## Use cases

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-mo-va-xem-dashboard](uc-mo-va-xem-dashboard.md) | sea | draft | Quản lý, Lễ tân | FR-room-dashboard-001, FR-room-dashboard-002, FR-room-dashboard-003, FR-room-dashboard-004, FR-room-dashboard-008, FR-room-dashboard-010, FR-room-dashboard-011 | dashboard-tong-quan | E-room-dashboard-002, E-room-dashboard-003, E-room-dashboard-004 | spec.md#OQ-3, spec.md#OQ-4 | P0 | 2026-09-17 |
| 2 | [uc-theo-doi-realtime-va-qua-han](uc-theo-doi-realtime-va-qua-han.md) | sea | draft | Hệ thống / Người xem | FR-room-dashboard-005, FR-room-dashboard-006 | dashboard-tong-quan | — | spec.md#OQ-1 | P0 | 2026-09-17 |
| 3 | [uc-loc-phong](uc-loc-phong.md) | sea | draft | Quản lý, Lễ tân | FR-room-dashboard-007 | dashboard-tong-quan | E-room-dashboard-005 | spec.md#OQ-2 | P0 | 2026-09-17 |
| 4 | [uc-xu-ly-mat-ket-noi-dashboard](uc-xu-ly-mat-ket-noi-dashboard.md) | sea | draft | Người xem | FR-room-dashboard-009 | dashboard-tong-quan | E-room-dashboard-001 | — | P0 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | PhongView | ChiSoTongHop | CoQuaHan |
|---|---|---|---|
| [uc-mo-va-xem-dashboard](uc-mo-va-xem-dashboard.md) | R | R | R |
| [uc-theo-doi-realtime-va-qua-han](uc-theo-doi-realtime-va-qua-han.md) | R | R | R |
| [uc-loc-phong](uc-loc-phong.md) | R | R | R |
| [uc-xu-ly-mat-ket-noi-dashboard](uc-xu-ly-mat-ket-noi-dashboard.md) | R | R | R |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Quản lý | primary | Xem/lọc dashboard liên tục trong ca | spec §2 |
| Lễ tân | primary | Tham khảo read-only; khoanh phòng sẵn sàng | spec §2 |
| Hệ thống | system | Tải chỉ số, nhận realtime, hiển thị cờ quá hạn, báo kết nối | spec §2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-theo-doi-realtime-va-qua-han | uc-mo-va-xem-dashboard | Realtime cập nhật trên dashboard đã mở |
| extend | uc-xu-ly-mat-ket-noi-dashboard | uc-mo-va-xem-dashboard | Banner offline phủ mọi lúc đang xem |

## Nguồn dữ liệu

- FR + Error: [[../srs/room-dashboard-spec.md|Room Dashboard SRS]]
- OQ canonical: `srs/room-dashboard-spec.md` Mục 12
