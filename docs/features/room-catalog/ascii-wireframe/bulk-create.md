# Flow: Tạo phòng theo dải

> Màn: bulk-create. Device: mobile 375.

---

## Screen: bulk-create — Tạo theo dải

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Tao phong theo dai  │
├────────────────────────────────────┤
│ Tang *                             │
│ [ 1______ ]                        │
│                                    │
│ So bat dau *     So ket thuc *     │
│ [ 101____ ]      [ 110____ ]       │
│                                    │
│ Loai phong *                       │
│ [ Standard                    v ]  │
│                                    │
│ Ket qua (sau luu):                 │
│ Da tao: 101,103..110               │
│ Bo qua (trung): 102                │
├────────────────────────────────────┤
│        [ Huy ]      [ Tao ]        │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Tầng / khoảng số / loại | Input | Input | FR-room-catalog-009. |
| 2 | Kết quả | Label | ReadOnly | Báo số tạo và số bỏ vì trùng. |
| 3 | Tạo | Button | Click | Phòng mới mặc định trống+sạch+bình thường (FR-room-catalog-002). |
