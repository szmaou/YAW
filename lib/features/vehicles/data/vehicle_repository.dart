import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/models/vehicle.dart';

class VehicleQuery {
  const VehicleQuery({this.page=1, this.limit=20, this.search, this.category, this.brand, this.minPrice, this.maxPrice, this.year, this.fuelType, this.transmission});
  final int page; final int limit; final String? search; final String? category; final String? brand;
  final double? minPrice; final double? maxPrice; final int? year; final String? fuelType; final String? transmission;
  Map<String,dynamic> toMap() => {
    'page':page,'limit':limit,
    if(search!=null && search!.isNotEmpty) 'search':search,
    if(category!=null) 'category':category,
    if(brand!=null) 'brand':brand,
    if(minPrice!=null) 'min_price':minPrice,
    if(maxPrice!=null) 'max_price':maxPrice,
    if(year!=null) 'year':year,
    if(fuelType!=null) 'fuel_type':fuelType,
    if(transmission!=null) 'transmission':transmission,
  };
}

class VehicleRepository {
  VehicleRepository(this._api);
  final ApiClient _api;

  Future<Paginated<Vehicle>> getVehicles(VehicleQuery q) async {
    final r = await _api.dio.get(ApiConstants.vehicles, queryParameters: q.toMap());
    final list = (r.data['data'] as List).map((e)=>Vehicle.fromJson(Map<String,dynamic>.from(e))).toList();
    final p = r.data['pagination'];
    return Paginated(data:list, page:p?['page']??q.page, limit:p?['limit']??q.limit, total:p?['total']??list.length);
  }

  Future<Vehicle> getById(String id) async {
    final r = await _api.dio.get('${ApiConstants.vehicles}/$id');
    final d = r.data['data'] is Map ? r.data['data'] : r.data;
    return Vehicle.fromJson(Map<String,dynamic>.from(d as Map));
  }

  Future<List<VehicleCategory>> getCategories() async {
    final r = await _api.dio.get(ApiConstants.categories);
    return (r.data['data'] as List).map((e)=> VehicleCategory.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    try {
      final r = await _api.dio.post(ApiConstants.vehicles, data: data);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Vehicle.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Vehicle gagal disimpan');
    }
  }

  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data) async {
    try {
      final r = await _api.dio.put('${ApiConstants.vehicles}/$id', data: data);
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Vehicle.fromJson(Map<String, dynamic>.from(d as Map));
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Vehicle gagal diperbarui');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _api.dio.delete('${ApiConstants.vehicles}/$id');
    } on DioException catch (e) {
      throw _mapWriteError(e, 'Vehicle gagal dihapus');
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
