# Flow: Xử lý việc dọn (NV)

> Màn hình thuộc flow này: viec-cua-toi, chi-tiet-viec. Flow tổng: `../srs/housekeeping-userflow.md`.

---

## Screen: viec-cua-toi — Việc của tôi

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ Viec cua toi          [Loc]        │
├────────────────────────────────────┤
│ (!) Mat ket noi — khoa ghi         │
│     (banner khi offline)           │
├────────────────────────────────────┤
│ [Tat ca|Da giao|Dang lam|Cho XN]   │
├────────────────────────────────────┤
│ P.201  Da giao      [QUA HAN]      │
│ Tra luc 14:05                      │
│ [ Nhan ]  [ Tu choi ]              │
├────────────────────────────────────┤
│ P.305  Dang lam                    │
│ [ Bao hoan tat ]                   │
├────────────────────────────────────┤
│ (Trong) Chua co viec nao           │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Tab/lọc trạng thái | Tabs | Filter | Đã giao / đang làm / chờ xác nhận (FR-housekeeping-010). |
| 2 | Dòng việc | ListItem | ReadOnly | Số phòng, trạng thái, cờ quá hạn (FR-housekeeping-008). |
| 3 | Nhận / Từ chối | Button | Click | FR-housekeeping-004; E-001/003/004/006. |
| 4 | Banner mất kết nối | Banner | ReadOnly | E-housekeeping-003 / FR-011. |

---

## Screen: chi-tiet-viec — Chi tiết công việc

### Wireframe (ASCII)

```text
┌────────────────────────────────────┐
│ < Quay lai     Chi tiet viec       │
├────────────────────────────────────┤
│ Phong 201                          │
│ Trang thai: Dang lam               │
│ Phu trach: Nguyen A                │
│ Tao luc: 14:05 (tra phong)         │
├────────────────────────────────────┤
│ Ghi chu tra lai (neu co):          │
│ "Thieu khan tam"                   │
├────────────────────────────────────┤
│ [ Nhan ] / [ Tu choi ]             │
│ [ Bao hoan tat ]                   │
│ (nut theo trang thai hien tai)     │
└────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Data type | Description |
|---|-------|--------------|-----------|-------------|
| 1 | Thông tin việc | Text | ReadOnly | Phòng, trạng thái, phụ trách, mốc tạo. |
| 2 | Ghi chú trả lại | Text | ReadOnly | Hiện khi QL đã trả lại (FR-006). |
| 3 | Thao tác theo state | Button | Click | Nhận/từ chối/báo HT — ≤3 chạm (NFR-002). |
