---
type: design-system
status: active
updated: 2026-10-27
links:
  - app/lib/core/theme/app_theme.dart
  - app/lib/shared/widgets/ui.dart
  - app/lib/shared/widgets/room_tile.dart
  - app/lib/shared/widgets/loading_skeleton.dart
---

# Design system — app Flutter

Quy ước giao diện chung cho mọi màn của app (web tại quầy + Android). Giá trị cụ thể nằm trong code,
tài liệu này chỉ nói **dùng cái gì, khi nào**.

## Token

| Nhóm | Ở đâu | Quy tắc |
|---|---|---|
| Màu | `AppColors` — [`app_theme.dart`](../../app/lib/core/theme/app_theme.dart) | Bảng màu Champagne Gold + Màu khối PMS (`solidReady`, `solidOccupied`, `solidHourly`, `solidOverdue`, `solidDirty`, `solidCleaning`, `solidInspect`, `solidOos`). Mọi cặp chữ/nền trạng thái đạt ≥ 4.5:1. |
| Chữ | `AppText` | Chỉ mang cỡ chữ (font Be Vietnam Pro đến từ theme). Thêm độ đậm/màu bằng `.copyWith(...)`. |
| Khoảng cách | `AppSpacing` | Lưới 4px: 4 · 8 · 12 · 16 · 24 · 32. |
| Bo góc | `AppTheme.radiusSm/Md/Lg` | 8 · 12 · 16. |
| Vùng chạm | `AppTheme.minTouch` = 48 | Nút trên điện thoại/tablet ≥ 48. Bảng web dày đặc được phép 34–36. |

**Không** viết `Color(0x…)` hay `fontSize:` trong file màn hình. Cần màu mới → thêm vào `AppColors`
với tên theo ý nghĩa; cần cỡ chữ mới → cân nhắc dùng bậc gần nhất trong `AppText` trước.

## Quy cách ô phòng trực quan (RoomTile - Chuẩn PMS)

Áp dụng thiết kế **Khối màu trực quan theo 5 trường hợp thực tế** (Solid Color Block) tối ưu cho quầy lễ tân:
- Nhận diện từ khoảng cách 2–3 mét qua màu nền đặc trưng.
- Số phòng to nổi bật (18–20px bold) + Tag loại phòng (`ĐƠN`, `ĐÔI`, `VIP`, `DLX`) + Icon trạng thái.
- Trạng thái chính in hoa rõ nét kèm dòng phụ chi tiết ngữ cảnh.
- Hover trên máy tính: Hiện Tooltip thông tin đầy đủ (Tên khách, số người, giờ vào, giờ dự kiến trả, ghi chú).

| Trường hợp | Màu nền | Icon | Trạng thái chính | Dòng phụ ngữ cảnh |
|---|---|---|---|---|
| **1. Trống sẵn sàng** | `solidReady` (`#229954`) | `check_circle` | `SẴN SÀNG` | Tên loại phòng • Sẵn sàng đón khách |
| **2. Trống cần dọn** | `solidDirty` (`#D97706`) | `cleaning_services` | `CẦN DỌN` | Khách vừa trả • Chờ buồng phòng dọn |
| **3. Thuê qua đêm** | `solidOccupied` (`#2563EB`) | `person` | `ĐANG Ở` | Tên khách • Trả 12:00 trưa |
| **4. Thuê theo tiếng** | `solidHourly` (`#0E7490`) | `access_time_filled` | `THEO TIẾNG` | Đếm ngược: Còn X phút (Hạn HH:mm) |
| **5. Khách ở quá giờ** | `solidOverdue` (`#DC2626`) | `warning_amber` | `QUÁ GIỜ TRẢ` | Viền nổi bật • Đã lố: +X phút (từ HH:mm) |
| **6. Đang dọn** | `solidCleaning` (`#7C3AED`) | `hourglass_top` | `ĐANG DỌN` | Buồng phòng đang dọn dẹp |
| **7. Chờ duyệt** | `solidInspect` (`#9C2F6B`) | `fact_check` | `CHỜ DUYỆT` | Đã dọn xong • Chờ kiểm tra |
| **8. Tạm khóa bảo trì** | `solidOos` (`#64748B`) | `build_circle` | `TẠM KHÓA` | Đang bảo trì / sửa chữa |

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
