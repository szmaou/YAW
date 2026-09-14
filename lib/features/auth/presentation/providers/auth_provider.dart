import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../shared/models/user.dart';
import '../../data/auth_repository.dart';

final secureStorageProvider = Provider((_) => SecureStorage());
final apiClientProvider = Provider((ref) => ApiClient(ref.watch(secureStorageProvider)));
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(secureStorageProvider)));

class AuthState {
  const AuthState({this.user, this.isLoading=false, this.error});
  final User? user;
  final bool isLoading;
  final String? error;
  bool get isLoggedIn => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError=false, bool clearUser=false}) =>
    AuthState(user: clearUser? null : (user??this.user), isLoading:isLoading??this.isLoading, error: clearError? null : (error??this.error));
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo): super(const AuthState(isLoading: true));
  final AuthRepository _repo;

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading:true, clearError:true);
    final token = await _repo.getToken();
    if (token==null || token.isEmpty) { state = const AuthState(isLoading:false); return; }
    try {
      final u = await _repo.me();
      if (!mounted) return;
      state = AuthState(user:u, isLoading:false);
    } catch (_) {
      if (!mounted) return;
      await _repo.logout();
      state = const AuthState(isLoading:false);
    }
  }

  Future<void> login(String email, String pass) async {
    state = state.copyWith(isLoading:true, clearError:true);
    try {
      final res = await _repo.login(email, pass);
      state = AuthState(user: res.user, isLoading:false);
    } catch (e) {
      state = state.copyWith(isLoading:false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register(String name, String email, String pass, {String? phone}) async {
    state = state.copyWith(isLoading:true, clearError:true);
    try {
      final res = await _repo.register(name, email, pass, phone: phone);
      state = AuthState(user: res.user, isLoading:false);
    } catch (e) {
      state = state.copyWith(isLoading:false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isLoading:false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final n = AuthNotifier(ref.watch(authRepositoryProvider));
  Future.microtask(n.checkAuth);
  return n;
});
