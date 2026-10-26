---
phase: 1
title: "Nền tảng design system"
owner: Dat
status: completed
effort: 10h
dependsOn: []
---

# Phase 01 — Nền tảng design system

## Bối cảnh

`core/theme/app_theme.dart` đã có `AppColors`, bán kính và `ThemeData`, nhưng chưa có thang chữ, khoảng
cách hay màu cho các trường hợp các màn đang tự viết `Color(0x…)`. `shared/widgets/ui.dart` có
`StatusChip`, `EmptyState`, `ErrorState`, `FilterPill`, `AppCard`, `Breakpoints` (chỉ 900/1100px).

## File sở hữu

- Sửa: `app/lib/core/theme/app_theme.dart`, `app/lib/shared/widgets/ui.dart`,
  `app/lib/shared/widgets/room_tile.dart`, `app/lib/shared/widgets/confirm_dialog.dart`,
  `app/lib/shared/widgets/task_status_timeline.dart`
- Tạo: `app/lib/shared/widgets/loading_skeleton.dart`, `app/test/shared/ui_widgets_test.dart`
- Không chạm file trong `features/`.

## Yêu cầu

1. **Token**
   - `AppSpacing` (4, 8, 12, 16, 24, 32) và `AppText` (thang chữ: display, title, body, label, caption) dựa trên `textTheme` Be Vietnam Pro.
   - Thu gom các mã màu đang viết cứng ở `features/` vào `AppColors` với tên theo ý nghĩa (vd `sidebarHover`, `loginGradientEnd`). Liệt kê bằng `grep -rn "Color(0x" app/lib/features`.
   - Kiểm tra lại độ tương phản các cặp chữ/nền trạng thái đạt 4.5:1 (chữ thường) và ghi kết quả vào comment.
2. **Theme**
   - Nâng `minimumSize` của các nút lên 48 (vùng chạm tối thiểu Android) và thêm `navigationRailTheme` theo phong cách `navigationBarTheme`.
3. **Breakpoints**
   - Thêm `compact` (<600), `medium` (600–899), `expanded` (≥900) cùng hàm `Breakpoints.of(context)` trả enum.
   - Giữ `isWide`/`hasSidebar` để không làm vỡ code hiện tại.
4. **Component mới/cải tiến**
   - `LoadingSkeleton`: các khối nhấp nháy dạng lưới ô phòng, danh sách và bảng; dùng `AnimationController` có sẵn, không thêm package. Tôn trọng `MediaQuery.disableAnimations`.
   - `initialLoadGate` (trong `ui.dart`, ban đầu dự kiến tên `AsyncBody`): gói ba trạng thái loading → skeleton, lỗi → `ErrorState` có nút thử lại, rỗng → `EmptyState`, kèm `RefreshIndicator` tùy chọn. Đây là mẫu chung để phase 02–04 bỏ `Center(child: CircularProgressIndicator())`.
   - `showAppSnack`: thêm tone `success`. Thông báo snack phải được trình đọc màn hình đọc lên (`SemanticsService.announce` hoặc `liveRegion`).
   - `StatusChip`, `OverdueBadge`, `RoomTile`: bọc `Semantics` với nhãn đầy đủ, vd "Phòng 204, đang có khách, quá hạn dọn".
   - `RoomTile`, `ConfirmDialog`, `TaskStatusTimeline`: chuyển sang token và kiểm tra không tràn chữ ở `textScaler` 2.0.
5. **Hợp đồng cho Bao/Kim**
   - Ghi chú ngắn ở đầu `ui.dart` liệt kê component, kèm một ví dụ dùng `AsyncBody`.
   - Merge vào `develop` ngay khi xong.

## Các bước

1. Viết `AppSpacing`, `AppText` và mở rộng `AppColors`.
2. Thêm Breakpoints mới và cập nhật theme.
3. Viết `LoadingSkeleton` + `AsyncBody` + tone snack.
4. Thêm Semantics cho các widget dùng chung và chuyển chúng sang token.
5. Viết widget test.
6. Chạy `flutter analyze` + `flutter test`, rồi mở PR `develop-dat` → `develop`.

## Kiểm tra

- `app/test/shared/ui_widgets_test.dart`:
  - `AsyncBody` hiện skeleton/lỗi/rỗng/dữ liệu đúng theo trạng thái.
  - `RoomTile` có nhãn semantics chứa số phòng và trạng thái.
  - `StatusChip` không tràn ở `textScaler: TextScaler.linear(2.0)` trong khung rộng 160px.
- `cd app && flutter analyze && flutter test` đều xanh.
- Các màn hiện tại vẫn biên dịch và chạy y như cũ (chưa màn nào bắt buộc dùng component mới).

## Rủi ro và rollback

- Nút cao lên 48 có thể làm lệch vài bố cục chặt → phase 02–04 kiểm khi chuyển màn; nếu vỡ nặng, giữ 44 và ghi lại lý do.
- Rollback: revert PR của phase 01 (chưa màn nào phụ thuộc trước khi phase 02–04 merge).
