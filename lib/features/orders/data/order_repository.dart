import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/core/constants/app_constants.dart';
import 'package:yaw/core/errors/exceptions.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';
import 'package:yaw/shared/models/order.dart';
import 'package:yaw/shared/models/vehicle.dart';

class OrderRepository {
  OrderRepository(this._api);
  final ApiClient _api;

  Future<Paginated<Order>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final r = await _api.dio.get(
        ApiConstants.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = r.data;
      if (data is List) {
        final list = data.map((e) => Order.fromJson(Map<String, dynamic>.from(e))).toList();
        return Paginated(data: list, page: page, limit: limit, total: list.length);
      }
      final list = (data['data'] as List).map((e) => Order.fromJson(Map<String, dynamic>.from(e))).toList();
      final p = data['pagination'];
      return Paginated(data: list, page: p?['page'] ?? page, limit: p?['limit'] ?? limit, total: p?['total'] ?? list.length);
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat pesanan');
    }
  }

  Future<Order> getOrder(String id) async {
    try {
      final r = await _api.dio.get('${ApiConstants.orders}/$id');
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Order.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat pesanan');
    }
  }

  Future<Order> createOrder(List<Map<String, dynamic>> items, {String? paymentMethod}) async {
    try {
      final r = await _api.dio.post(
        ApiConstants.orders,
        data: {'items': items, if (paymentMethod != null) 'payment_method': paymentMethod},
      );
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Order.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Pesanan gagal dibuat');
    }
  }

  Future<Order> updateStatus(String id, String status) async {
    try {
      final r = await _api.dio.put('${ApiConstants.orders}/$id/status', data: {'status': status});
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Order.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Status pesanan gagal diperbarui');
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

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});
