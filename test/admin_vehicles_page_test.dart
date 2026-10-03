import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/core/network/api_client.dart';
import 'package:yaw/core/storage/secure_storage.dart';
import 'package:yaw/features/admin/vehicles/presentation/pages/admin_vehicles_page.dart';
import 'package:yaw/features/vehicles/data/vehicle_repository.dart';
import 'package:yaw/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:yaw/shared/models/vehicle.dart';

/// Repo palsu: 2 kendaraan dengan nama + harga panjang (kasus terburuk mobile).
class FakeVehicleRepo extends VehicleRepository {
  FakeVehicleRepo() : super(ApiClient(SecureStorage()));
  bool deleted = false;

  Vehicle _v(String id, String name, double price) => Vehicle(
        id: id, categoryId: '1', name: name, slug: 'slug-$id',
        brand: 'Toyota', model: 'Fortuner 2.8 VRZ 4x4 Long Name Edition',
        year: 2024, price: price, stock: 6,
      );

  @override
  Future<Paginated<Vehicle>> getVehicles(VehicleQuery q) async => Paginated(
        data: [_v('1', 'Fortuner 2.8 VRZ Panjang Sekali', 3750000000), _v('2', 'Avanza', 250000000)],
        page: 1, limit: 20, total: 2,
      );

  @override
  Future<void> deleteVehicle(String id) async {
    deleted = true;
  }
}

Future<void> _pumpAdminPage(WidgetTester tester, FakeVehicleRepo fake) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  final router = GoRouter(
    initialLocation: '/admin/vehicles',
    routes: [
      GoRoute(path: '/admin/vehicles', builder: (_, __) => const AdminVehiclesPage()),
      GoRoute(path: '/admin/vehicles/:id/edit', builder: (_, __) => const Scaffold(body: Text('EDIT'))),
      GoRoute(path: '/vehicles/:id', builder: (_, __) => const Scaffold(body: Text('DETAIL'))),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [vehicleRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mobile 360px: baris kelola kendaraan tidak overflow', (tester) async {
    final fake = FakeVehicleRepo();
    await _pumpAdminPage(tester, fake);
    expect(tester.takeException(), isNull);
    // Kedua tombol hapus terlihat & bisa diketuk.
    expect(find.byTooltip('Hapus'), findsNWidgets(2));
  });

  testWidgets('mobile 360px: ketuk hapus -> dialog -> Hapus memanggil repo', (tester) async {
    final fake = FakeVehicleRepo();
    await _pumpAdminPage(tester, fake);
    await tester.tap(find.byTooltip('Hapus').first);
    await tester.pumpAndSettle();
    expect(find.text('Hapus kendaraan?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(fake.deleted, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('semua lebar (320/414/600/800/1280): tidak overflow', (tester) async {
    for (final w in [320.0, 414.0, 600.0, 800.0, 1280.0]) {
      tester.view.physicalSize = Size(w, 800);
      tester.view.devicePixelRatio = 1.0;
      final fake = FakeVehicleRepo();
      final router = GoRouter(
        initialLocation: '/admin/vehicles',
        routes: [
          GoRoute(path: '/admin/vehicles', builder: (_, __) => const AdminVehiclesPage()),
          GoRoute(path: '/admin/vehicles/:id/edit', builder: (_, __) => const Scaffold(body: Text('EDIT'))),
          GoRoute(path: '/vehicles/:id', builder: (_, __) => const Scaffold(body: Text('DETAIL'))),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [vehicleRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow pada lebar $w');
      expect(find.byTooltip('Hapus'), findsNWidgets(2));
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
