---
type: srs-userflow
feature: auth-roles
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "361b66a8"
author: "@Composer"
note: "batch-authorized by Devin link — HARD STOP waived"
---

# Auth Roles — User Flow

## 1. User Flow (tổng)

```mermaid
flowchart TD
  A(["Mo ung dung"]) --> B["Man dang nhap"]
  B --> C{"Submit SDT+MK"}
  C -->|"sai"| D["Bao E-auth-roles-001"]
  D --> B
  C -->|"bi khoa"| E["Bao E-auth-roles-002"]
  E --> B
  C -->|"MK tam"| F["Man doi MK bat buoc"]
  F --> G{"MK moi hop le?"}
  G -->|"khong"| H["E-auth-roles-005"]
  H --> F
  G -->|"co"| I["Man chinh theo vai tro"]
  C -->|"OK Hoat dong"| I
  I --> J["Dang xuat / het phien / bi da"]
  J --> B
  I --> K["QL: danh sach TK"]
  K --> L["Tao / khoa / mo / reset"]
  L -->|"QL cuoi"| M["E-auth-roles-010"]
  M --> K
  L -->|"OK"| K
  I --> N["QL: nhat ky"]
  N --> O["Loc va xem"]
  O --> End(["Ket thuc"])

```

## 2. Chia flow

| Flow slug | Screens | Use cases | Ghi chú |
|---|---|---|---|
| dang-nhap | login, force-change-password, home | uc-dang-nhap, uc-doi-mat-khau | P0 |
| quan-ly-tai-khoan | account-list, account-form, temp-password-once | uc-quan-ly-tai-khoan | P0 |
| xem-nhat-ky | audit-filter, audit-list | uc-xem-nhat-ky | P1 |

## 3. Open Questions (ref)

- OQ-1 ngưỡng hiệu năng đăng nhập — xem `srs/auth-roles-spec.md#OQ-1` (chưa chốt).
- OQ-2, OQ-3 đã resolved — không mở lại.

