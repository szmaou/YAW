import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/core/widgets/app_error_view.dart';
import 'package:yaw/features/admin/shared/admin_app_bar.dart';
import 'package:yaw/features/vehicles/data/vehicle_repository.dart';
import 'package:yaw/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:yaw/shared/models/vehicle.dart';

class AdminVehiclesPage extends ConsumerStatefulWidget {
  const AdminVehiclesPage({super.key});
  @override
  ConsumerState<AdminVehiclesPage> createState() => _AdminVehiclesPageState();
}

class _AdminVehiclesPageState extends ConsumerState<AdminVehiclesPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleListProvider);
    return Scaffold(
      appBar: const AdminAppBar(title: 'KELOLA KENDARAAN'),
      body: state.isLoading && state.data.isEmpty
          ? const AppLoadingView()
          : state.error != null && state.data.isEmpty
              ? AppErrorView(message: state.error!, onRetry: () => ref.read(vehicleListProvider.notifier).load(refresh: true))
              : _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/vehicles/new'),
        backgroundColor: YawColors.primary,
        foregroundColor: YawColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kendaraan'),
      ),
    );
  }

  Widget _buildBody(VehicleListState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header(),
      Expanded(
        child: state.data.isEmpty
            ? const AppEmptyView(
                title: 'Tidak ada kendaraan',
                subtitle: 'Belum ada data kendaraan pada halaman ini.',
                icon: Icons.directions_car_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(vehicleListProvider.notifier).load(query: state.query, refresh: true),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.data.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    if (i >= state.data.length) {
                      if (!state.hasMore) return const SizedBox.shrink();
                      Future.microtask(() => ref.read(vehicleListProvider.notifier).loadMore());
                      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: YawColors.primary)));
                    }
                    final v = state.data[i];
                    return _row(context, v);
                  },
                ),
              ),
      ),
      if (state.isLoadingMore) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator(color: YawColors.primary))),
      if (state.error != null && state.data.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(state.error!, style: const TextStyle(color: YawColors.error, fontSize: 12)),
        ),
    ]);
  }

  Widget _header() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)),
        child: const Row(children: [
          Expanded(flex: 10, child: Text('KENDARAAN', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textDim))),
          Expanded(flex: 4, child: Text('KATEGORI', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textDim))),
          Expanded(flex: 3, child: Text('HARGA', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textDim))),
          Expanded(flex: 2, child: Text('STOK', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textDim))),
          Expanded(flex: 3, child: SizedBox()),
        ]),
      );

  Widget _row(BuildContext context, Vehicle v) => InkWell(
        onTap: () => context.push('/vehicles/${v.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
          child: Row(children: [
            Expanded(
              flex: 10,
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: YawColors.border)),
                  clipBehavior: Clip.antiAlias,
                  child: v.primaryImage.isNotEmpty
                      ? CachedNetworkImage(imageUrl: v.primaryImage, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(Icons.directions_car_rounded, size: 22, color: YawColors.textDim))
                      : const Icon(Icons.directions_car_rounded, size: 22, color: YawColors.textDim),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${v.brand} ${v.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text(v.model, style: const TextStyle(fontSize: 11, color: YawColors.textMuted)),
                ])),
              ]),
            ),
            Expanded(flex: 4, child: Text(v.category?.name ?? '-', style: const TextStyle(fontSize: 12, color: YawColors.textMuted))),
            Expanded(flex: 3, child: Text(v.displayPrice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('Stok ${v.stock}', style: TextStyle(fontSize: 12, color: v.stock > 0 ? YawColors.textPrimary : YawColors.error, fontWeight: FontWeight.w600))),
            Expanded(
              flex: 3,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined, size: 18), color: YawColors.textMuted, onPressed: () => context.push('/admin/vehicles/${v.id}/edit')),
                const SizedBox(width: 4),
                IconButton(tooltip: 'Hapus', icon: const Icon(Icons.delete_outline_rounded, size: 18), color: YawColors.error, onPressed: () => _confirmDelete(context, v, ref.read(vehicleRepositoryProvider))),
              ]),
            ),
          ]),
        ),
      );

  Future<void> _confirmDelete(BuildContext context, Vehicle v, VehicleRepository repo) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: YawColors.surface,
            title: const Text('Hapus kendaraan?'),
            content: Text('${v.brand} ${v.name} akan dihapus. Lanjutkan?'),
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: YawColors.error), child: const Text('Hapus')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      await repo.deleteVehicle(v.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack('Kendaraan dihapus', YawColors.error));
      ref.invalidate(vehicleListProvider);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }

  SnackBar _snack(String msg, Color bg) => SnackBar(
        content: Text(msg, style: const TextStyle(color: YawColors.textPrimary)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: YawColors.border)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
}
