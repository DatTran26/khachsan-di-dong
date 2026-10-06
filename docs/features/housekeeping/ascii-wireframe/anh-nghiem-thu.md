# Flow: Ảnh nghiệm thu dọn phòng

> Mở từ `chi-tiet-viec`; mô tả giao diện mẫu cho mobile và hàng chờ xác nhận của quản lý.

## Screen: ảnh nghiệm thu — Nhân viên

```text
┌────────────────────────────────────┐
│ < Phòng 1208 · Ảnh nghiệm thu      │
├────────────────────────────────────┤
│ ① Tổng quan phòng       [Đã tải ✓] │
│    [ ảnh thu nhỏ ]       [Chụp lại]│
│ ② Khu ngủ / giường       [Đã tải ✓] │
│    [ ảnh thu nhỏ ]       [Chụp lại]│
│ ③ Nhà vệ sinh             [Cần ảnh] │
│    [ + Chụp ảnh ]                  │
│ ── Khi có bất thường ───────────── │
│ [ + Thêm ảnh cận cảnh ]            │
│                                    │
│ [ Báo hoàn tất ]  (khóa khi thiếu) │
└────────────────────────────────────┘
```

## Screen: ảnh nghiệm thu — Quản lý

```text
┌────────────────────────────────────┐
│ Phòng 1208 · Chờ xác nhận           │
├────────────────────────────────────┤
│ 3/3 ảnh bắt buộc đã tải             │
│ [Tổng quan] [Khu ngủ] [Nhà vệ sinh] │
│      Chạm để mở toàn màn hình       │
│      Pinch / double-tap để zoom     │
├────────────────────────────────────┤
│ [ Trả lại ]       [ Xác nhận sạch ] │
└────────────────────────────────────┘
```

Ảnh hiển thị theo nhóm để quản lý đối chiếu nhanh; trình xem toàn màn hình chỉ hỗ trợ kiểm tra, không thay đổi thứ tự hay xóa bằng chứng.
