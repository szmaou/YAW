import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/features/vehicles/data/vehicle_repository.dart';
import 'package:yaw/shared/models/vehicle.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(ref.watch(apiClientProvider));
});

final categoriesProvider = FutureProvider<List<VehicleCategory>>((ref) async {
  return ref.watch(vehicleRepositoryProvider).getCategories();
});

class VehicleListState {
  const VehicleListState({this.data=const [], this.page=1, this.total=0, this.isLoading=false, this.isLoadingMore=false, this.error, this.query=const VehicleQuery()});
  final List<Vehicle> data; final int page; final int total; final bool isLoading; final bool isLoadingMore; final String? error; final VehicleQuery query;
  bool get hasMore => data.length < total;
  VehicleListState copyWith({List<Vehicle>? data, int? page, int? total, bool? isLoading, bool? isLoadingMore, String? error, VehicleQuery? query}) =>
    VehicleListState(data:data??this.data, page:page??this.page, total:total??this.total, isLoading:isLoading??this.isLoading, isLoadingMore:isLoadingMore??this.isLoadingMore, error:error, query:query??this.query);
}

class VehicleListNotifier extends StateNotifier<VehicleListState> {
  VehicleListNotifier(this._repo): super(const VehicleListState());
  final VehicleRepository _repo;

  Future<void> load({VehicleQuery query = const VehicleQuery(), bool refresh=false}) async {
    if (refresh) {
      state = VehicleListState(isLoading:true, query:query);
    } else if (state.data.isEmpty) {
      state = state.copyWith(isLoading:true, error:null);
    }
    state = state.copyWith(query:query);
    try {
      final res = await _repo.getVehicles(query);
      if (!mounted) return;
      state = VehicleListState(data:res.data, page:res.page, total:res.total, isLoading:false, query:query);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading:false, error:e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore:true);
    try {
      final next = VehicleQuery(
        page: state.page+1, limit: state.query.limit, search: state.query.search,
        category: state.query.category, brand: state.query.brand,
        minPrice: state.query.minPrice, maxPrice: state.query.maxPrice,
        year: state.query.year, fuelType: state.query.fuelType, transmission: state.query.transmission);
      final res = await _repo.getVehicles(next);
      state = state.copyWith(data:[...state.data, ...res.data], page:res.page, total:res.total, isLoadingMore:false, query:next);
    } catch (e) {
      state = state.copyWith(isLoadingMore:false, error:e.toString());
    }
  }
}

final vehicleListProvider = StateNotifierProvider<VehicleListNotifier, VehicleListState>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  final n = VehicleListNotifier(repo);
  Future.microtask(()=> n.load());
  return n;
});

final vehicleDetailProvider = FutureProvider.family<Vehicle,String>((ref,id) async {
  return ref.watch(vehicleRepositoryProvider).getById(id);
});
