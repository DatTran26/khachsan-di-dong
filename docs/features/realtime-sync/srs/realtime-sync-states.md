---
type: srs-states
feature: realtime-sync
updated: 2026-09-17
---

# realtime-sync — States

## State: KetNoiThietBi

**Related entity**: KetNoiThietBi
**Related UC**: [[../usecases/uc-xu-ly-mat-ket-noi.md]]
**Related BR**: BR-realtime-sync-03, BR-realtime-sync-04

```mermaid
stateDiagram-v2
    [*] --> truc_tuyen : thiet bi ket noi may chu
    truc_tuyen --> mat_ket_noi : mat lien lac
    mat_ket_noi --> truc_tuyen : reconnect + tai trang thai moi
    mat_ket_noi --> can_dang_nhap_lai : reconnect nhung phien het han

    note right of mat_ket_noi
        Khoa ghi - van xem du lieu cuoi
        BR-realtime-sync-03
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| mat_ket_noi | truc_tuyen | Không mở khóa ghi trước khi tải trạng thái mới (BR-realtime-sync-04) |

## State: GhiDoiTuong

**Related entity**: PhienBanDoiTuong / thao tác ghi
**Related UC**: [[../usecases/uc-xu-ly-xung-dot.md]]
**Related BR**: BR-realtime-sync-02

```mermaid
stateDiagram-v2
    [*] --> cho_kiem_tra : thiet bi gui ghi kem phien ban
    cho_kiem_tra --> da_luu : phien ban khop
    cho_kiem_tra --> bi_tu_choi : phien ban cu
    da_luu --> da_phat_su_kien : luu truoc phat sau
    bi_tu_choi --> [*] : tai trang thai moi
    da_phat_su_kien --> [*]
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| cho_kiem_tra | da_phat_su_kien | Không phát sự kiện khi chưa lưu (BR-realtime-sync-01) |
| bi_tu_choi | da_luu | Từ chối không được ghi đè |
