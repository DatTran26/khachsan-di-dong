---
type: srs-userflow
feature: audit-log
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "c4a91e2b"
---

# audit-log — User Flow

> Nguồn chia flow DUY NHẤT. Spec: màn nhật ký cho quản lý (web); `primary_device: mobile` theo batch. Mobile nhân viên không có màn nhật ký v1.

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n0["Dang nhap quan ly"]
    n1["[1] Nhat ky theo phong"]
    n2{"Quyen quan ly?"}
    n3["Ket thuc: E-audit-log-001"]
    n4{"Tai OK?"}
    n5["E-audit-log-003 Mat ket noi"]
    n6{"Co ban ghi?"}
    n7["Ket thuc: E-audit-log-004 Rong"]
    n8["Dong thoi gian"]
    n9["Dat loc"]
    n10{"Loc hop le?"}
    n11["E-audit-log-002 Khoang thoi gian"]
    n12["[2] Nhat ky chung P1"]
    n13["Ket thuc: da xem"]

    n0 --> n1
    n1 --> n2
    n2 -->|"Khong"| n3
    n2 -->|"Co"| n4
    n4 -->|"Loi mang"| n5
    n5 -->|"Thu lai"| n4
    n4 -->|"OK"| n6
    n6 -->|"Khong"| n7
    n6 -->|"Co"| n8
    n8 --> n9
    n9 --> n10
    n10 -->|"Khong"| n11
    n11 -->|"Chinh lai"| n9
    n10 -->|"Co"| n6
    n8 --> n13
    n0 --> n12
    n12 --> n2

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n8,n12,n13 happy
    class n3,n5,n11 error
    class n7 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | nhat-ky-theo-phong | Nhật ký theo phòng | Dòng thời gian bản ghi một phòng; lọc thời gian/vai trò/người | xem-theo-phong, loc-nhat-ky |
| 2 | nhat-ky-chung | Nhật ký chung | Toàn hệ thống gồm sự kiện không gắn phòng; lọc mở rộng | xem-nhat-ky-chung |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| xem-theo-phong | Xem nhật ký theo phòng | nhat-ky-theo-phong | happy, error quyền/mạng, empty |
| loc-nhat-ky | Lọc nhật ký | nhat-ky-theo-phong, nhat-ky-chung | happy, E-002, empty |
| xem-nhat-ky-chung | Xem nhật ký chung | nhat-ky-chung | happy P1, error, empty |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| — | Nhật ký theo phòng [1] | Mở từ chi tiết phòng | Vai trò quản lý |
| — | Nhật ký chung [2] | Mở mục Nhật ký chung | Vai trò quản lý; P1 |

## 4. Open Questions

* [ ] OQ-1 → `srs/audit-log-spec.md#OQ-1`
* [ ] OQ-2 → `srs/audit-log-spec.md#OQ-2`
