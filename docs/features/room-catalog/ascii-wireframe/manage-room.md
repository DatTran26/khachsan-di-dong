# Flow: Thêm / sửa / xóa phòng

> Màn: room-list, room-form. Device: mobile 375.

---

## Screen: room-list — Danh mục phòng (lối vào)

Xem wireframe đầy đủ tại [browse-rooms.md](browse-rooms.md#screen-room-list--danh-mục-phòng). Từ danh sách: Thêm / Sửa / Xóa.

---

## Screen: room-form — Form thêm / sửa phòng

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Them / Sua phong    │
├────────────────────────────────────┤
│ So phong *                         │
│ [______________________________]   │
│                                    │
│ Tang *                             │
│ [________]                         │
│                                    │
│ Loai phong *                       │
│ [ Standard                    v ]  │
│                                    │
│ ! So phong da ton tai (neu co)     │
├────────────────────────────────────┤
│        [ Huy ]      [ Luu ]        │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Số phòng | Text | Input | Bắt buộc, duy nhất (FR-room-catalog-001/003). E-room-catalog-001 khi trùng. |
| 2 | Tầng | Number | Input | Số nguyên dương bắt buộc. |
| 3 | Loại phòng | Select | Input | Chỉ loại đang dùng (FR-room-catalog-010). |
| 4 | Lưu | Button | Click | Lưu + mặc định trạng thái khi thêm (FR-room-catalog-002). E-room-catalog-005/007. |
| 5 | Hủy | Button | Click | Về room-list, không lưu. |
