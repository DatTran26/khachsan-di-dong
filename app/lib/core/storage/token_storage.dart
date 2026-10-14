import 'package:shared_preferences/shared_preferences.dart';

/// Lưu token phiên trong SharedPreferences, khóa `auth_token`.
///
/// Không mã hóa. Trên web đây là lưu trữ trình duyệt; trên Android là file prefs.
/// Không lưu refresh token — backend chỉ có một token 12 giờ.
class TokenStorage {
  static const _tokenKey = 'auth_token';

  /// Token gốc hoặc null nếu chưa đăng nhập / đã xóa.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Ghi đè token. [token] là bản gốc server trả một lần lúc login, chưa băm.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Xóa khóa token. Không đụng các preference khác của app.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
