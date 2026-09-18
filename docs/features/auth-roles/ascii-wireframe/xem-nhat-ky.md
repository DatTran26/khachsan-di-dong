# Flow: xem-nhat-ky

## Screen: audit-filter — Bo loc

```
+---------------------------+
|  Nhat ky hoat dong        |
|---------------------------|
|  Nguoi  [v]               |
|  Ngay   [____] - [____]   |
|  Loai   [v]               |
|  [ Ap dung ]              |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | Nguoi | select | string | FR-014 |
| 2 | Ngay | date range | date | FR-014 |
| 3 | Loai | select | string | FR-014 |

## Screen: audit-list — Danh sach

```
+---------------------------+
|  Ket qua                  |
|---------------------------|
|  17/09 10:01 | A | Dang nhap |
|  17/09 10:05 | QL| Khoa TK B |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | Dong nhat ky | list row | — | Nguoi, vai tro, hanh dong, doi tuong, thoi diem |
