---
type: srs-states
feature: housekeeping
updated: 2026-09-17
---

# housekeeping — States

## State: ViecDonPhong

**Related entity**: ViecDonPhong (khớp ERD `srs/housekeeping-erd.md`)
**Related UC**: [[../usecases/uc-tao-giao-viec-sau-tra-phong.md]], [[../usecases/uc-nhan-tu-choi-viec.md]], [[../usecases/uc-bao-hoan-tat.md]], [[../usecases/uc-xac-nhan-tra-lai.md]]
**Related BR**: BR-housekeeping-001, BR-housekeeping-002, BR-housekeeping-005

```mermaid
stateDiagram-v2
    [*] --> cho_giao : tao viec sau tra phong
    cho_giao --> da_giao : tu giao khi co NV truc
    da_giao --> dang_lam : NV nhan viec
    da_giao --> cho_giao : tu choi va het nguoi truc
    da_giao --> da_giao : tu choi roi giao lai NV khac
    dang_lam --> cho_xac_nhan : NV bao hoan tat
    cho_xac_nhan --> hoan_tat : QL xac nhan
    cho_xac_nhan --> dang_lam : QL tra lai kem ghi chu
    hoan_tat --> [*]

    note right of cho_xac_nhan
        Tra lai bat buoc ghi chu
        BR-housekeeping-005
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| hoan_tat | dang_lam | Việc đã hoàn tất không mở lại |
| cho_giao | cho_xac_nhan | Phải qua nhận / đang làm |
| dang_lam | hoan_tat | Phải qua xác nhận quản lý (BR-housekeeping-001) |

## State: TrucVeSinhPhong

**Related entity**: Phong.truc_ve_sinh
**Related UC**: [[../usecases/uc-tao-giao-viec-sau-tra-phong.md]], [[../usecases/uc-nhan-tu-choi-viec.md]], [[../usecases/uc-bao-hoan-tat.md]], [[../usecases/uc-xac-nhan-tra-lai.md]]
**Related BR**: BR-housekeeping-001, BR-housekeeping-003

```mermaid
stateDiagram-v2
    [*] --> can_don : su kien tra phong
    can_don --> dang_don : NV nhan viec
    dang_don --> cho_kiem_tra : NV bao hoan tat
    cho_kiem_tra --> sach : QL xac nhan
    cho_kiem_tra --> dang_don : QL tra lai
    sach --> can_don : su kien tra phong lan sau

    note right of sach
        San sang = trong + sach + dang phuc vu
        composite BR-housekeeping-003
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| can_don | sach | Phải qua dọn + xác nhận quản lý |
| cho_kiem_tra | can_don | Không nhảy về cần dọn khi trả lại — về đang dọn |
