import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';

/// Lỗi API đã tách từ body `{ error: { code, message, details } }` hoặc lỗi mạng.
///
/// [code] là mã ổn định (`SESSION_EXPIRED`, `VERSION_CONFLICT`, …).
/// [message] là câu tiếng Việt cho người dùng. [details] có thể là bản ghi
/// hiện tại khi xung đột version, hoặc null.
class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const ApiException({required this.code, required this.message, this.details});

  /// Đúng khi server bảo phiên không còn dùng được — app nên về màn đăng nhập.
  bool get isUnauthenticated =>
      code == 'UNAUTHENTICATED' ||
      code == 'SESSION_EXPIRED' ||
      code == 'SESSION_INVALID';

  /// Đúng khi tài khoản còn mật khẩu tạm và route không cho qua.
  bool get isPasswordChangeRequired => code == 'PASSWORD_CHANGE_REQUIRED';

  /// Đúng khi `version` client gửi đã cũ. [details] thường chứa bản ghi mới.
  bool get isVersionConflict => code == 'VERSION_CONFLICT';

  /// Trả [message] để snackbar và log không in cả object Dio.
  @override
  String toString() => message;
}

/// Callback khi interceptor thấy mã chưa đăng nhập. Auth gán để xóa token.
typedef OnUnauthenticated = void Function();

/// HTTP client duy nhất của app, bọc Dio.
///
/// Tự gắn `Authorization: Bearer` từ [TokenStorage] nếu còn token.
/// Lỗi có body `error` được đổi thành [ApiException] rồi reject.
/// Timeout kết nối và nhận mặc định 10 giây. Không retry.
class ApiClient {
  late final Dio _dio;
  OnUnauthenticated? onUnauthenticated;

  /// [baseUrl] mặc định `$apiUrl/api` (xem [apiUrl]). App Android emulator không đổi host này.
  ApiClient({String baseUrl = '$apiUrl/api'}) {
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
        } else if (options.path != '/auth/login') {
          // Chưa có phiên (vd vừa đăng xuất, màn cũ còn tải lại dữ liệu) → chặn tại chỗ,
          // không gửi request chắc chắn bị 401. Không gọi [onUnauthenticated]: phiên đã xóa rồi.
          handler.reject(DioException(
            requestOptions: options,
            error: const ApiException(
                code: 'UNAUTHENTICATED',
                message: 'Vui lòng đăng nhập để tiếp tục.'),
          ));
          return;
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

  /// Đổi lỗi Dio thành [ApiException]. Lỗi không có body API thành `NETWORK_ERROR`.
  ApiException _wrap(Object e) {
    if (e is DioException && e.error is ApiException) {
      return e.error as ApiException;
    }
    return const ApiException(code: 'NETWORK_ERROR', message: 'Không thể kết nối đến máy chủ.');
  }

  /// GET JSON. [path] tương đối [baseUrl]. [query] bỏ qua khi null.
  /// Ném [ApiException]. Giả định body là object — body null thì `data!` ném.
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// POST JSON. [receiveTimeout] nới thời gian nhận cho lệnh chậm có chủ đích
  /// (tóm tắt AI, server chờ tối đa khoảng 15 giây). Không đổi timeout gửi.
  /// Trả map body. 204 hoặc body không phải map sẽ lỗi ép kiểu ở `data!`.
  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body, Duration? receiveTimeout}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(path,
          data: body,
          options: receiveTimeout == null
              ? null
              : Options(receiveTimeout: receiveTimeout));
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// POST byte ảnh thô. Server nhận diện loại theo byte đầu, không tin tên tệp.
  /// Timeout gửi và nhận 60 giây. [query] dùng cho `category`. Trả metadata JSON.
  Future<Map<String, dynamic>> postBytes(String path, List<int> bytes,
      {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(path,
          data: Stream.fromIterable([bytes]),
          queryParameters: query,
          options: Options(
            contentType: 'application/octet-stream',
            headers: {Headers.contentLengthHeader: bytes.length},
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ));
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// Tải byte ảnh kèm token. Ảnh nghiệm thu không có URL công khai.
  /// Trả [Uint8List]. Lỗi mạng hoặc 403 thành [ApiException].
  Future<Uint8List> getBytes(String path) async {
    try {
      final res = await _dio.get<List<int>>(path,
          options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(res.data!);
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// POST có thể không có body JSON (đăng xuất 204).
  /// Body là map thì trả map, ngược lại trả null. Vẫn ném [ApiException] khi server lỗi.
  Future<Map<String, dynamic>?> postNoContent(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.post<dynamic>(path, data: body);
      if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
      return null;
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// PATCH JSON. [body] thường gồm `version` và các trường sửa.
  /// Trả map. Không gửi nếu body null — Dio nhận data null.
  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(path, data: body);
      return res.data!;
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// DELETE. [body] dùng khi server đòi `version` trong thân request (xóa phòng).
  /// Không trả payload. 204 và 200 đều thành công nếu Dio không ném.
  Future<void> delete(String path, {Map<String, dynamic>? body}) async {
    try {
      await _dio.delete<dynamic>(path, data: body);
    } catch (e) {
      throw _wrap(e);
    }
  }
}

/// Singleton dùng chung. Đổi [ApiClient.onUnauthenticated] trên đúng instance này.
final apiClient = ApiClient();
