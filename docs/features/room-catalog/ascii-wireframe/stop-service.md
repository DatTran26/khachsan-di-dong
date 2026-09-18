# Flow: Đặt / gỡ ngừng phục vụ

> Màn: room-list, stop-service-confirm. Device: mobile 375.

---

## Screen: stop-service-confirm — Xác nhận ngừng phục vụ

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Ngung phuc vu       │
├────────────────────────────────────┤
│ Phong 102                          │
│ Dang o | Sach | Binh thuong        │
│                                    │
│ ! Phong dang co khach.             │
│   Van ngung? Khach o het ky;       │
│   chan nhan khach moi.             │
│                                    │
│ Ly do ngung phuc vu *              │
│ [______________________________]   │
│ [______________________________]   │
│                                    │
│ ! Vui long nhap ly do (neu thieu)  │
├────────────────────────────────────┤
│   [ Huy ]     [ Xac nhan ngung ]   │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Thông tin phòng | Label | ReadOnly | Số + 3 trục hiện tại. |
| 2 | Cảnh báo đang ở | Banner | ReadOnly | Hiện khi lưu trú=đang ở (FR-room-catalog-007). |
| 3 | Lý do | TextArea | Input | Bắt buộc (E-room-catalog-004). |
| 4 | Xác nhận | Button | Click | Đặt ngừng / gỡ ngừng (FR-room-catalog-007/008). |
