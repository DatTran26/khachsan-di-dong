# Flow: Xử lý việc bảo trì

> Màn hình: danh-sach-viec, chi-tiet-viec. Flow tổng: `../srs/maintenance-userflow.md`.

---

## Screen: danh-sach-viec — Danh sách việc bảo trì

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ <        Viec bao tri       [Loc]  │
├────────────────────────────────────┤
│ [Cho nhan] [Dang sua] [Qua han]    │
├────────────────────────────────────┤
│ P.201  Cho nhan                    │
│ Dieu hoa khong mat                 │
│ Vi tri: Phong ngu                  │
│ ----------------------------       │
│ P.105  Dang sua · An               │
│ Vo voi nuoc                        │
│ (!) Qua han                        │
├────────────────────────────────────┤
│ (Keo de tai them)                  │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Tab/lọc trạng thái | Chip | Filter | Lọc theo trạng thái/phòng/người xử lý (FR-maintenance-012 P1). |
| 2 | Danh sách việc | List | ReadOnly | Phòng, mô tả, vị trí, trạng thái, người xử lý (FR-maintenance-004). |
| 3 | Cờ quá hạn | Badge | ReadOnly | Theo FR-maintenance-010 / OQ-1 — chỉ hiển thị khi feature đánh cờ. |
| 4 | Item việc | Link | Click | Mở chi-tiet-viec. |

---

## Screen: chi-tiet-viec — Chi tiết việc

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Chi tiet viec       │
├────────────────────────────────────┤
│ Phong: 201                         │
│ Trang thai: Cho nhan               │
│ Nguoi bao: Lan                     │
│ Nguoi xu ly: —                     │
├────────────────────────────────────┤
│ Mo ta:                             │
│ Dieu hoa khong mat                 │
│ Vi tri: Phong ngu                  │
├────────────────────────────────────┤
│ [ Nhan viec ]                      │
│ [ Huy viec ]   (neu cho nhan)      │
│ [ Bao xong ]   (neu dang sua)      │
├────────────────────────────────────┤
│ Banner loi (neu co):               │
│ Da co nguoi nhan / Sai trang thai  │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Thông tin việc | Label | ReadOnly | Phòng, mô tả, trạng thái, người báo/xử lý. |
| 2 | Nhận việc | Button | Click | Chỉ khi "chờ nhận"; xung đột → E-maintenance-001. |
| 3 | Báo xong | Button | Click | Chỉ việc của mình đang sửa (FR-maintenance-005). |
| 4 | Hủy việc | Button | Click | Người báo/QL khi "chờ nhận"; lý do tùy chọn ≤200. |
| 5 | Banner lỗi | Banner | ReadOnly | E-maintenance-001/004/006/002. |
