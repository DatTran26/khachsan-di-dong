# Flow: Quản lý danh sách việc

> Màn hình: danh-sach-cong-viec. Flow tổng: `../srs/housekeeping-userflow.md`.

---

## Screen: danh-sach-cong-viec — Danh sách công việc

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ Cong viec don phong                │
├────────────────────────────────────┤
│ Loc: [NV v] [Trang thai v] [Phong] │
├────────────────────────────────────┤
│ Canh bao: 2 viec qua han           │
├────────────────────────────────────┤
│ P.201  Da giao   NV: A  [QUA HAN]  │
│ [ Phan cong lai ]                  │
├────────────────────────────────────┤
│ P.110  Cho giao                    │
│ (!) Chua co NV truc                │
├────────────────────────────────────┤
│ (Trong) Khong co viec khop loc     │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Bộ lọc | Select/Input | Filter | NV / trạng thái / phòng (FR-010). |
| 2 | Cảnh báo quá hạn | Banner | ReadOnly | FR-008; số việc quá hạn. |
| 3 | Phân công lại | Button | Click | FR-009; chỉ việc đang mở; ghi nhật ký. |
| 4 | Trạng thái rỗng | EmptyState | ReadOnly | Khi lọc 0 kết quả. |
