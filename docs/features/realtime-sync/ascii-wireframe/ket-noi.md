# Flow: Mất kết nối / reconnect

---

## Screen: banner-ket-noi — Banner trạng thái kết nối

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│  (!) Mat ket noi — dang thu lai…   │
│  Thao tac ghi da bi khoa           │
├────────────────────────────────────┤
│  (noi dung man nghiep vu — chi doc)│
│  [ Nut ghi bi vo hieu hoa ]        │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  (ok) Da ket noi lai — du lieu     │
│      da cap nhat                   │
├────────────────────────────────────┤
│  [ Nut ghi mo khoa ]               │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Description |
|---|-------|--------------|-------------|
| 1 | Banner offline | Banner | FR-005, FR-007; E-001 khi thử ghi. Ngưỡng phát hiện — OQ-1. |
| 2 | Khóa ghi | Disabled controls | BR-03; vẫn xem dữ liệu cuối. |
| 3 | Banner reconnect | Banner | FR-006; tải mới trước khi mở khóa (BR-04). Phiên hết hạn → E-003. |
