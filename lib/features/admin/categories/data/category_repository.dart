import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/core/constants/app_constants.dart';
import 'package:yaw/core/errors/exceptions.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/core/network/mock_data.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';
import 'package:yaw/shared/models/vehicle.dart';

class CategoryRepository {
  CategoryRepository(this._api);
  final ApiClient _api;

  Future<List<VehicleCategory>> getCategories() async {
    try {
      final r = await _api.dio.get(ApiConstants.categories);
      final data = r.data;
      final List list = data is List ? data : data['data'] as List;
      return list.map((e) => VehicleCategory.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return MockData.categories;
    }
  }

  Future<VehicleCategory> createCategory(String name, String? description) async {
    try {
      final r = await _api.dio.post(ApiConstants.categories, data: {'name': name, 'description': description});
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return VehicleCategory.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Kategori gagal disimpan');
    }
  }

  Future<VehicleCategory> updateCategory(String id, String name, String? description) async {
    try {
      final r = await _api.dio.put('${ApiConstants.categories}/$id', data: {'name': name, 'description': description});
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return VehicleCategory.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Kategori gagal diperbarui');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _api.dio.delete('${ApiConstants.categories}/$id');
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Kategori gagal dihapus');
    }
  }

  Exception _mapWriteError(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException('Tidak dapat terhubung ke server. Periksa koneksi.');
    }
    if (e.response?.statusCode == 401) return const AuthException('Sesi expired, silakan login kembali');
    return Exception(ApiClient.msgFrom(e.response?.data, fallback));
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});
