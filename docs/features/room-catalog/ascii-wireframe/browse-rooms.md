# Flow: Tra cứu / lọc danh mục phòng

> Màn: room-list. Device: mobile 375. Flow tổng: `../srs/room-catalog-userflow.md`.

---

## Screen: room-list — Danh mục phòng

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ Danh muc phong            [+] [..] │
├────────────────────────────────────┤
│ Tang [Tat ca v]  Loai [Tat ca v]   │
│ Luu tru [v] Ve sinh [v] Bao tri[v] │
├────────────────────────────────────┤
│ 101  Tang 1  Standard              │
│ Trong | Sach | Binh thuong         │
│ * San sang *                       │
│              [Sua] [Ngung] [Xoa]   │
├────────────────────────────────────┤
│ 102  Tang 1  Standard              │
│ Dang o | Sach | Binh thuong        │
│              [Sua] [Ngung] [Xoa]   │
├────────────────────────────────────┤
│ 201  Tang 2  Deluxe                │
│ Trong | Can don | Binh thuong      │
│              [Sua] [Ngung] [Xoa]   │
├────────────────────────────────────┤
│ [Tao theo dai]    [Loai phong]     │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Bộ lọc | Select | Input | Lọc tầng, loại, từng trục (FR-room-catalog-006). Rỗng → trạng thái rỗng. |
| 2 | Dòng phòng | List | ReadOnly | Số, tầng, loại + 3 trục; "sẵn sàng" khi trống+sạch+bình thường (FR-room-catalog-005). |
| 3 | Thêm / Sửa / Xóa | Button | Click | CRUD phòng (FR-room-catalog-001..004). Lỗi E-room-catalog-001..003. |
| 4 | Ngừng phục vụ | Button | Click | Sang stop-service-confirm (FR-room-catalog-007/008). |
| 5 | Tạo theo dải / Loại | Link | Click | Sang bulk-create / room-type-list. |
