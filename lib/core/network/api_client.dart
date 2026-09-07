import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        final token = await _storage.read(StorageKeys.token);
        if (token != null && token.isNotEmpty) {
          o.headers['Authorization'] = 'Bearer $token';
        }
        h.next(o);
      },
      onError: (e, h) => h.next(e),
    ));
    _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }

  final SecureStorage _storage;
  late final Dio _dio;
  Dio get dio => _dio;

  // Helpers that normalize success/error shape from PRD
  static String msgFrom(dynamic data, String fallback) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return fallback;
  }
}
