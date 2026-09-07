import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';

class FavoritesRepo {
  FavoritesRepo(this.api);
  final ApiClient api;
  final Set<String> _ids = {};
  Set<String> get ids => _ids;

  Future<void> toggle(String id) async {
    try {
      if (_ids.contains(id)) {
        await api.dio.delete('/favorites/$id');
        _ids.remove(id);
      } else {
        await api.dio.post('/favorites', data: {'vehicle_id': id});
        _ids.add(id);
      }
    } catch (_) {
      if (_ids.contains(id)) _ids.remove(id); else _ids.add(id);
    }
  }
}

class FavoritesState {
  const FavoritesState({this.ids = const {}, this.isLoading = false});
  final Set<String> ids; final bool isLoading;
  bool isFav(String id) => ids.contains(id);
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier(this.repo) : super(const FavoritesState());
  final FavoritesRepo repo;
  Future<void> toggle(String id) async {
    await repo.toggle(id);
    state = FavoritesState(ids: Set.from(repo.ids));
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final api = ref.watch(apiClientProvider);
  return FavoritesNotifier(FavoritesRepo(api));
});
