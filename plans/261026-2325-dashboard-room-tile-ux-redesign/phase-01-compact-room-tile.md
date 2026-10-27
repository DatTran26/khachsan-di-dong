# Phase 01: Thiết kế lại Compact RoomTile

## 1. Mục tiêu
Thay thế cấu trúc hiển thị cũ (thân thẻ trắng, 3 dòng text 11px nhỏ xíu) bằng cấu trúc ô phòng tinh gọn, màu nền phân vùng, icon trực quan và nhãn ngữ cảnh thời gian.

## 2. File liên quan
- `app/lib/shared/widgets/room_tile.dart` (sửa chính)
- `app/lib/shared/widgets/ui.dart` (cập nhật tông màu, icon mapper cho trạng thái)
- `app/lib/models/room.dart` (nếu cần bổ sung helper rút gọn mã loại phòng: Standard -> STD, Deluxe -> DLX, VIP -> VIP)

## 3. Các bước thực hiện
1. **Bổ sung Icon và Tông màu nền:**
   - Trong `ui.dart`: Định nghĩa ánh xạ icon cho từng trạng thái:
     - `ready` -> `Icons.check_circle_outline`
     - `occupied` -> `Icons.person_outline`
     - `dirty` -> `Icons.cleaning_services_outlined`
     - `cleaning` -> `Icons.sync` / `Icons.hourglass_top_outlined`
     - `inspect` -> `Icons.fact_check_outlined`
     - `oos` -> `Icons.build_outlined`
     - `overdue` -> `Icons.warning_amber_rounded`
2. **Thiết kế lại `RoomTile`:**
   - Bố cục 2 phần tinh gọn:
     - Header: Số phòng (to rõ, font bold ~15-16px) + Mã loại phòng (tag nhỏ) + Icon trạng thái.
     - Body: Nhãn trạng thái ngắn (ví dụ `Trống`, `12:00`, `35p`, `Cần dọn`, `+45p`).
   - Màu nền (background color): Nền thẻ áp dụng màu tint của `StatusTone` (thay vì màu trắng).
   - Viền thẻ: Viền cùng tông màu trạng thái, riêng `overdue` dùng `AppColors.danger` viền 2px.
3. **Tooltip chi tiết khi hover:**
   - Cung cấp tooltip dạng nhiều dòng rõ ràng:
     - Tên phòng + Loại phòng
     - Trạng thái 3 trục
     - Cảnh báo quá hạn (nếu có)

## 4. Kiểm chứng
- Thử nghiệm hiển thị trực quan các ô phòng ở trạng thái: Sẵn sàng, Đang ở, Cần dọn, Bảo trì, Quá hạn.
- Đảm bảo co giãn theo cỡ chữ `textScaler` không bị tràn (overflow).
