---
type: srs-userflow
feature: realtime-sync
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "b2d4f801"
---

# realtime-sync — User Flow

> Feature nền — UX tập trung banner kết nối + thông báo xung đột. Batch-authorized by Devin.

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n0["Man nghiep vu bat ky dang mo"]
    n1{"Ket noi may chu?"}
    n2["[1] Banner mat ket noi"]
    n3["Khoa ghi - van xem du lieu cuoi"]
    n4["Thu ghi khi offline"]
    n5["E-realtime-sync-001"]
    n6["Tu reconnect"]
    n7{"Phien con han?"}
    n8["E-realtime-sync-003 dang nhap lai"]
    n9["Tai trang thai moi"]
    n10["Mo khoa ghi + banner da ket noi lai"]
    n11["User ghi kem phien ban"]
    n12{"Phien ban khop?"}
    n13["[2] Thong bao xung dot E-realtime-sync-002"]
    n14["Tai + hien ban moi"]
    n15["Luu + lan truyen realtime"]

    n0 --> n1
    n1 -->|"mat ket noi"| n2
    n2 --> n3
    n3 --> n4
    n4 --> n5
    n5 --> n3
    n3 -->|"co mang"| n6
    n6 --> n7
    n7 -->|"het han"| n8
    n7 -->|"con han"| n9
    n9 --> n10
    n10 --> n0
    n1 -->|"truc tuyen"| n11
    n11 --> n12
    n12 -->|"khong"| n13
    n13 --> n14
    n14 --> n0
    n12 -->|"co"| n15
    n15 --> n0

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n0,n9,n10,n15 happy
    class n2,n5,n8,n13 error
    class n1,n3,n7,n12,n14 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | banner-ket-noi | Banner trạng thái kết nối | Báo mất kết nối / đã kết nối lại trên mọi màn | ket-noi |
| 2 | thong-bao-xung-dot | Thông báo xung đột phiên bản | Báo dữ liệu vừa được cập nhật + đã tải bản mới | xung-dot |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| ket-noi | Mất kết nối / reconnect | banner-ket-noi | happy reconnect, error offline ghi, edge phiên hết hạn |
| xung-dot | Xung đột phiên bản | thong-bao-xung-dot | happy từ chối + tải mới |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| Màn nghiệp vụ bất kỳ | Banner kết nối [1] | Mất liên lạc máy chủ | Overlay/banner trên màn hiện tại |
| Màn nghiệp vụ bất kỳ | Thông báo xung đột [2] | Ghi bị từ chối do phiên bản cũ | Toast/banner trên màn hiện tại |

## 4. Open Questions

> Canonical: `srs/realtime-sync-spec.md` Mục 14 — chỉ ref.

- [ ] OQ-1: xem `spec.md#OQ-1` — Thiết bị báo mất kết nối sau tối đa bao lâu?
- [ ] OQ-2: xem `spec.md#OQ-2` — Người bị từ chối ghi đè có cần giữ nội dung vừa nhập?
- [ ] OQ-3: xem `spec.md#OQ-3` — Tải trạng thái mới khi reconnect là toàn bộ hay chỉ phần đã đổi?
