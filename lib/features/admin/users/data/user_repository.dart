import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/core/constants/app_constants.dart';
import 'package:yaw/core/errors/exceptions.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';
import 'package:yaw/shared/models/user.dart';
import 'package:yaw/shared/models/vehicle.dart';

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<Paginated<User>> getUsers({int page = 1, int limit = 20, String? search}) async {
    try {
      final r = await _api.dio.get(
        ApiConstants.users,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final data = r.data;
      if (data is List) {
        final list = data.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
        return Paginated(data: list, page: page, limit: limit, total: list.length);
      }
      final list = (data['data'] as List).map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
      final p = data['pagination'];
      return Paginated(data: list, page: p?['page'] ?? page, limit: p?['limit'] ?? limit, total: p?['total'] ?? list.length);
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat pengguna');
    }
  }

  Future<User> getUser(String id) async {
    try {
      final r = await _api.dio.get('${ApiConstants.users}/$id');
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat pengguna');
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final r = await _api.dio.put('${ApiConstants.users}/$id', data: data);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memperbarui pengguna');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _api.dio.delete('${ApiConstants.users}/$id');
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal menghapus pengguna');
    }
  }

  Exception _mapError(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException('Tidak dapat terhubung ke server. Periksa koneksi.');
    }
    if (e.response?.statusCode == 401) return const AuthException('Sesi expired, silakan login kembali');
    return Exception(ApiClient.msgFrom(e.response?.data, fallback));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});
