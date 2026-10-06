import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/user.dart';

class UsersState {
  final List<AppUser> users;
  final bool isLoading;
  final String? error;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

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

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(const UsersState()) {
    load();
  }

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

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier();
});
