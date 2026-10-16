---
type: qa-checklist
sprint: 3
status: active
updated: 2026-10-13
links:
  - app/test/responsive_a11y_test.dart
  - app/test/dashboard_screen_test.dart
  - app/test/ai_summary_screen_test.dart
---

# Sprint 3 — Kiểm tra giao diện: responsive, khả năng tiếp cận, token

> Phạm vi: màn **Tổng quan** (dashboard) và **Tóm tắt vận hành** (S3-HOANG-04/007/011).
> Không có tài liệu token riêng → nguồn token là `app/lib/core/theme/app_theme.dart` (`AppColors`, `AppTheme`).
> Chạy lại: `cd app && flutter test`.

## Kết quả 13/10/2026 (Kim)

| Hạng mục | Cách kiểm | Kết quả |
|---|---|---|
| Không tràn bố cục ở 360×740, 768×1024, 1280×800 | Widget test, theme thật; font test rộng hơn font thật nên khắt khe như khi phóng to chữ | Đạt (sau khi sửa: hàng chọn kỳ tràn 101px ở 360px → `SegmentedPills` cuộn ngang) |
| Vùng bấm ≥24×24 (WCAG 2.2 AA, 2.5.8) | `MinimumTapTargetGuideline` | Đạt |
| Nút/vùng bấm có nhãn đọc màn hình | `labeledTapTargetGuideline` | Đạt |
| Tương phản chữ ≥4.5:1 (WCAG AA) | `textContrastGuideline` + tính tay từng cặp token | Đạt (sau khi sửa: `ready` trên `readyBg` 4,49 → 4,6) |
| Thứ tự Tab trên web theo thứ tự đọc, tới được lưới phòng | Widget test 20 lần Tab | Đạt |
| Ô đang focus nhìn rõ (WCAG 2.4.7) | Đọc theme | Đã sửa: `focusColor` vàng 35% (mặc định Material chỉ phủ 10%). Chưa kiểm bằng mắt |
| Màu dùng đúng token | Đọc code 2 màn | Đạt — chỉ dùng `AppColors`/`AppTheme`, không mã màu rời |

### Tương phản các cặp token (tính tay)

| Cặp | Tỷ lệ | | Cặp | Tỷ lệ |
|---|---|---|---|---|
| `text` / `bg` | 15,85 | | `occupied` / `occupiedBg` | 5,43 |
| `muted` / `surface` | 5,93 | | `dirty` / `dirtyBg` | 4,70 |
| `goldText` / `goldTint` | 5,55 | | `cleaning` / `cleaningBg` | 5,72 |
| `goldLight` / `espresso` | 10,83 | | `inspect` / `inspectBg` | 5,90 |
| `ready` / `readyBg` | 4,61 | | `oos` / `oosBg` | 6,45 |
| `danger` / `dangerBg` | 5,14 | | chữ trắng / `danger` | 5,90 |

`border` (1,3:1) và `dotMuted` (2,0:1) chỉ là trang trí, không mang thông tin → không áp ngưỡng 3:1.

## Còn mở

| # | Vấn đề | Đề xuất | Ai quyết |
|---|---|---|---|
| 1 | Nút lọc dạng viên (`FilterPill`, `SegmentedPills`) cao 32–34px — dưới chuẩn 48×48 của Android. Đạt chuẩn web (24px) | Mở rộng vùng bấm ra ngoài hình viên tới 48px (giữ nguyên hình), như vùng đệm của chip Material | Đạt (thiết kế) |
| 2 | Chưa kiểm bằng mắt trên Android thật, Chrome ở cỡ mobile (dev server web bị lỗi nạp script khi giả lập mobile) | Kiểm khi build APK ở Sprint 4 | Bảo |
| 3 | Chưa kiểm với trình đọc màn hình thật (TalkBack / NVDA) | Kiểm 1 lượt 2 màn trước demo | Bảo |
