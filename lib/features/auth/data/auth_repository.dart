import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/models/user.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api; final SecureStorage _storage;

  Future<User> me() async {
    try {
      final r = await _api.dio.get(ApiConstants.me);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return User.fromJson(d is Map<String,dynamic> ? d : Map<String,dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _msg(e);
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final r = await _api.dio.post(ApiConstants.login, data: {'email':email,'password':password});
      final ar = AuthResponse.fromJson(r.data);
      await _storage.write(StorageKeys.token, ar.token);
      await _storage.write(StorageKeys.userJson, '${ar.user.id}|${ar.user.name}|${ar.user.email}|${ar.user.role}');
      return ar;
    } on DioException catch (e) {
      // fallback mock for demo/offline
      if (e.type==DioExceptionType.connectionError || e.type==DioExceptionType.connectionTimeout) {
        return _mockLogin(email, password);
      }
      final m = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      throw m ?? _msg(e);
    }
  }

  Future<AuthResponse> register(String name, String email, String password, {String? phone}) async {
    try {
      final r = await _api.dio.post(ApiConstants.register, data: {'name':name,'email':email,'password':password,'phone':phone});
      final ar = AuthResponse.fromJson(r.data);
      await _storage.write(StorageKeys.token, ar.token);
      return ar;
    } on DioException catch (e) {
      if (e.type==DioExceptionType.connectionError || e.type==DioExceptionType.connectionTimeout) {
        // mock register
        final token = 'mock_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(StorageKeys.token, token);
        return AuthResponse(user: User(id:'u1', name:name, email:email, phone:phone, role:'user'), token: token);
      }
      final m = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      throw m ?? _msg(e);
    }
  }

  Future<void> logout() async {
    try { await _api.dio.post(ApiConstants.logout); } catch (_) {}
    await _storage.delete(StorageKeys.token);
    await _storage.delete(StorageKeys.userJson);
  }

  Future<String?> getToken() => _storage.read(StorageKeys.token);

  String _msg(DioException e) {
    if (e.response?.data is Map && e.response?.data['message']!=null) return e.response!.data['message'].toString();
    if (e.type==DioExceptionType.connectionError) return 'Tidak dapat terhubung ke server. Periksa koneksi.';
    if (e.type==DioExceptionType.receiveTimeout || e.type==DioExceptionType.sendTimeout) return 'Server timeout. Coba lagi.';
    return e.message ?? 'Terjadi kesalahan';
  }

  Future<AuthResponse> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email=='admin@yaw.id' && password=='admin123') {
      const u = User(id:'admin1', name:'YAW Admin', email:'admin@yaw.id', role:'admin');
      const t = 'mock_admin_token';
      await _storage.write(StorageKeys.token, t);
      return const AuthResponse(user:u, token:t);
    }
    if (password.length < 6) throw 'Password minimal 6 karakter';
    final u = User(id:'u1', name: email.split('@').first, email:email, role:'user');
    const t = 'mock_user_token';
    await _storage.write(StorageKeys.token, t);
    return AuthResponse(user:u, token:t);
  }
}
