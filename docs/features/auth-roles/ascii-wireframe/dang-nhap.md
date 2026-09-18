# Flow: dang-nhap

## Screen: login — Đăng nhập

```
+---------------------------+
|  Khach san di dong        |
|---------------------------|
|  So dien thoai            |
|  [________________]       |
|  Mat khau                 |
|  [________________]       |
|                           |
|  [ Dang nhap ]            |
|                           |
|  (thong bao loi VN)       |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | So dien thoai | text | string | 10 so, bat dau 0 |
| 2 | Mat khau | password | string | khong hien gia tri |
| 3 | Dang nhap | button | action | Submit FR-001 |
| 4 | Thong bao loi | label | string | E-auth-roles-001/002 |

## Screen: force-change-password — Doi MK bat buoc

```
+---------------------------+
|  Doi mat khau bat buoc    |
|---------------------------|
|  Mat khau moi             |
|  [________________]       |
|  Xac nhan mat khau moi    |
|  [________________]       |
|  [ Luu mat khau ]         |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | MK moi | password | string | >=8, chu+so |
| 2 | Xac nhan | password | string | khop MK moi |
| 3 | Luu | button | action | FR-006 |

## Screen: home — Man chinh theo vai tro

```
+---------------------------+
|  Xin chao, {ho ten}       |
|  Vai tro: {vai tro}       |
|---------------------------|
|  (menu theo quyen)        |
|  [ Dang xuat ]            |
+---------------------------+
```

| # | Items | Control type | Data type | Description |
|---|---|---|---|---|
| 1 | Menu | nav | — | An/hien theo vai tro |
| 2 | Dang xuat | button | action | FR-002 |
