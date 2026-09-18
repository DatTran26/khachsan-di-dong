---
type: srs-states
feature: auth-roles
status: draft
updated: 2026-09-17
---

# Auth Roles — States

## State: TaiKhoanNhanVien

```mermaid
stateDiagram-v2
  [*] --> ChoKichHoat: Tao TK / Reset MK / Mo khoa
  ChoKichHoat --> HoatDong: Doi MK tam thanh cong
  HoatDong --> BiKhoa: QL khoa / Sai MK 5 lan
  BiKhoa --> ChoKichHoat: QL mo khoa
  note right of ChoKichHoat
    Dang nhap duoc nhung bat doi MK
  end note
  note right of BiKhoa
    Khong dang nhap; phien dang mo bi huy
  end note
```

## State: PhienDangNhap

```mermaid
stateDiagram-v2
  [*] --> Active: Dang nhap thanh cong
  Active --> [*]: Dang xuat / Het 12h / Khoa TK / Dang nhap thiet bi moi
```
