---
type: usecase-index
feature: ai-ops-summary
status: draft
updated: 2026-09-17
links:
  - docs/features/ai-ops-summary/srs/ai-ops-summary-spec.md
---

# ai-ops-summary — Use Cases Index

## Use cases

| # | Slug | Level | Status | Actor primary | Covers FR | Screens | Errors (E-*) | OQ ref | Priority | Updated |
|---|------|-------|--------|---------------|-----------|---------|--------------|--------|----------|---------|
| 1 | [uc-tao-tom-tat-van-hanh](uc-tao-tom-tat-van-hanh.md) | sea | draft | Quan ly | FR-ai-ops-summary-001, FR-ai-ops-summary-002, FR-ai-ops-summary-003, FR-ai-ops-summary-004, FR-ai-ops-summary-005, FR-ai-ops-summary-006, FR-ai-ops-summary-007, FR-ai-ops-summary-008, FR-ai-ops-summary-009, FR-ai-ops-summary-010, FR-ai-ops-summary-011, FR-ai-ops-summary-014 | tom-tat-van-hanh | E-ai-ops-summary-001, E-ai-ops-summary-002, E-ai-ops-summary-003, E-ai-ops-summary-004, E-ai-ops-summary-005, E-ai-ops-summary-006, E-ai-ops-summary-007 | spec.md#OQ-1, OQ-2, OQ-3, OQ-5 | P0 | 2026-09-17 |
| 2 | [uc-dieu-phoi-viec-can-chu-y](uc-dieu-phoi-viec-can-chu-y.md) | sea | draft | Quan ly | FR-ai-ops-summary-012 | tom-tat-van-hanh | E-ai-ops-summary-006 | — | P1 | 2026-09-17 |
| 3 | [uc-xem-lai-tom-tat-gan-nhat](uc-xem-lai-tom-tat-gan-nhat.md) | sea | draft | Quan ly | FR-ai-ops-summary-013 | tom-tat-van-hanh | E-ai-ops-summary-006 | spec.md#OQ-4 | P1 | 2026-09-17 |
| 4 | [uc-chan-truy-cap-sai-quyen](uc-chan-truy-cap-sai-quyen.md) | sea | draft | He thong | FR-ai-ops-summary-011 | tom-tat-van-hanh | E-ai-ops-summary-006 | — | P0 | 2026-09-17 |

## CRUD matrix

| UC \ Entity | BanTomTatKy | HanMucAI | SoLieuTongHopKy |
|---|---|---|---|
| uc-tao-tom-tat-van-hanh | CR | RU | R |
| uc-dieu-phoi-viec-can-chu-y | R | | R |
| uc-xem-lai-tom-tat-gan-nhat | R | | |
| uc-chan-truy-cap-sai-quyen | | | |

## Actors

| Actor | Loai | Mo ta | Nguon |
|---|---|---|---|
| Quan ly | primary | Chon ky, tao, doc tom tat/bao cao mau, dieu phoi viec can chu y | SRS Muc 2 |
| He thong | system | Chot T, tinh so lieu, goi AI, kiem dau ra, han muc, ghi nhat ky luot tao | SRS Muc 2 |
| Dich vu LLM | ngoai | Tra tom tat co cau truc — vendor OQ-3 | SRS Muc 2 |

## Relationships

| Type | From | To | Rationale |
|---|---|---|---|
| extend | uc-dieu-phoi-viec-can-chu-y | uc-tao-tom-tat-van-hanh | Muc can chu y nam tren ban tom tat/bao cao mau |
| extend | uc-xem-lai-tom-tat-gan-nhat | uc-tao-tom-tat-van-hanh | Chi khi OQ-4 chot luu |

## Nguon du lieu

- SRS: [[../srs/ai-ops-summary-spec.md]]
- OQ nguong/timeout/han muc: chi ref, khong bia so
