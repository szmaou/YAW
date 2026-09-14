import 'package:flutter_riverpod/legacy.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';

class FavoritesRepo {
  FavoritesRepo(this.api);
  final ApiClient api;
  final Set<String> _ids = {};
  Set<String> get ids => _ids;

  Future<void> toggle(String id) async {
    final wasFav = _ids.contains(id);
    // Optimistic update so UI feels instant.
    if (wasFav) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    try {
      if (wasFav) {
        await api.dio.delete('/favorites/$id');
      } else {
        await api.dio.post('/favorites', data: {'vehicle_id': id});
      }
    } catch (e) {
      // Revert optimistic update — never silently succeed offline.
      if (wasFav) {
        _ids.add(id);
      } else {
        _ids.remove(id);
      }
      rethrow;
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
