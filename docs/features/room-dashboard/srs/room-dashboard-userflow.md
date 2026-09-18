---
type: srs-userflow
feature: room-dashboard
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "rd9f2b10"
---

# room-dashboard — User Flow

> Batch-authorized by Devin. Dashboard v1 web (OQ-3 Android). Wireframe mobile-width.

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n0["Dang nhap QL / Le tan"]
    n1["[1] Dashboard tong quan"]
    n2{"Quyen?"}
    n3["E-room-dashboard-003 Sai quyen"]
    n4{"Tai OK?"}
    n5["E-room-dashboard-002 Thu lai"]
    n6["Luoi 3 truc + chi so"]
    n7["Loc tang / nhom"]
    n8["E-room-dashboard-005 Rong"]
    n9["Realtime cap nhat / co qua han"]
    n10["Banner mat ket noi E-room-dashboard-001"]
    n11["Tai moi khi reconnect"]

    n0 --> n1
    n1 --> n2
    n2 -->|"Khong"| n3
    n3 --> EndDenied((Ket thuc))
    n2 -->|"Co"| n4
    n4 -->|"Loi"| n5
    n5 -.-> n4
    n4 -->|"OK"| n6
    n6 --> n7
    n7 -->|"0 KQ"| n8
    n8 -.->|"doi bo loc"| n7
    n6 --> n9
    n9 --> n6
    n6 -.-> n10
    n10 --> n11
    n11 --> n6

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n6,n9 happy
    class n3,n5,n10 error
    class n7,n8,n11 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | dashboard-tong-quan | Dashboard tổng quan | Lưới 3 trục + chỉ số + lọc + banner kết nối | xem-dashboard |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| xem-dashboard | Xem / lọc / realtime / offline | dashboard-tong-quan | happy, error (quyền, tải, offline), edge (lọc rỗng, mẫu=0) |

## 3.5. Chuyển màn

| Từ | Đến | Trigger | Điều kiện |
|----|-----|---------|-----------|
| Dashboard [1] | Chi tiết phòng (TBD) | Chạm ô phòng | Phụ thuộc OQ-4 |

## 4. Open Questions

- [ ] OQ-1: `spec.md#OQ-1` — ngưỡng quá hạn bảo trì
- [ ] OQ-2: `spec.md#OQ-2` — định nghĩa chỉ số/lọc "cần dọn"
- [ ] OQ-3: `spec.md#OQ-3` — Android?
- [ ] OQ-4: `spec.md#OQ-4` — màn chi tiết phòng?
