import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/user.dart';

/// Danh sách tài khoản, cờ tải và lỗi của `GET /users`.
class UsersState {
  final List<AppUser> users;
  final bool isLoading;
  final String? error;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
  UsersState copyWith({
    List<AppUser>? users,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      UsersState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Tải và sửa tài khoản. Constructor gọi [load]. Quyền do server kiểm.
class UsersNotifier extends StateNotifier<UsersState> {
  /// Side effect: gọi [load] khi tạo.
  UsersNotifier() : super(const UsersState()) {
    load();
  }

  /// GET `/users`. [ApiException] ghi lỗi vào state, không ném tiếp.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/users');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList();
      state = state.copyWith(users: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// POST `/users` rồi [load]. Trả `data` (có `tempPassword`).
  /// [ApiException] ném lại, không ghi vào state.
  Future<Map<String, dynamic>?> createUser({
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final res = await apiClient.post('/users', body: {
        'fullName': fullName,
        'phone': phone,
        'role': role.value,
      });
      final data = res['data'] as Map<String, dynamic>;
      await load();
      return data;
    } on ApiException {
      rethrow;
    }
  }

  /// PATCH `/users/{id}`. Chỉ gửi trường khác null, luôn gửi [version].
  /// Xong thì [load]. Ném [ApiException] khi xung đột hoặc SĐT trùng.
  Future<void> updateUser({
    required String id,
    required int version,
    String? fullName,
    String? phone,
    UserRole? role,
    bool? onDuty,
  }) async {
    final body = <String, dynamic>{'version': version};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (role != null) body['role'] = role.value;
    if (onDuty != null) body['onDuty'] = onDuty;
    try {
      await apiClient.patch('/users/$id', body: body);
      await load();
    } on ApiException {
      rethrow;
    }
  }

  /// POST `/users/{id}/lock` với [version], rồi [load]. Ném [ApiException] nếu server từ chối.
  Future<void> lockUser(String id, int version) async {
    try {
      await apiClient.post('/users/$id/lock', body: {'version': version});
      await load();
    } on ApiException {
      rethrow;
    }
  }

  /// Mở khóa → BE cấp mật khẩu tạm mới (trả về `tempPassword`).
  Future<Map<String, dynamic>?> unlockUser(String id, int version) async {
    final res =
        await apiClient.post('/users/$id/unlock', body: {'version': version});
    await load();
    return res['data'] as Map<String, dynamic>?;
  }

  /// POST `/users/{id}/reset-password`. Trả `data` (thường có `tempPassword`) sau [load].
  /// Ném [ApiException], không nuốt.
  Future<Map<String, dynamic>?> resetPassword(String id, int version) async {
    try {
      final res = await apiClient
          .post('/users/$id/reset-password', body: {'version': version});
      await load();
      return res['data'] as Map<String, dynamic>?;
    } on ApiException {
      rethrow;
    }
  }
}

/// Tài khoản dùng chung. Một [UsersNotifier] đến khi không còn listener.
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier();
});
