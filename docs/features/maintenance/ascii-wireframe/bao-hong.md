# Flow: Báo hỏng

> Màn hình thuộc flow này: form-bao-hong. Flow tổng: `../srs/maintenance-userflow.md`.

---

## Screen: form-bao-hong — Form báo hỏng

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai      Bao hong           │
├────────────────────────────────────┤
│ Phong *                            │
│ [ Chon phong            v ]        │
├────────────────────────────────────┤
│ Mo ta hong hoc * (toi da 500)      │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ │                                │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ Vi tri / hang muc (toi da 100)     │
│ [ ........................ ]       │
├────────────────────────────────────┤
│ (!) Dang co viec mo tren phong nay │
│     (canh bao nhe neu co)          │
├────────────────────────────────────┤
│         [ Gui bao hong ]           │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Chọn phòng | Select | Required | Phòng thuộc `room-catalog` (FR-maintenance-001). |
| 2 | Mô tả hỏng hóc | TextArea | Required | ≤500 ký tự; trống → E-maintenance-003. |
| 3 | Vị trí/hạng mục | Text | Optional | ≤100 ký tự. |
| 4 | Cảnh báo việc mở | Banner | ReadOnly | Hiển thị khi phòng đã có việc mở (FR-maintenance-008). |
| 5 | Gửi báo hỏng | Button | Click | Tạo việc "chờ nhận"; mất mạng → E-maintenance-002. |
