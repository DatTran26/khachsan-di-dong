import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const ApiException({required this.code, required this.message, this.details});

  bool get isUnauthenticated =>
      code == 'UNAUTHENTICATED' ||
      code == 'SESSION_EXPIRED' ||
      code == 'SESSION_INVALID';

  bool get isPasswordChangeRequired => code == 'PASSWORD_CHANGE_REQUIRED';

  bool get isVersionConflict => code == 'VERSION_CONFLICT';

  @override
  String toString() => message;
}

typedef OnUnauthenticated = void Function();

class ApiClient {
  late final Dio _dio;
  OnUnauthenticated? onUnauthenticated;

  ApiClient({String baseUrl = 'http://localhost:3000/api'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final response = error.response;
        if (response != null) {
          final data = response.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            final err = data['error'] as Map<String, dynamic>;
            final apiEx = ApiException(
              code: err['code'] as String? ?? 'UNKNOWN',
              message: err['message'] as String? ?? 'Có lỗi xảy ra.',
              details: err['details'],
            );
            if (apiEx.isUnauthenticated) {
              onUnauthenticated?.call();
            }
            handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: apiEx,
              response: response,
              type: error.type,
            ));
            return;
          }
        }
        handler.next(error);
      },
    ));
  }

  ApiException _wrap(Object e) {
    if (e is DioException && e.error is ApiException) {
      return e.error as ApiException;
    }
    return const ApiException(code: 'NETWORK_ERROR', message: 'Không thể kết nối đến máy chủ.');
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(path, data: body);
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>?> postNoContent(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.post<dynamic>(path, data: body);
      if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
      return null;
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(path, data: body);
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> delete(String path, {Map<String, dynamic>? body}) async {
    try {
      await _dio.delete<dynamic>(path, data: body);
    } catch (e) {
      throw _wrap(e);
    }
  }
}

final apiClient = ApiClient();
