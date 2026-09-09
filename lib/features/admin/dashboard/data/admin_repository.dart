import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/core/constants/app_constants.dart';
import 'package:yaw/core/errors/exceptions.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';
import 'package:yaw/shared/models/order.dart';

/// Aggregated snapshot returned by `GET /admin/dashboard`.
class AdminDashboardData {
  const AdminDashboardData({
    required this.totalVehicles,
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.recentOrders,
  });

  final int totalVehicles;
  final int totalUsers;
  final int totalOrders;
  final num totalRevenue;
  final int pendingOrders;
  final int completedOrders;
  final List<Order> recentOrders;

  factory AdminDashboardData.fromJson(Map<String, dynamic> j) => AdminDashboardData(
        totalVehicles: (j['totalVehicles'] as num?)?.toInt() ?? 0,
        totalUsers: (j['totalUsers'] as num?)?.toInt() ?? 0,
        totalOrders: (j['totalOrders'] as num?)?.toInt() ?? 0,
        totalRevenue: j['totalRevenue'] ?? 0,
        pendingOrders: (j['pendingOrders'] as num?)?.toInt() ?? 0,
        completedOrders: (j['completedOrders'] as num?)?.toInt() ?? 0,
        recentOrders: j['recentOrders'] is List
            ? (j['recentOrders'] as List)
                .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
      );
}

/// One (month, orders, revenue) row from `GET /admin/statistics`.
class MonthlyStat {
  const MonthlyStat({required this.month, required this.orders, required this.revenue});
  final String month;
  final int orders;
  final num revenue;

  factory MonthlyStat.fromJson(Map<String, dynamic> j) => MonthlyStat(
        month: j['month']?.toString() ?? '',
        orders: (j['orders'] as num?)?.toInt() ?? 0,
        revenue: j['revenue'] ?? 0,
      );
}

/// Aggregated snapshot returned by `GET /admin/statistics`.
class AdminStatisticsData {
  const AdminStatisticsData({required this.monthly, required this.byStatus, required this.popular});
  final List<MonthlyStat> monthly;
  final List<Map<String, dynamic>> byStatus;
  final List<Map<String, dynamic>> popular;

  factory AdminStatisticsData.fromJson(Map<String, dynamic> j) => AdminStatisticsData(
        monthly: j['monthly'] is List
            ? (j['monthly'] as List)
                .map((e) => MonthlyStat.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
        byStatus: _asMapList(j['byStatus']),
        popular: _asMapList(j['popular']),
      );

  static List<Map<String, dynamic>> _asMapList(dynamic v) => v is List
      ? v.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      : const [];
}

class AdminRepository {
  AdminRepository(this._api);
  final ApiClient _api;

  Future<AdminDashboardData> getDashboard() async {
    try {
      final r = await _api.dio.get(ApiConstants.adminDashboard);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return AdminDashboardData.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat dashboard');
    }
  }

  Future<AdminStatisticsData> getStatistics() async {
    try {
      final r = await _api.dio.get(ApiConstants.adminStatistics);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return AdminStatisticsData.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapError(e, 'Gagal memuat statistik');
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

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});
