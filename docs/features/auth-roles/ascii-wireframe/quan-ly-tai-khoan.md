# Flow: quan-ly-tai-khoan

## Screen: account-list — Danh sach tai khoan

```
+---------------------------+
|  Tai khoan nhan vien      |
|---------------------------|
|  [ + Tao moi ]            |
|  - Nguyen A | Le tan | OK |
|  - Tran B   | QL     | OK |
|  - Le C     | BP-BT  | Khoa|
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | Tao moi | button | action | Mo account-form |
| 2 | Hang TK | list row | — | Bam de sua/khoa |

## Screen: account-form — Tao/sua tai khoan

```
+---------------------------+
|  Tao tai khoan            |
|---------------------------|
|  Ho ten  [____________]   |
|  SDT     [____________]   |
|  Vai tro [v]              |
|  [ Luu ]  [ Huy ]         |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | Ho ten | text | string | Bat buoc |
| 2 | SDT | text | string | Unique |
| 3 | Vai tro | select | enum | 3 vai tro MVP |
| 4 | Luu | button | action | FR-005 |

## Screen: temp-password-once — MK tam 1 lan

```
+---------------------------+
|  Mat khau tam             |
|---------------------------|
|  ******1234               |
|  (chi hien 1 lan)         |
|  [ Da chep / Dong ]       |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | MK tam | text | string | Hien 1 lan, khong log |
