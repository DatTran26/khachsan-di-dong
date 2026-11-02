# Phase 02: Nâng cấp Bộ lọc & Tìm kiếm nhanh trên Dashboard

## 1. Mục tiêu
Hỗ trợ lễ tân tra cứu nhanh danh mục phòng theo Loại phòng và Số phòng ngay trên màn hình Tổng quan (Dashboard), đồng thời tối ưu hóa khoảng cách và tỷ lệ lưới để ô phòng hiển thị đẹp mắt, vuông vức.

## 2. File liên quan
- `app/lib/features/dashboard/screens/dashboard_screen.dart` (sửa chính)
- `app/lib/features/rooms/providers/room_types_provider.dart` (lấy danh sách loại phòng để lọc)

## 3. Các bước thực hiện
1. **Bổ sung Bộ lọc Loại phòng (Room Type Filter):**
   - Thêm dropdown hoặc hàng chip `FilterPill` cho các loại phòng đang có trong khách sạn (VIP, Deluxe, Standard...).
   - Cập nhật hàm `_matches(Room r, ...)` để lọc theo `roomTypeId`.
2. **Bổ sung Ô tìm kiếm nhanh (Quick Search):**
   - Hộp nhập số phòng (Search box) thu gọn, khi lễ tân gõ "201" sẽ làm nổi bật hoặc lọc đúng phòng 201.
3. **Cân đối tỉ lệ GridView:**
   - Điều chỉnh `gridDelegate` để tỷ lệ ô phòng vuông vức hơn (khoảng 80x75px hoặc 90x80px), hiển thị được nhiều phòng hơn trên mỗi hàng mà không bị choán chỗ.

## 4. Kiểm chứng
- Lọc theo tầng kết hợp loại phòng và nhóm trạng thái hoạt động chính xác.
- Tìm kiếm số phòng phản hồi tức thì.
- Giao diện đáp ứng mượt mà khi co giãn kích thước cửa sổ.
