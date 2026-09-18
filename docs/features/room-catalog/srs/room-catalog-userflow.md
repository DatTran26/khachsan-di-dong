---
type: srs-userflow
feature: room-catalog
updated: 2026-09-17
primary_device: mobile
stage: flow-approved
flow_approved_at: 2026-09-17
flow_hash: "a7c3e91f"
author: batch-authorized by Devin link
---

# Room Catalog — User Flow

> Nguồn chia flow DUY NHẤT. Batch-authorized by Devin (Tầng 2→4, bỏ L1/HARD STOP).

## 1. User Flow (tổng)

```mermaid
flowchart TD
    n1["[1] Danh muc phong<br/>loc tang / loai / trang thai"]
    n2["[2] Form them / sua phong"]
    n3["[3] Xac nhan ngung phuc vu"]
    n4["[4] Tao phong theo dai"]
    n5["[5] Danh sach loai phong"]
    n6["[6] Form loai phong"]
    e1["Loi so trung<br/>E-room-catalog-001"]
    e2["Tu choi xoa<br/>E-room-catalog-002 / 003"]
    e3["Thieu ly do<br/>E-room-catalog-004"]
    e4["Mat mang / sai quyen<br/>E-room-catalog-005 / 007"]
    edge1["Canh bao phong dang o"]
    empty["Trang thai rong"]

    n1 -->|"them / sua"| n2
    n2 -->|"luu OK"| n1
    n2 -->|"trung so"| e1
    e1 -.->|"sua lai"| n2
    n1 -->|"xoa that bai"| e2
    e2 -.->|"goi y ngung"| n3
    n1 -->|"dat / go ngung"| n3
    n3 -->|"thieu ly do"| e3
    e3 -.->|"nhap lai"| n3
    n3 -->|"dang o"| edge1
    edge1 -->|"xac nhan"| n3
    n3 -->|"OK"| n1
    n1 -->|"tao theo dai"| n4
    n4 -->|"xong"| n1
    n1 -->|"quan ly loai"| n5
    n5 -->|"them / sua"| n6
    n6 -->|"luu"| n5
    n5 -.->|"quay lai"| n1
    n1 -->|"loc khong khop"| empty
    empty -.->|"doi loc"| n1
    n2 -->|"mat mang"| e4
    n3 -->|"mat mang"| e4
    e4 -.->|"thu lai"| n1

    classDef happy fill:#d4edda,stroke:#28a745
    classDef error fill:#f8d7da,stroke:#dc3545
    classDef edge fill:#fff3cd,stroke:#ffc107

    class n1,n2,n3,n4,n5,n6 happy
    class e1,e2,e3,e4 error
    class edge1,empty edge
```

## 2. Danh sách màn hình

| [#] | Slug | Màn hình | Mục đích | Thuộc flow |
|-----|------|----------|----------|------------|
| 1 | room-list | Danh mục phòng | Tra cứu/lọc 3 trục; lối vào CRUD, ngừng phục vụ, tạo dải, loại | browse-rooms, manage-room, stop-service, bulk-create |
| 2 | room-form | Form thêm/sửa phòng | Nhập số/tầng/loại | manage-room |
| 3 | stop-service-confirm | Xác nhận ngừng phục vụ | Lý do bắt buộc; cảnh báo nếu đang ở | stop-service |
| 4 | bulk-create | Tạo theo dải | Tầng + khoảng số + loại | bulk-create |
| 5 | room-type-list | Danh sách loại phòng | Xem/tắt loại | manage-room-type |
| 6 | room-type-form | Form loại phòng | Thêm/sửa tên loại | manage-room-type |

## 3. Mục chia flow

| Flow-slug | Tên flow | Màn hình gồm | Cases phủ |
|-----------|----------|--------------|-----------|
| browse-rooms | Tra cứu / lọc | room-list | happy, edge (rỗng) |
| manage-room | Thêm / sửa / xóa phòng | room-list → room-form | happy, error (trùng số, chặn xóa, mất mạng) |
| stop-service | Đặt / gỡ ngừng phục vụ | room-list → stop-service-confirm | happy, error (thiếu lý do), edge (đang ở) |
| bulk-create | Tạo theo dải | room-list → bulk-create | happy, edge (bỏ qua số trùng) |
| manage-room-type | Quản lý loại phòng | room-type-list → room-type-form | happy, error (mất mạng/sai quyền) |

## 3.5. Chuyển màn (transitions)

| Từ màn [#] | Đến màn [#] | Trigger | Điều kiện |
|-----------|------------|---------|-----------|
| Danh mục phòng [1] | Form thêm/sửa [2] | Bấm Thêm / Sửa | Quyền quản lý (OQ-1 lễ tân) |
| Form thêm/sửa [2] | Danh mục phòng [1] | Lưu thành công / Hủy | — |
| Danh mục phòng [1] | Xác nhận ngừng [3] | Đặt/gỡ ngừng phục vụ | — |
| Xác nhận ngừng [3] | Danh mục phòng [1] | Xác nhận / Hủy | — |
| Danh mục phòng [1] | Tạo theo dải [4] | Bấm Tạo theo dải | Quản lý |
| Tạo theo dải [4] | Danh mục phòng [1] | Xong / Hủy | — |
| Danh mục phòng [1] | Danh sách loại [5] | Quản lý loại | Quản lý |
| Danh sách loại [5] | Form loại [6] | Thêm / Sửa | — |
| Form loại [6] | Danh sách loại [5] | Lưu / Hủy | — |

## 4. Open Questions

- [ ] `spec.md#OQ-1` — Quyền lễ tân với danh mục
- [ ] `spec.md#OQ-2` — Cách nạp danh mục 50 phòng ban đầu
- [ ] `spec.md#OQ-3` — Quy ước đánh số phòng
