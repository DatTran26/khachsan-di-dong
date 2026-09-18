---
type: srs-states
feature: room-dashboard
updated: 2026-09-17
---

# room-dashboard — States

> Trạng thái 3 trục phòng thuộc feature nguồn. Dashboard chỉ có trạng thái phiên xem / kết nối.

## State: PhienXemDashboard

**Related UC**: [[../usecases/uc-mo-va-xem-dashboard.md]], [[../usecases/uc-xu-ly-mat-ket-noi-dashboard.md]]

```mermaid
stateDiagram-v2
    [*] --> dang_tai : mo dashboard
    dang_tai --> san_sang : tai thanh cong
    dang_tai --> loi_tai : tai that bai
    loi_tai --> dang_tai : bam thu lai
    san_sang --> mat_ket_noi : mat realtime
    mat_ket_noi --> dang_tai_lai : co mang tro lai
    dang_tai_lai --> san_sang : tai moi thanh cong
    san_sang --> [*] : dong man

    note right of mat_ket_noi
        Banner E-001 + danh dau loi thoi
    end note
```

### Invalid transitions

| From | To | Why not |
|---|---|---|
| loi_tai | san_sang | Phải tải lại thành công |
| mat_ket_noi | san_sang | Phải tải trạng thái mới, không ghép dữ liệu cũ |
