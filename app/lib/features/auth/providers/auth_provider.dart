import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../models/user.dart';

/// Trạng thái đăng nhập trên UI.
///
/// [user] null nghĩa là chưa có phiên trong bộ nhớ. [initialized] false trong lúc
/// đọc token lúc mở app — router không redirect sớm. [error] là câu login/đổi MK vừa thất bại.
class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool initialized;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.initialized = false,
  });

  /// Có [user] trong bộ nhớ. Không kiểm token còn hạn — server từ chối thì interceptor xóa phiên.
  bool get isAuthenticated => user != null;

  /// Trả bản sao. [clearUser] và [clearError] thắng tham số cùng tên.
  /// Không truyền field thì giữ giá trị cũ.
  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool? initialized,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        initialized: initialized ?? this.initialized,
      );
}

/// Phiên đăng nhập: khôi phục token, login, đổi mật khẩu, logout.
///
/// Gán [apiClient.onUnauthenticated] và [socketService.onSessionRevoked]
/// trong constructor. Hai callback này là singleton — notifier thứ hai sẽ ghi đè.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
    apiClient.onUnauthenticated = _handleUnauthenticated;
    socketService.onSessionRevoked = _handleSessionRevoked;
  }

  String? _revokedMessage;

  /// Câu server gửi khi phiên bị hủy. UI đọc sau khi state đã về khách.
  /// Không tự xóa sau khi đọc.
  String? get revokedMessage => _revokedMessage;

  /// Đang chạy [_logout]. Chặn gọi chồng: đăng xuất chủ động khiến server bắn
  /// `session:revoked` (LOGGED_OUT) về chính thiết bị này, và 401 có thể tới cùng lúc.
  bool _loggingOut = false;

  /// Nếu còn token thì gọi GET `/auth/me`. Lỗi thì xóa token và coi như chưa đăng nhập.
  /// Thành công thì nối socket trừ khi còn mật khẩu tạm.
  Future<void> _init() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      state = state.copyWith(initialized: true);
      return;
    }
    try {
      final res = await apiClient.get('/auth/me');
      final user = AppUser.fromJson(res['data']['user'] as Map<String, dynamic>);
      state = state.copyWith(user: user, initialized: true);
      _connectSocket(token, user);
    } catch (_) {
      await TokenStorage.clearToken();
      state = state.copyWith(initialized: true);
    }
  }

  /// Nối socket khi đã đổi mật khẩu tạm.
  ///
  /// Server từ chối handshake nếu còn `mustChangePassword`, và client sẽ thử lại
  /// mã đó sau mỗi 3 giây. Vì vậy hàm không gọi [socketService.connect] khi cờ còn bật.
  void _connectSocket(String token, AppUser user) {
    if (user.mustChangePassword) return;
    socketService.connect(token);
  }

  /// Interceptor Dio: xóa phiên cục bộ. Vẫn gọi POST logout (server trả 204 nếu phiên đã chết).
  void _handleUnauthenticated() {
    _logout(emitRevoked: false);
  }

  /// Socket báo phiên hết. Lưu [message] vào [revokedMessage] rồi xóa phiên.
  /// [reason] không được lưu riêng.
  /// Bỏ qua khi chính thiết bị này đang đăng xuất (không phải bị đá).
  void _handleSessionRevoked(String reason, String message) {
    if (_loggingOut) return;
    _revokedMessage = message;
    _logout(emitRevoked: false);
  }

  /// Đăng nhập. [deviceInfo] gửi cứng `flutter-web`, kể cả bản Android.
  ///
  /// Lưu token, cập nhật user, nối socket nếu không còn mật khẩu tạm.
  /// [ApiException] được đưa vào [AuthState.error] rồi ném lại cho màn hình.
  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.post('/auth/login', body: {
        'phone': phone,
        'password': password,
        'deviceInfo': 'flutter-web',
      });
      final data = res['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await TokenStorage.saveToken(token);
      _revokedMessage = null;
      state = state.copyWith(user: user, isLoading: false);
      _connectSocket(token, user);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  /// Đổi mật khẩu trên phiên hiện tại. Token không đổi.
  ///
  /// Thành công thì cập nhật user và nối socket nếu trước đó đang chặn vì mật khẩu tạm.
  /// Sai mật khẩu hiện tại: ghi [error] và ném lại.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.post('/auth/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      final user = AppUser.fromJson(
          (res['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>);
      state = state.copyWith(user: user, isLoading: false);
      // Đổi MK xong (phiên vẫn giữ token cũ) → giờ mới mở được kết nối realtime.
      final token = await TokenStorage.getToken();
      if (token != null) _connectSocket(token, user);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  /// Đăng xuất chủ động. Luôn xóa token và ngắt socket dù POST `/auth/logout` lỗi.
  Future<void> logout() async {
    _revokedMessage = null;
    await _logout(emitRevoked: true);
  }

  /// Xóa phiên cục bộ. [emitRevoked] hiện không được đọc — cả đường chủ động
  /// và đường bị đá đều vẫn gọi API logout rồi đưa state về đã khởi tạo, không user.
  /// Gọi chồng khi đang chạy thì bỏ qua.
  Future<void> _logout({required bool emitRevoked}) async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      // Ngắt socket trước khi báo server: khỏi nhận lại `session:revoked` của chính mình.
      socketService.disconnect();
      try {
        await apiClient.postNoContent('/auth/logout');
      } catch (_) {}
      await TokenStorage.clearToken();
      state = const AuthState(initialized: true);
    } finally {
      _loggingOut = false;
    }
  }
}

/// Provider phiên. Tạo [AuthNotifier] một lần; constructor tự khôi phục token.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
