# Phase 03: Kiểm thử tích hợp & Đảm bảo chất lượng (QA)

## 1. Mục tiêu
Xác thực lại toàn bộ giao diện đã sửa đổi trên môi trường thực tế, đảm bảo không có hồi quy (regression) và mã nguồn đạt chuẩn chất lượng của dự án.

## 2. File liên quan
- `app/test/` (cập nhật hoặc chạy test widget liên quan đến Dashboard và RoomTile)
- Toàn bộ codebase app Flutter

## 3. Các bước thực hiện
1. **Chạy tĩnh phân tích mã nguồn:**
   - Thực thi `flutter analyze lib` trong thư mục `app/`, đảm bảo 0 lỗi lint và không có cảnh báo mới.
2. **Chạy kiểm thử tự động:**
   - Thực thi `flutter test` để xác nhận các test suite hiện tại không bị ảnh hưởng.
3. **Kiểm thử thủ công trên trình duyệt (Chrome):**
   - Chạy `dev.cmd` hoặc kiểm tra trực tiếp giao diện Web:
     - Kiểm tra trực quan 50 ô phòng với các màu sắc đại diện.
     - Kiểm tra độ tương phản màu (đảm bảo đạt WCAG AA, dễ đọc, không chói mắt).
     - Kiểm tra tương tác mở sheet chi tiết phòng khi bấm vào từng ô.

## 4. Tiêu chí hoàn thành
- Báo cáo kết quả kiểm thử pass 100%.
- Không có lỗi bố cục giao diện (RenderFlex overflow).
