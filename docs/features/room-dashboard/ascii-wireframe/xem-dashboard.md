# Flow: Xem dashboard

> Màn: dashboard-tong-quan. Flow tổng: `../srs/room-dashboard-userflow.md`.

---

## Screen: dashboard-tong-quan — Dashboard tổng quan

### Wireframe (ASCII)

```text
┌──────────────────────────────────────────┐
│ Dashboard phong          Cap nhat: 14:42 │
├──────────────────────────────────────────┤
│ (!) Mat ket noi — du lieu co the loi thoi│
│     (banner E-room-dashboard-001)        │
├──────────────────────────────────────────┤
│ Dang o 12 | San sang 8 | Can don 5       │
│ Ngung 2 | Qua han 3 | Lap day 28%        │
├──────────────────────────────────────────┤
│ Tang [Tat ca v]  Nhom [San sang v]       │
├──────────────────────────────────────────┤
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐              │
│ │201 │ │202 │ │203 │ │204 │              │
│ │O   │ │Trong│ │Trong│ │O  │             │
│ │Can │ │Sach │ │Don │ │Sach│             │
│ │BT  │ │BT   │ │BT  │ │Ngung│  [QH]     │
│ └────┘ └────┘ └────┘ └────┘              │
│ ... (toi 50 phong)                       │
├──────────────────────────────────────────┤
│ (Trong) Khong co phong nao khop bo loc   │
│ [ Thu lai ]  (khi loi tai E-room-dashboard-002) │
└──────────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Hàng chỉ số | Stats | ReadOnly | FR-room-dashboard-002; mẫu=0 → "không áp dụng" (FR-room-dashboard-004). |
| 2 | Ô phòng 3 trục | Grid cell | ReadOnly | 3 trục riêng (FR-room-dashboard-001); cờ QH (FR-room-dashboard-006). |
| 3 | Lọc tầng / nhóm | Select | Filter | FR-room-dashboard-007; 0 KQ → E-room-dashboard-005. |
| 4 | Banner kết nối | Banner | ReadOnly | E-room-dashboard-001; reconnect tải mới (FR-room-dashboard-009). |
| 5 | Mốc cập nhật | Text | ReadOnly | FR-room-dashboard-011 Should. |
| 6 | Thử lại | Button | Click | E-room-dashboard-002 khi tải ban đầu thất bại. |
