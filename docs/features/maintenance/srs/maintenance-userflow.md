---
type: srs-userflow
feature: maintenance
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "a7c3e91f"
---

# maintenance — User Flow

> Nguồn chia flow DUY NHẤT. Batch-authorized by Devin (Tầng 2→4, no L1/HARD STOP).

## 1. User Flow (tổng)

> Phủ happy / error / edge. `[n]` = số màn hình đối chiếu Mục 2.

```mermaid
flowchart TD
    n1["[1] Form bao hong"]
    n2{"Gui hop le?"}
    n3["Bao thieu mo ta E-maintenance-003"]
    n4["Canh bao dang co viec mo"]
    n5["[2] Danh sach viec bao tri"]
    n6["[3] Chi tiet viec"]
    n7{"Nhan viec OK?"}
    n8["E-maintenance-001 da co nguoi nhan"]
    n9["Bao xong / Huy"]
    n10{"Dong viec OK?"}
    n11["E-maintenance-004 / E-maintenance-006"]
    n12["[4] Dat / go ngung phuc vu"]
    n13{"Go khi con viec mo?"}
    n14["E-maintenance-005"]
    n15["Banner mat ket noi E-maintenance-002"]

    n1 -->|"gui"| n2
    n2 -->|"thieu mo ta"| n3
    n3 -.->|"sua va gui lai"| n1
    n2 -->|"hop le + da co viec mo"| n4
    n4 --> n5
    n2 -->|"hop le"| n5
    n5 -->|"chon viec"| n6
    n6 -->|"nhan viec"| n7
    n7 -->|"xung dot"| n8
    n8 -.->|"tai lai"| n5
    n7 -->|"thanh cong"| n6
    n6 -->|"bao xong hoac huy"| n9
    n9 --> n10
    n10 -->|"loi"| n11
    n10 -->|"ok"| n5
    n11 -.->|"tai lai"| n6
    n12 -->|"go"| n13
    n13 -->|"con viec mo"| n14
    n14 -.->|"sua viec truoc"| n12
    n13 -->|"het viec mo"| n12
    n1 -.->|"mat mang khi ghi"| n15
    n6 -.->|"mat mang khi ghi"| n15
    n12 -.->|"mat mang khi ghi"| n15
    n15 -.->|"co mang thu lai"| n1

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n4,n5,n6,n9,n12 happy
    class n3,n8,n11,n14,n15 error
    class n2,n7,n10,n13 edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | form-bao-hong | Form báo hỏng | Chọn phòng + mô tả/vị trí, gửi báo hỏng | bao-hong |
| 2 | danh-sach-viec | Danh sách việc bảo trì | Xem/lọc việc chờ nhận/đang sửa/quá hạn | xu-ly-viec |
| 3 | chi-tiet-viec | Chi tiết việc | Nhận việc, báo xong, hủy | xu-ly-viec |
| 4 | dat-go-ngung | Đặt/gỡ ngừng phục vụ | Đặt tay kèm lý do; gỡ tay | dat-go-ngung |

## 3. Danh sách flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| bao-hong | Báo hỏng | form-bao-hong | happy, error (thiếu mô tả, mất mạng), edge (đã có việc mở) |
| xu-ly-viec | Nhận / hoàn tất / hủy việc | danh-sach-viec → chi-tiet-viec | happy, error (xung đột nhận, sai trạng thái), edge (hủy chờ nhận) |
| dat-go-ngung | Đặt/gỡ ngừng tay | dat-go-ngung | happy, error (gỡ khi còn việc mở, mất mạng) |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| Form báo hỏng [1] | Danh sách việc [2] | Gửi báo hỏng thành công | — |
| Danh sách việc [2] | Chi tiết việc [3] | Chọn một việc | — |
| Chi tiết việc [3] | Danh sách việc [2] | Nhận/báo xong/hủy thành công hoặc Quay lại | — |

## 4. Open Questions

> Chỉ ref — không tự trả lời. Canonical: `srs/maintenance-spec.md` Mục 14.

- [ ] OQ-1: xem `spec.md#OQ-1` — Ngưỡng "quá hạn" việc bảo trì + tần suất cảnh báo?
- [ ] OQ-2: xem `spec.md#OQ-2` — Cơ chế giao việc — tự nhận hay chỉ định từ đầu?
- [ ] OQ-3: xem `spec.md#OQ-3` — Việc trên phòng đang có khách — sửa giữa kỳ lưu trú hay chờ trả?
