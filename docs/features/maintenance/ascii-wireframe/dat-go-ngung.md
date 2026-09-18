# Flow: Đặt/gỡ ngừng phục vụ

> Màn hình: dat-go-ngung. Flow tổng: `../srs/maintenance-userflow.md`.

---

## Screen: dat-go-ngung — Đặt/gỡ ngừng phục vụ

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai   Ngung phuc vu         │
├────────────────────────────────────┤
│ Phong: 305                         │
│ Truc bao tri: Binh thuong          │
│ Co ngung tay: Khong                │
│ Viec bao tri mo: 0                 │
├────────────────────────────────────┤
│ Ly do dat ngung * (toi da 200)     │
│ ┌────────────────────────────────┐ │
│ │ Sua dien khan                  │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│      [ Dat ngung phuc vu ]         │
│      [ Go ngung tay ]              │
├────────────────────────────────────┤
│ Loi: Phong con viec dang xu ly     │
│ (E-maintenance-005 neu go sai)     │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Trạng thái phòng | Label | ReadOnly | Trục bảo trì + cờ ngừng tay + số việc mở. |
| 2 | Lý do | TextArea | Required | Bắt buộc khi đặt (≤200) — BR-maintenance-04. |
| 3 | Đặt ngừng | Button | Click | FR-maintenance-007; sai quyền → E-maintenance-006. |
| 4 | Gỡ ngừng tay | Button | Click | Từ chối nếu còn việc mở → E-maintenance-005. |
