/// Địa chỉ gốc của backend (không có `/api`), đọc lúc build:
/// `flutter build web --dart-define=API_URL=https://ten-mien-demo.vn`.
///
/// Bỏ trống thì dùng máy dev local. REST gọi `$apiUrl/api`, Socket.IO nối thẳng [apiUrl].
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');
