# Flow: Xem nhat ky chung

> Man: nhat-ky-chung. Xem `../srs/audit-log-userflow.md`.

## Screen: nhat-ky-chung — Nhat ky chung

### Wireframe (ASCII)

```text
+------------------------------------+
| < Menu           Nhat ky chung     |
+------------------------------------+
| Tu-Den | Nguoi | Loai HD | Truc    |
| Doi tuong: [Tat ca v] [Ap dung]    |
+------------------------------------+
| 08:01 — He thong — Khoa TK         |
| 07:55 — Le tan C — Dang nhap fail  |
| 07:40 — Quan ly B — Tra phong 212  |
+------------------------------------+
|         [ Tai them... ]            |
+------------------------------------+
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Bo loc mo rong | Select/Date | Input | FR-audit-log-010: thoi gian, nguoi, loai HD, truc, loai doi tuong |
| 2 | Danh sach | List | ReadOnly | Gom su kien khong gan phong; E-audit-log-001/003/004 |
