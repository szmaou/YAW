import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../shared/widgets/app_shell.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/vehicles/presentation/pages/vehicle_list_page.dart';
import '../features/vehicles/presentation/pages/vehicle_detail_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/admin/dashboard/presentation/admin_dashboard_page.dart';
import '../features/admin/vehicles/presentation/pages/admin_vehicles_page.dart';
import '../features/admin/vehicles/presentation/pages/admin_vehicle_form_page.dart';
import '../features/admin/users/presentation/pages/admin_users_page.dart';
import '../features/admin/categories/presentation/pages/admin_categories_page.dart';
import '../features/admin/orders/presentation/pages/admin_orders_page.dart';

/// Notifies GoRouter when the auth state changes so it can re-run redirects,
/// without recreating the router instance (which would collide with the
/// Navigator's internal page key reservation).
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/',
    redirect: (ctx, state) {
      final auth = ref.read(authProvider);
      final loc = state.uri.path;
      final isAuthRoute = loc == '/login' || loc == '/register';
      final isSplash = loc == '/';
      final loggedIn = auth.isLoggedIn;
      final loading = auth.isLoading;
      if (loading) return null;
      if (isSplash) return loggedIn ? '/home' : '/login';
      if (!loggedIn && !isAuthRoute && !loc.startsWith('/vehicles')) {
        // allow browsing vehicles without login, but protect fav/orders/profile/admin
        if (loc.startsWith('/favorites') || loc.startsWith('/orders') || loc.startsWith('/profile') || loc.startsWith('/admin')) {
          return '/login';
        }
      }
      // Admin-only guard: logged-in non-admins cannot reach admin subpaths.
      if (loggedIn && !auth.isAdmin && loc.startsWith('/admin')) {
        return '/home';
      }
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(name: 'splash', path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(name: 'login', path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(name: 'register', path: '/register', builder: (_, __) => const RegisterPage()),
      // Admin outside shell
      GoRoute(name: 'adminDashboard', path: '/admin/dashboard', builder: (_, __) => const AdminDashboardPage()),
      GoRoute(name: 'admin', path: '/admin', redirect: (_, __) => '/admin/dashboard'),
      GoRoute(name: 'adminVehicles', path: '/admin/vehicles', builder: (_, __) => const AdminVehiclesPage()),
      GoRoute(name: 'adminVehicleNew', path: '/admin/vehicles/new', builder: (_, __) => const AdminVehicleFormPage()),
      GoRoute(name: 'adminVehicleEdit', path: '/admin/vehicles/:id/edit', builder: (_, s) => AdminVehicleFormPage(id: s.pathParameters['id']!)),
      GoRoute(name: 'adminUsers', path: '/admin/users', builder: (_, __) => const AdminUsersPage()),
      GoRoute(name: 'adminCategories', path: '/admin/categories', builder: (_, __) => const AdminCategoriesPage()),
      GoRoute(name: 'adminOrders', path: '/admin/orders', builder: (_, __) => const AdminOrdersPage()),

      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(name: 'home', path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(name: 'vehicles', path: '/vehicles', builder: (_, __) => const VehicleListPage()),
          GoRoute(name: 'vehicleDetail', path: '/vehicles/:id', builder: (_, s) => VehicleDetailPage(id: s.pathParameters['id']!)),
          GoRoute(name: 'favorites', path: '/favorites', builder: (_, __) => const FavoritesPage()),
          GoRoute(name: 'orders', path: '/orders', builder: (_, __) => const OrdersPage()),
          GoRoute(name: 'orderDetail', path: '/orders/:id', builder: (_, s) => OrderDetailPage(id: s.pathParameters['id']!)),
          GoRoute(name: 'profile', path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
    ],
    errorBuilder: (_, s) => Scaffold(body: Center(child: Text('404 — ${s.uri.path}'))),
  );
});
