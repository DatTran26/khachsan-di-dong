---
type: usecase-index
feature: auth-roles
status: stale
updated: 2026-09-17
links:
  - docs/features/auth-roles/srs/auth-roles-spec.md
---

# Auth Roles — Use Cases Index

## Use cases

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-dang-nhap](uc-dang-nhap.md) | sea | draft | Nhân viên | FR-auth-roles-001,002,003,011,012,015 | login, force-change-password, home | E-auth-roles-001,002,003,004,011 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 2 | [uc-doi-mat-khau](uc-doi-mat-khau.md) | sea | draft | Nhân viên | FR-auth-roles-006,007,015 | change-password | E-auth-roles-005 | — | P0 | 2026-09-17 |
| 3 | [uc-quan-ly-tai-khoan](uc-quan-ly-tai-khoan.md) | sea | draft | Quản lý | FR-auth-roles-005,008,009,010,016,017 | account-list, account-form | E-auth-roles-006,007,008,009,010 | — | P0 | 2026-09-17 |
| 4 | [uc-xem-nhat-ky](uc-xem-nhat-ky.md) | sea | draft | Quản lý | FR-auth-roles-014 | audit-filter, audit-list | E-auth-roles-007 | — | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | TaiKhoanNhanVien | PhienDangNhap | NhatKyHoatDong |
|---|---|---|---|
| [uc-dang-nhap](uc-dang-nhap.md) | R/U | C/D | C |
| [uc-doi-mat-khau](uc-doi-mat-khau.md) | U | R | C |
| [uc-quan-ly-tai-khoan](uc-quan-ly-tai-khoan.md) | CRU | D | C |
| [uc-xem-nhat-ky](uc-xem-nhat-ky.md) | R | — | R |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Quản lý | primary | Quản lý TK, xem nhật ký | spec Actors |
| Lễ tân | primary | Đăng nhập để vận hành | spec Actors |
| Nhân viên buồng phòng–bảo trì | primary | Đăng nhập; việc giao tường minh (OQ-3) | spec Actors |
| Hệ thống | system | Lockout, hết phiên, nhật ký | spec Actors |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/auth-roles-spec.md|SRS spec]]
- Screens: [[../ascii-wireframe/auth-roles-wireframe-index.md|Screens index]]
