# Flow: Xem nhat ky theo phong

> Man: nhat-ky-theo-phong. Xem `../srs/audit-log-userflow.md`.

## Screen: nhat-ky-theo-phong — Nhat ky theo phong

### Wireframe (ASCII)

```text
+------------------------------------+
| < Phong 301          Nhat ky       |
+------------------------------------+
| Tu [__/__/____] Den [__/__/____]   |
| Nguoi: [Tat ca v] Vai tro: [v]     |
|              [ Ap dung loc ]       |
+------------------------------------+
| 14:32 — Le tan A — Tra phong       |
| Luu tru: Dang o -> Trong           |
| Ve sinh: Sach -> Can don           |
+------------------------------------+
| 14:30 — He thong — Tao viec don    |
+------------------------------------+
|         [ Tai them... ]            |
+------------------------------------+
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Loc tu-den | Date | Input | FR-audit-log-008; E-audit-log-002 neu tu > den; OQ-1 khung mac dinh |
| 2 | Loc nguoi/vai tro | Select | Input | Gom he thong; phan giao cac loc |
| 3 | Danh sach | List | ReadOnly | FR-audit-log-007; empty E-audit-log-004; mang E-audit-log-003 |
