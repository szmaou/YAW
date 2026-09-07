import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/core/widgets/app_error_view.dart';
import 'package:yaw/features/admin/categories/data/category_repository.dart';
import 'package:yaw/shared/models/vehicle.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});
  @override
  ConsumerState<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  late Future<List<VehicleCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<VehicleCategory>> _fetch() async {
    return ref.read(categoryRepositoryProvider).getCategories();
  }

  SnackBar _snack(String msg, Color bg) => SnackBar(
        content: Text(msg, style: const TextStyle(color: YawColors.textPrimary)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: YawColors.border)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KELOLA KATEGORI'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go('/admin/dashboard')),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.go('/profile')),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: YawColors.border)),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) return const AppLoadingView();
          if (snap.hasError) {
            return AppErrorView(message: snap.error.toString(), onRetry: () => setState(() => _future = _fetch()));
          }
          final cats = snap.data ?? [];
          if (cats.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Belum ada kategori.', style: TextStyle(color: YawColors.textMuted))),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _fetch()),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = cats[i];
                return _row(c);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, null),
        backgroundColor: YawColors.primary,
        foregroundColor: YawColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Widget _row(VehicleCategory c) => InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(c.slug, style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text(c.description ?? '-', style: const TextStyle(fontSize: 11, color: YawColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined, size: 18), color: YawColors.textMuted, onPressed: () => _showForm(context, c)),
              const SizedBox(width: 4),
              IconButton(tooltip: 'Hapus', icon: const Icon(Icons.delete_outline_rounded, size: 18), color: YawColors.error, onPressed: () => _confirmDelete(context, c)),
            ]),
          ]),
        ),
      );

  void _showForm(BuildContext context, VehicleCategory? c) {
    final nameCtrl = TextEditingController(text: c?.name ?? '');
    final descCtrl = TextEditingController(text: c?.description ?? '');
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: YawColors.surface,
        title: Text(c == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama'), style: const TextStyle(color: YawColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), style: const TextStyle(color: YawColors.textPrimary)),
        ]),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(_snack('Nama kategori wajib diisi', YawColors.error));
                return;
              }
              Navigator.pop(d);
              await _save(context, c, name, desc);
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, VehicleCategory? c, String name, String desc) async {
    final repo = ref.read(categoryRepositoryProvider);
    try {
      if (c == null) {
        await repo.createCategory(name, desc);
      } else {
        await repo.updateCategory(c.id, name, desc);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(c == null ? 'Kategori ditambahkan' : 'Kategori diperbarui', YawColors.success));
      setState(() => _future = _fetch());
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }

  Future<void> _confirmDelete(BuildContext context, VehicleCategory c) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            backgroundColor: YawColors.surface,
            title: const Text('Hapus kategori?'),
            content: Text('${c.name} akan dihapus. Kategori yang masih dipakai kendaraan tidak bisa dihapus.'),
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(d, false), child: const Text('Batal')),
              ElevatedButton(onPressed: () => Navigator.pop(d, true), style: ElevatedButton.styleFrom(backgroundColor: YawColors.error), child: const Text('Hapus')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    final repo = ref.read(categoryRepositoryProvider);
    try {
      await repo.deleteCategory(c.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack('Kategori dihapus', YawColors.error));
      setState(() => _future = _fetch());
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }
}
