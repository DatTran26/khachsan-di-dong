---
phase: 3
title: "Lưu trú, Chi tiết phòng, Bảo trì"
owner: Bao
status: completed
effort: 10h
dependsOn: [1]
---

# Phase 03 — Lưu trú, Chi tiết phòng, Bảo trì

## Bối cảnh

Đây là luồng lễ tân dùng nhiều nhất: mở chi tiết phòng (`room_detail_panel.dart`, 572 dòng) để nhận
phòng, đặt/gỡ ngừng phục vụ, xác nhận sạch; trả phòng ở màn Lưu trú; báo hỏng qua
`report_issue_dialog.dart`. Màn Lưu trú chưa có kéo-làm-mới; cả ba màn tải bằng spinner.

## File sở hữu

- Sửa:
  - `app/lib/features/stays/screens/stays_screen.dart`
  - `app/lib/features/rooms/widgets/room_detail_panel.dart`
  - `app/lib/features/rooms/screens/room_form_screen.dart`
  - `app/lib/features/maintenance/screens/maintenance_screen.dart`
  - `app/lib/features/maintenance/widgets/report_issue_dialog.dart`
- Tạo: `app/test/features/stays_maintenance_test.dart`
- Không sửa: `shared/widgets/*`, `core/theme/*` (cần component chung thì báo Dat).

## Yêu cầu

1. **Đếm thao tác trước khi sửa**
   - Ghi số lần chạm của ba luồng nhận phòng, trả phòng và báo hỏng vào `plans/reports/` để so sánh trước/sau.
2. **Chi tiết phòng**
   - Mobile: bottom sheet kéo được (`DraggableScrollableSheet`) để xem nhanh mà không mất ngữ cảnh lưới.
   - Web: panel bên.
   - Hành động chính theo trạng thái phòng (Nhận phòng / Xác nhận sạch / Mở lại phục vụ) nằm ở vị trí cố định cuối sheet, nút cao 48.
3. **Phản hồi tức thì**
   - Khi đang gửi: khóa nút và hiện spinner trong nút (đã có, chuẩn hóa).
   - Gửi xong: snack tone `success`. Gặp lỗi: thông báo cụ thể qua `error_handler` hiện có.
   - Khi offline: nút bị vô hiệu và có giải thích ngay bên dưới, thay vì chỉ làm mờ.
4. **Form**
   - Thêm phòng/nhận phòng/báo hỏng: kiểm tra lỗi ngay khi rời ô, `textInputAction` chuyển ô tiếp theo, bàn phím đúng loại (số phòng → number).
   - Lỗi được trình đọc màn hình đọc lên.
5. **Lưu trú và Bảo trì**
   - Skeleton qua `AsyncBody`; Lưu trú có kéo-làm-mới.
   - Thẻ (mobile) và bảng (web) dùng token; chip trạng thái có semantics.
6. Bỏ hết `Color(0x`/`fontSize:` viết cứng trong file sở hữu.

## Các bước

1. Kéo `develop` về `develop-bao` và đếm thao tác (bước 1 ở trên).
2. Làm `room_detail_panel.dart`, rồi `report_issue_dialog.dart` + `room_form_screen.dart`.
3. Làm `stays_screen.dart`, `maintenance_screen.dart`.
4. Viết test, kiểm thủ công ở 3 kích thước, cập nhật số thao tác sau trong report, rồi mở PR `develop-bao` → `develop`.

## Kiểm tra

- Test:
  - Nút hành động bị vô hiệu khi offline và hiện dòng giải thích.
  - Form báo hỏng báo lỗi khi mô tả trống.
  - Lưu trú hiện skeleton khi đang tải.
- Thủ công: đăng nhập lễ tân → nhận phòng → trả phòng → báo hỏng → mở lại phục vụ, trên web và Android.
- Số thao tác sau không lớn hơn trước ở cả ba luồng.

## Rủi ro và rollback

- `room_detail_panel.dart` được dashboard (phase 02) gọi qua `showRoomDetailSheet` → giữ nguyên chữ ký hàm này.
- Rollback: revert PR của phase.
