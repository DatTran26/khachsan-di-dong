# Flow: Tạo tóm tắt vận hành

> Màn: tom-tat-van-hanh. Flow tổng: `../srs/ai-ops-summary-userflow.md`.

---

## Screen: tom-tat-van-hanh — Tóm tắt vận hành

### Wireframe (ASCII)

```text
┌──────────────────────────────────────────┐
│ Tom tat van hanh                         │
├──────────────────────────────────────────┤
│ Ky: ( ) Ca hien tai  ( ) Ca truoc        │
│     ( ) Hom nay                          │
│                    [ Tao tom tat ]       │
├──────────────────────────────────────────┤
│ Trang thai: Dang tao… (nut bi khoa)      │
├──────────────────────────────────────────┤
│ === Ban AI ===                           │
│ Du lieu tinh den 17/09 14:30             │
│ Nhan: Tham khao — tom tat do AI tao,     │
│       khong thay quyet dinh van hanh     │
│                                          │
│ Tong quan: …                             │
│ Diem noi bat: …                          │
│ Viec can chu y:                          │
│  - Viec don P.201 qua han  [Toi dashboard]│
│  - Phong 305 ngung phuc vu [Toi dashboard]│
├──────────────────────────────────────────┤
│ === Bao cao mau (fallback) ===           │
│ Nhan: Bao cao mau — du lieu goc,         │
│       chua qua AI                        │
│ Chi so: … | Viec can chu y: …            │
├──────────────────────────────────────────┤
│ [ Xem ban gan nhat ]  (neu OQ-4 chot)    │
│ Thong bao: E-001..007 theo tinh huong    │
└──────────────────────────────────────────┘
```

### Screen description

| # | Items | Control type | Description |
|---|-------|--------------|-------------|
| 1 | Chọn kỳ | Radio | Ca hiện tại / ca trước / hôm nay; không kỳ tương lai (FR-001). Định nghĩa ca — OQ-1. |
| 2 | Tạo tóm tắt | Button | Khóa khi đang tạo (FR-008); kiểm hạn mức OQ-2 trước gọi AI. |
| 3 | Bản AI | Content | Cấu trúc tổng quan + nổi bật + việc cần chú ý; thời điểm T + nhãn tham khảo (FR-006). |
| 4 | Báo cáo mẫu | Content | Fallback lỗi/timeout/hết hạn mức/đầu ra sai/kỳ rỗng (FR-003,007). |
| 5 | Việc cần chú ý | Links | Đi tới dashboard (FR-012). |
| 6 | Xem lại | Button | Phụ thuộc OQ-4 (FR-013). |
