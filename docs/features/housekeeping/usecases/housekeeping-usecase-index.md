---
type: usecase-index
feature: housekeeping
status: draft
updated: 2026-09-17
links:
  - docs/features/housekeeping/srs/housekeeping-spec.md
---

# housekeeping — Use Cases Index

## Use cases

> Bảng này là ma trận truy vết per-feature (UC↔FR↔Screen↔Error↔OQ).

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-tao-giao-viec-sau-tra-phong](uc-tao-giao-viec-sau-tra-phong.md) | sea | draft | Hệ thống | FR-housekeeping-001, FR-housekeeping-002, FR-housekeeping-003, FR-housekeeping-013 | danh-sach-cong-viec | E-housekeeping-002 | spec.md#OQ-1 | P0 | 2026-09-17 |
| 2 | [uc-nhan-tu-choi-viec](uc-nhan-tu-choi-viec.md) | sea | draft | Nhân viên buồng phòng | FR-housekeeping-004, FR-housekeeping-011, FR-housekeeping-012, FR-housekeeping-013 | viec-cua-toi, chi-tiet-viec | E-housekeeping-001, E-housekeeping-003, E-housekeeping-004, E-housekeeping-006 | — | P0 | 2026-09-17 |
| 3 | [uc-nop-anh-nghiem-thu](uc-nop-anh-nghiem-thu.md) | sea | draft | Nhân viên buồng phòng | FR-housekeeping-005, FR-housekeeping-006, FR-housekeeping-007 | chi-tiet-viec, anh-nghiem-thu | E-housekeeping-007 | OQ-4 | P0 | 2026-09-26 |
| 4 | [uc-bao-hoan-tat](uc-bao-hoan-tat.md) | sea | draft | Nhân viên buồng phòng | FR-housekeeping-005, FR-housekeeping-006, FR-housekeeping-013, FR-housekeeping-014, FR-housekeeping-015 | chi-tiet-viec, anh-nghiem-thu | E-housekeeping-003, E-housekeeping-004, E-housekeeping-006, E-housekeeping-007 | — | P0 | 2026-09-26 |
| 5 | [uc-xac-nhan-tra-lai](uc-xac-nhan-tra-lai.md) | sea | draft | Quản lý | FR-housekeeping-007, FR-housekeeping-008, FR-housekeeping-009, FR-housekeeping-013, FR-housekeeping-015 | hang-cho-xac-nhan, chi-tiet-viec, anh-nghiem-thu | E-housekeeping-003, E-housekeeping-004, E-housekeeping-005, E-housekeeping-006 | — | P0 | 2026-09-26 |
| 5 | [uc-canh-bao-qua-han](uc-canh-bao-qua-han.md) | sea | draft | Hệ thống | FR-housekeeping-008 | danh-sach-cong-viec, viec-cua-toi | — | spec.md#OQ-2, spec.md#OQ-3 | P0 | 2026-09-17 |
| 6 | [uc-phan-cong-lai-va-loc](uc-phan-cong-lai-va-loc.md) | sea | draft | Quản lý | FR-housekeeping-009, FR-housekeeping-010, FR-housekeeping-013 | danh-sach-cong-viec | E-housekeeping-003, E-housekeeping-006 | — | P1 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | Phong | ViecDonPhong | NguoiDung | NhatKy |
|---|---|---|---|---|
| [uc-tao-giao-viec-sau-tra-phong](uc-tao-giao-viec-sau-tra-phong.md) | RU | C | R | C |
| [uc-nhan-tu-choi-viec](uc-nhan-tu-choi-viec.md) | RU | RU | R | C |
| [uc-nop-anh-nghiem-thu](uc-nop-anh-nghiem-thu.md) | R | RU | R | C |
| [uc-bao-hoan-tat](uc-bao-hoan-tat.md) | RU | U | R | C |
| [uc-xac-nhan-tra-lai](uc-xac-nhan-tra-lai.md) | RU | U | R | C |
| [uc-canh-bao-qua-han](uc-canh-bao-qua-han.md) | R | U | R | C |
| [uc-phan-cong-lai-va-loc](uc-phan-cong-lai-va-loc.md) | R | RU | R | C |

## Actors

| Actor | Loại | Mô tả | Nguồn |
|---|---|---|---|
| Nhân viên buồng phòng | primary | Nhận/từ chối/báo hoàn tất việc được giao | spec §2 |
| Quản lý | primary | Xác nhận/trả lại; phân công lại; theo dõi quá hạn | spec §2 |
| Lễ tân | secondary | Xem trạng thái "sẵn sàng" (read-only trong feature này) | spec §2 |
| Hệ thống | system | Tạo việc, tự giao, đánh cờ quá hạn, ghi nhật ký, phát realtime | spec §2 |
| Feature nhận/trả phòng | system | Nguồn sự kiện trả phòng | spec §2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| include | uc-bao-hoan-tat | uc-nhan-tu-choi-viec | Báo hoàn tất sau khi đã nhận |
| include | uc-xac-nhan-tra-lai | uc-bao-hoan-tat | Xác nhận khép chu trình sau báo hoàn tất |
| extend | uc-canh-bao-qua-han | uc-tao-giao-viec-sau-tra-phong | Cờ quá hạn bám mốc tạo việc |

## Nguồn dữ liệu

- FR + Error Matrix: [[../srs/housekeeping-spec.md|Housekeeping SRS]]
- Screens: [[../ascii-wireframe/housekeeping-wireframe-index.md|Screens index]]
- Open Questions: `srs/housekeeping-spec.md` Mục Open Questions (canonical — chỉ trỏ ref `spec.md#OQ-N`)
