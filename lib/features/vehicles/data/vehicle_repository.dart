import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/mock_data.dart';
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
    try {
      final r = await _api.dio.get(ApiConstants.vehicles, queryParameters: q.toMap());
      final list = (r.data['data'] as List).map((e)=>Vehicle.fromJson(Map<String,dynamic>.from(e))).toList();
      final p = r.data['pagination'];
      return Paginated(data:list, page:p?['page']??q.page, limit:p?['limit']??q.limit, total:p?['total']??list.length);
    } on DioException catch (e) {
      if (e.type==DioExceptionType.connectionError || e.type==DioExceptionType.connectionTimeout) {
        return _mockFilter(q);
      }
      rethrow;
    }
  }

  Future<Vehicle> getById(String id) async {
    try {
      final r = await _api.dio.get('${ApiConstants.vehicles}/$id');
      final d = r.data['data'] is Map ? r.data['data'] : r.data;
      return Vehicle.fromJson(Map<String,dynamic>.from(d as Map));
    } on DioException catch (e) {
      if (e.type==DioExceptionType.connectionError) {
        return MockData.vehicles.firstWhere((v)=> v.id==id, orElse: ()=> MockData.vehicles.first);
      }
      rethrow;
    }
  }

  Future<List<VehicleCategory>> getCategories() async {
    try {
      final r = await _api.dio.get(ApiConstants.categories);
      return (r.data['data'] as List).map((e)=> VehicleCategory.fromJson(Map<String,dynamic>.from(e))).toList();
    } catch (_) {
      return MockData.categories;
    }
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

  Paginated<Vehicle> _mockFilter(VehicleQuery q) {
    var list = MockData.vehicles;
    if (q.search!=null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((v)=> '${v.brand} ${v.name} ${v.model}'.toLowerCase().contains(s)).toList();
    }
    if (q.category!=null && q.category!.isNotEmpty) {
      final cat = MockData.categories.where((c)=> c.slug==q.category || c.id==q.category).map((c)=> c.id).toSet();
      if (cat.isNotEmpty) list = list.where((v)=> cat.contains(v.categoryId)).toList();
    }
    if (q.brand!=null && q.brand!.isNotEmpty) list = list.where((v)=> v.brand.toLowerCase()==q.brand!.toLowerCase()).toList();
    if (q.minPrice!=null) list = list.where((v)=> v.price >= q.minPrice!).toList();
    if (q.maxPrice!=null) list = list.where((v)=> v.price <= q.maxPrice!).toList();
    if (q.year!=null) list = list.where((v)=> v.year==q.year).toList();
    if (q.fuelType!=null) list = list.where((v)=> v.fuelType?.toLowerCase()==q.fuelType!.toLowerCase()).toList();
    if (q.transmission!=null) list = list.where((v)=> v.transmission?.toLowerCase()==q.transmission!.toLowerCase()).toList();
    final total = list.length;
    final start = (q.page-1)*q.limit;
    final end = (start+q.limit).clamp(0, total);
    final pageData = start < total ? list.sublist(start,end) : <Vehicle>[];
    return Paginated(data:pageData, page:q.page, limit:q.limit, total:total);
  }
}
