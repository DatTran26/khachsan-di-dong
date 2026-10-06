---
type: srs-userflow
feature: ai-ops-summary
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "e8b3a047"
---

# ai-ops-summary — User Flow

> Spec: man quan ly tren web dashboard; `primary_device: mobile` theo batch.

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n0["Dang nhap quan ly"]
    n1["[1] Tom tat van hanh"]
    n2{"Quyen?"}
    n3["Ket thuc: E-006 Sai quyen"]
    n4["Chon ky + Tao"]
    n5{"Dang tao?"}
    n6["Ket thuc: E-007 Cho"]
    n7["Dang tao / khoa nut"]
    n8{"Ky co DL?"}
    n9["Mau rong E-001"]
    n10{"Con han muc chi phi?"}
    n11["Mau E-003"]
    n12{"AI OK trong 15 giay?"}
    n14["Mau E-002"]
    n15{"Dau ra khop?"}
    n16["Mau E-005"]
    n17["Ban AI + nhan tham khao"]
    n18["Bam viec can chu y"]
    n19["Ket thuc: Dashboard"]
    n20["Ket thuc: E-004 Mat mang"]
    n21["Ghi nhat ky luot tao"]

    n0 --> n1
    n1 --> n2
    n2 -->|"Khong"| n3
    n2 -->|"Co"| n4
    n4 --> n5
    n5 -->|"Co"| n6
    n5 -->|"Khong"| n7
    n7 --> n8
    n7 -->|"Mat mang"| n20
    n8 -->|"Khong"| n9
    n8 -->|"Co"| n10
    n10 -->|"Het"| n11
    n10 -->|"Con"| n12
    n12 -->|"Loi"| n14
    n12 -->|"OK"| n15
    n15 -->|"Sai"| n16
    n15 -->|"Dung"| n17
    n9 --> n21
    n11 --> n21
    n14 --> n21
    n16 --> n21
    n17 --> n21
    n21 --> n18
    n18 --> n19

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n17,n19 happy
    class n3,n6,n14,n16,n20 error
    class n9,n11 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | tom-tat-van-hanh | Tom tat van hanh | Chon ky, tao, xem AI/mau, viec can chu y | tao-tom-tat, dieu-phoi, xem-lai |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| tao-tom-tat | Tao tom tat | tom-tat-van-hanh | happy AI, mau, rong, han muc, timeout, mat mang, concurrent |
| dieu-phoi | Dieu phoi viec can chu y | tom-tat-van-hanh | happy → dashboard |
| xem-lai | Xem lai ban gan nhat | tom-tat-van-hanh | phu thuoc OQ-4 |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| Tom tat [1] | Dashboard (feature khac) | Bam muc viec can chu y | FR-ai-ops-summary-012 |

## 4. Open Questions

* [ ] OQ-1 … OQ-5 → `srs/ai-ops-summary-spec.md`
