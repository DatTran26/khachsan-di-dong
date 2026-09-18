---
type: srs-userflow
feature: check-in-out
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "b4e8a201"
author: batch-authorized by Devin link
---

# Check-in-out — User Flow

> Batch-authorized by Devin (Tang 2→4, bo L1/HARD STOP).

## 1. User Flow (tong)

```mermaid
flowchart TD
    n1["[1] Danh sach dang o"]
    n2["[2] Form nhan phong"]
    n3["[3] Xac nhan tra phong"]
    n4["[4] Xac nhan huy nhan"]
    e1["Chan nhan<br/>E-check-in-out-001/002/003"]
    e2["Thieu thong tin khach<br/>E-check-in-out-004"]
    e3["Tra khong hop le<br/>E-check-in-out-005"]
    e4["Huy qua cua so<br/>E-check-in-out-006"]
    e5["Mat mang / sai quyen<br/>E-check-in-out-007/008"]
    empty["Trang thai rong"]
    pick["Chon phong san sang<br/>room-catalog"]

    n1 -->|"nhan moi"| pick
    pick --> n2
    n2 -->|"OK"| n1
    n2 -->|"chan 3 truc"| e1
    e1 -.->|"chon phong khac"| pick
    n2 -->|"thieu truong"| e2
    e2 -.->|"sua form"| n2
    n1 -->|"tra"| n3
    n3 -->|"OK"| n1
    n3 -->|"loi trang thai"| e3
    e3 -.->|"tai lai"| n1
    n1 -->|"huy nhan P1"| n4
    n4 -->|"OK"| n1
    n4 -->|"qua cua so"| e4
    e4 -.->|"dung Tra phong"| n3
    n2 -->|"mat mang"| e5
    n3 -->|"mat mang"| e5
    e5 -.->|"thu lai"| n1
    n1 -->|"khong ai o"| empty
    empty -.->|"nhan moi"| pick

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107
    class n1,n2,n3,n4,pick happy
    class e1,e2,e3,e4,e5 error
    class empty edge
```

## 2. Danh sach man hinh

| [#] | Slug | Man hinh | Muc dich | Thuoc flow |
|-----|------|----------|----------|------------|
| 1 | occupied-list | Danh sach dang o | Xem phong+khach+moc nhan; chon tra/huy | view-occupied, check-in, check-out, cancel-check-in |
| 2 | check-in-form | Form nhan phong | Ten khach + so nguoi (+ ghi chu/ngay P1) | check-in |
| 3 | check-out-confirm | Xac nhan tra phong | Xac nhan dong luot | check-out |
| 4 | cancel-check-in-confirm | Xac nhan huy nhan | Huy trong cua so ngan | cancel-check-in |

## 3. Muc chia flow

| Flow-slug | Ten flow | Man hinh gom | Cases phu |
|-----------|----------|--------------|-----------|
| view-occupied | Xem danh sach dang o | occupied-list | happy, edge (rong) |
| check-in | Nhan phong | occupied-list → check-in-form | happy, error (3 truc, thieu thong tin) |
| check-out | Tra phong | occupied-list → check-out-confirm | happy, error (trang thai), edge (ngung + dang o) |
| cancel-check-in | Huy nhan phong | occupied-list → cancel-check-in-confirm | happy, error (qua cua so) |

## 3.5. Chuyen man (transitions)

| Tu man [#] | Den man [#] | Trigger | Dieu kien |
|-----------|------------|---------|-----------|
| Danh sach dang o [1] | Form nhan [2] | Nhan phong (tu phong san sang) | Le tan |
| Form nhan [2] | Danh sach [1] | Luu OK / Huy | — |
| Danh sach [1] | Xac nhan tra [3] | Tra phong | Co luot mo |
| Xac nhan tra [3] | Danh sach [1] | Xac nhan / Huy | — |
| Danh sach [1] | Xac nhan huy [4] | Huy nhan | P1, trong cua so |
| Xac nhan huy [4] | Danh sach [1] | Xac nhan / Huy | — |

## 4. Open Questions

- [ ] `spec.md#OQ-1` — Thong tin khach toi thieu
- [ ] `spec.md#OQ-2` — Cua so huy nhan / chua phat sinh
- [ ] `spec.md#OQ-3` — Ghi chu tinh trang khi tra
- [ ] `spec.md#OQ-4` — Le tan xem lich su luot da dong
