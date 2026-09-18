---
type: srs-states
feature: maintenance
updated: 2026-09-17
---

# maintenance — States

## State: ViecBaoTri

**Related entity**: ViecBaoTri (khớp ERD `srs/maintenance-erd.md`)
**Related UC**: [[../usecases/uc-bao-hong.md]], [[../usecases/uc-nhan-viec.md]], [[../usecases/uc-hoan-tat-viec.md]], [[../usecases/uc-huy-viec.md]]
**Related BR**: BR-maintenance-05

```mermaid
stateDiagram-v2
    [*] --> cho_nhan : tao bao hong hop le
    cho_nhan --> dang_sua : NV bao tri nhan viec
    cho_nhan --> da_huy : nguoi bao hoac QL huy
    dang_sua --> hoan_tat : NV bao xong viec cua minh
    hoan_tat --> [*]
    da_huy --> [*]

    note right of hoan_tat
        Khong mo lai viec da dong
        BR-maintenance-05
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| hoan_tat | cho_nhan | Việc đã đóng không mở lại (BR-maintenance-05) |
| da_huy | dang_sua | Việc đã hủy không mở lại |
| dang_sua | cho_nhan | Không trả về chờ nhận sau khi đã nhận |

## State: TrucBaoTriPhong

**Related entity**: Phong.truc_bao_tri
**Related UC**: [[../usecases/uc-bao-hong.md]], [[../usecases/uc-hoan-tat-viec.md]], [[../usecases/uc-dat-go-ngung.md]]
**Related BR**: BR-maintenance-01, BR-maintenance-07

```mermaid
stateDiagram-v2
    [*] --> binh_thuong
    binh_thuong --> ngung_phuc_vu : co viec mo HOAC dat ngung tay
    ngung_phuc_vu --> binh_thuong : het viec mo VA khong co co ngung tay

    note right of ngung_phuc_vu
        Co ngung tay va co do viec mo doc lap
        BR-maintenance-07
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| ngung_phuc_vu | binh_thuong | Không chuyển khi còn việc mở hoặc còn cờ ngừng tay |
