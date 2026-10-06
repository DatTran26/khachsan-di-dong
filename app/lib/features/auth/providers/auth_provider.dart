import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../models/user.dart';

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

  bool get isAuthenticated => user != null;

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

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
    apiClient.onUnauthenticated = _handleUnauthenticated;
    socketService.onSessionRevoked = _handleSessionRevoked;
  }

  String? _revokedMessage;
  String? get revokedMessage => _revokedMessage;

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
      _connectSocket(token);
    } catch (_) {
      await TokenStorage.clearToken();
      state = state.copyWith(initialized: true);
    }
  }

  void _connectSocket(String token) {
    socketService.connect(token);
  }

  void _handleUnauthenticated() {
    _logout(emitRevoked: false);
  }

  void _handleSessionRevoked(String reason, String message) {
    _revokedMessage = message;
    _logout(emitRevoked: false);
  }

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
      state = state.copyWith(user: user, isLoading: false);
      _connectSocket(token);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

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
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _logout(emitRevoked: true);
  }

  Future<void> _logout({required bool emitRevoked}) async {
    try {
      await apiClient.postNoContent('/auth/logout');
    } catch (_) {}
    await TokenStorage.clearToken();
    socketService.disconnect();
    state = const AuthState(initialized: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
