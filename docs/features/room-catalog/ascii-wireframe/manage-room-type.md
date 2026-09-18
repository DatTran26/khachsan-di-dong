# Flow: Quản lý loại phòng

> Màn: room-type-list, room-type-form. Device: mobile 375.

---

## Screen: room-type-list — Danh sách loại phòng

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Loai phong    [+]   │
├────────────────────────────────────┤
│ Standard          Dang dung  [Sua] │
│                              [Tat] │
├────────────────────────────────────┤
│ Deluxe            Dang dung  [Sua] │
│                              [Tat] │
├────────────────────────────────────┤
│ Suite             Da ngung   [Bat] │
└────────────────────────────────────┘
```

---

## Screen: room-type-form — Form loại phòng

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Them / Sua loai     │
├────────────────────────────────────┤
│ Ten loai *                         │
│ [______________________________]   │
├────────────────────────────────────┤
│        [ Huy ]      [ Luu ]        │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Danh sách loại | List | ReadOnly | Trạng thái dùng/ngừng (FR-room-catalog-010). |
| 2 | Tắt / Bật | Button | Click | Đổi trạng thái loại. |
| 3 | Tên loại | Text | Input | Thêm/sửa tên. |
| 4 | Lưu | Button | Click | E-room-catalog-005/007 khi lỗi. |
