# Flow: Xác nhận / trả lại (QL)

> Màn hình: hang-cho-xac-nhan (+ form ghi chú trên chi tiết). Flow tổng: `../srs/housekeeping-userflow.md`.

---

## Screen: hang-cho-xac-nhan — Hàng chờ xác nhận

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ Hang cho xac nhan                  │
├────────────────────────────────────┤
│ P.201  Cho xac nhan   [QUA HAN]    │
│ NV: Nguyen A · Bao HT 14:40        │
│ [ Xac nhan ]  [ Tra lai ]          │
├────────────────────────────────────┤
│ --- Form tra lai (khi chon) ---    │
│ Ghi chu * (toi da 500)             │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ └────────────────────────────────┘ │
│ [ Gui tra lai ]                    │
│ (!) Thieu ghi chu → E-005          │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Danh sách chờ XN | List | ReadOnly | Việc "chờ xác nhận" (FR-005/006). |
| 2 | Xác nhận | Button | Click | → hoàn tất / sạch (BR-001). |
| 3 | Trả lại + ghi chú | TextArea + Button | Required | ≤500; trống → E-housekeeping-005. |
