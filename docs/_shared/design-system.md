---
type: design-system
status: active
updated: 2026-10-17
links:
  - app/lib/core/theme/app_theme.dart
  - app/lib/shared/widgets/ui.dart
  - app/lib/shared/widgets/loading_skeleton.dart
---

# Design system — app Flutter

Quy ước giao diện chung cho mọi màn của app (web tại quầy + Android). Giá trị cụ thể nằm trong code,
tài liệu này chỉ nói **dùng cái gì, khi nào**.

## Token

| Nhóm | Ở đâu | Quy tắc |
|---|---|---|
| Màu | `AppColors` — [`app_theme.dart`](../../app/lib/core/theme/app_theme.dart) | Bảng màu Champagne Gold. Màu trạng thái phòng cố định, không trùng màu thương hiệu. Mọi cặp chữ/nền trạng thái đạt ≥ 4.5:1 (số đo ghi ở comment). |
| Chữ | `AppText` | Chỉ mang cỡ chữ (font Be Vietnam Pro đến từ theme). Thêm độ đậm/màu bằng `.copyWith(...)`. |
| Khoảng cách | `AppSpacing` | Lưới 4px: 4 · 8 · 12 · 16 · 24 · 32. |
| Bo góc | `AppTheme.radiusSm/Md/Lg` | 8 · 12 · 16. |
| Vùng chạm | `AppTheme.minTouch` = 48 | Nút trên điện thoại/tablet ≥ 48. Bảng web dày đặc được phép 34–36. |

**Không** viết `Color(0x…)` hay `fontSize:` trong file màn hình. Cần màu mới → thêm vào `AppColors`
với tên theo ý nghĩa; cần cỡ chữ mới → cân nhắc dùng bậc gần nhất trong `AppText` trước.

## Bố cục theo bề rộng

`Breakpoints.of(context)` trả `WindowSize`:

| Mức | Bề rộng | Điều hướng |
|---|---|---|
| `compact` | < 600 | Thanh dưới (≤ 5 mục) hoặc ngăn kéo |
| `medium` | 600–899 | Thanh điều hướng dọc (`NavigationRail`), cuộn được khi màn thấp |
| `expanded` | ≥ 900 | Thanh bên espresso + thanh đầu trang trắng |

`Breakpoints.isWide` (≥ 1100) dùng cho màn có bảng + khung chi tiết bên phải.

## Component dùng chung

Tất cả export qua [`ui.dart`](../../app/lib/shared/widgets/ui.dart).

| Cần | Dùng |
|---|---|
| Tải lần đầu / lỗi | `initialLoadGate(...)` + `SkeletonGrid` (lưới phòng) hoặc `SkeletonList` (danh sách, bảng). Không dùng vòng xoay giữa màn. |
| Danh sách rỗng | `EmptyState` — nói rõ đây là gì, vì sao trống, bước tiếp theo. |
| Làm mới | `RefreshIndicator` + `AlwaysScrollableScrollPhysics` trên mọi danh sách. |
| Mất kết nối | Khóa nút ghi **và** đặt `OfflineActionNote` cạnh nhóm nút để nói lý do. |
| Trạng thái | `StatusChip` (chữ luôn đi kèm màu), `OverdueBadge`, `AppBanner`. |
| Lọc | `FilterPill`, `SegmentedPills` (tự xuống dòng khi chật). |
| Thông báo sau thao tác | `showAppSnack` — câu nói cụ thể việc vừa làm ("Đã nhận phòng 105 cho …"). |

## Checklist trợ năng cho màn mới

- [ ] Nút chỉ có icon có `tooltip`.
- [ ] Nút lặp trong danh sách có `semanticsLabel` nói rõ đối tượng ("Trả phòng 103", "Khóa tài khoản An").
- [ ] Thẻ thông tin bọc `MergeSemantics` để trình đọc màn hình đọc liền một câu; nút để ngoài.
- [ ] Lỗi/cảnh báo mới hiện ra dùng `AppBanner` (đã là live region).
- [ ] Form: `autovalidateMode: onUserInteraction`, `textInputAction` chuyển ô, đúng `keyboardType`.
- [ ] Không chiều cao cố định cho khối có chữ — dùng `minHeight`, `Flexible`, `Wrap` để chữ to không tràn.
- [ ] Thêm màn vào ma trận bố cục [`layout_matrix_test.dart`](../../app/test/features/layout_matrix_test.dart)
      (3 bề rộng × cỡ chữ 100%/200%).
