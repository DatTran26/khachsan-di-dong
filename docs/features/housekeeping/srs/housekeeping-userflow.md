---
type: srs-userflow
feature: housekeeping
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "hk17c4a2"
author: batch-authorized by Devin link
---

# housekeeping — User Flow

> Nguồn chia flow DUY NHẤT. Batch-authorized by Devin (Tầng 2→4, no L1/HARD STOP).

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n0["Su kien tra phong"]
    n1["He thong tao + giao viec"]
    n2["[1] Viec cua toi"]
    n3["[2] Chi tiet viec"]
    n4{"Nhan OK?"}
    n5["E-housekeeping-001 / 004"]
    n6["Bao hoan tat"]
    n7["[3] Hang cho xac nhan"]
    n8{"Xac nhan hay tra lai?"}
    n9["Hoan tat / sach"]
    n10["Form ghi chu tra lai"]
    n11["E-housekeeping-005"]
    n12["[4] Danh sach cong viec QL"]
    n13["Phan cong lai / loc"]
    n14["Banner mat ket noi E-003"]
    n15["Co qua han"]

    n0 --> n1
    n1 --> n2
    n2 -->|"chon"| n3
    n3 -->|"nhan"| n4
    n4 -->|"loi"| n5
    n5 -.->|"tai lai"| n2
    n4 -->|"ok"| n3
    n3 -->|"bao hoan tat"| n6
    n6 --> n7
    n7 --> n8
    n8 -->|"xac nhan"| n9
    n8 -->|"tra lai"| n10
    n10 -->|"thieu"| n11
    n11 -.-> n10
    n10 -->|"ok"| n3
    n12 --> n13
    n1 -.-> n15
    n2 -.->|"mat mang"| n14
    n3 -.->|"mat mang"| n14
    n7 -.->|"mat mang"| n14

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n2,n3,n6,n7,n9,n12 happy
    class n5,n11,n14 error
    class n4,n8,n10,n13,n15 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | viec-cua-toi | Việc của tôi | NV xem việc giao/đang làm; nhận/từ chối; cờ quá hạn | xu-ly-viec |
| 2 | chi-tiet-viec | Chi tiết công việc | Nhận/từ chối/báo hoàn tất; xem ghi chú trả lại | xu-ly-viec, xac-nhan |
| 3 | hang-cho-xac-nhan | Hàng chờ xác nhận | QL xác nhận / trả lại | xac-nhan |
| 4 | danh-sach-cong-viec | Danh sách công việc | QL lọc + phân công lại + quá hạn | quan-ly-viec |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| xu-ly-viec | NV nhận / từ chối / báo hoàn tất | viec-cua-toi → chi-tiet-viec | happy, error (xung đột, mất mạng), edge (từ chối) |
| xac-nhan | QL xác nhận / trả lại | hang-cho-xac-nhan, chi-tiet-viec | happy, error (thiếu ghi chú) |
| quan-ly-viec | Lọc + phân công lại | danh-sach-cong-viec | happy, edge (0 kết quả lọc) |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| Việc của tôi [1] | Chi tiết [2] | Chọn một việc | — |
| Chi tiết [2] | Việc của tôi [1] | Nhận/từ chối/báo HT thành công hoặc Quay lại | — |
| Hàng chờ [3] | Chi tiết [2] | Chọn việc chờ xác nhận | — |
| Danh sách QL [4] | Chi tiết [2] | Chọn việc để phân công lại | — |

## 4. Open Questions

> Canonical: `srs/housekeeping-spec.md` Mục 12 — chỉ ref.

- [ ] OQ-1: xem `spec.md#OQ-1` — Nguồn danh sách NV buồng phòng đang trực?
- [ ] OQ-2: xem `spec.md#OQ-2` — Cảnh báo quá hạn 1 lần hay lặp định kỳ?
- [ ] OQ-3: xem `spec.md#OQ-3` — Việc chờ xác nhận quá lâu có ngưỡng nhắc riêng?
