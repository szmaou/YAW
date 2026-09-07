import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/core/utils/formatters.dart';
import 'package:yaw/core/widgets/app_error_view.dart';
import 'package:yaw/features/admin/shared/admin_app_bar.dart';
import 'package:yaw/features/admin/users/data/user_repository.dart';
import 'package:yaw/features/auth/presentation/providers/auth_provider.dart';
import 'package:yaw/shared/models/user.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});
  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final List<User> _users = [];
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  SnackBar _snack(String msg, Color bg) => SnackBar(
        content: Text(msg, style: const TextStyle(color: YawColors.textPrimary)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: YawColors.border)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _users.clear();
      _page = 1;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final res = await repo.getUsers(page: _page, limit: 20);
      setState(() {
        _users
          ..clear()
          ..addAll(res.data);
        _total = res.total;
        _error = null;
      });
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    final hasMore = _users.length < _total;
    if (_loadingMore || !hasMore) return;
    setState(() => _loadingMore = true);
    _page++;
    try {
      final repo = ref.read(userRepositoryProvider);
      final res = await repo.getUsers(page: _page, limit: 20);
      setState(() {
        _users.addAll(res.data);
        _total = res.total;
      });
    } on Exception catch (e) {
      _page--;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider).user;
    Widget body;
    if (_loading && _users.isEmpty) {
      body = const AppLoadingView();
    } else if (_error != null && _users.isEmpty) {
      body = AppErrorView(message: _error!, onRetry: () => _load(refresh: true));
    } else if (_users.isEmpty) {
      body = ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Belum ada pengguna.', style: TextStyle(color: YawColors.textMuted))),
        ],
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _users.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (i >= _users.length) {
              if (_users.length >= _total) return const SizedBox.shrink();
              Future.microtask(() => _loadMore());
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: YawColors.primary)));
            }
            final u = _users[i];
            final isMe = me?.id == u.id;
            return _buildRow(u, isMe);
          },
        ),
      );
    }
    return Scaffold(
      appBar: const AdminAppBar(title: 'KELOLA PENGGUNA'),
      body: body,
    );
  }

  Widget _buildRow(User u, bool isSelf) {
    final avatar = _avatar(u);
    final info = Expanded(
      flex: 9,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          _roleBadge(u.role),
        ]),
        Text(u.email, style: const TextStyle(fontSize: 11, color: YawColors.textMuted)),
        if (u.phone != null && u.phone!.isNotEmpty)
          Text(u.phone!, style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
      ]),
    );
    final createdAt = Expanded(
      flex: 5,
      child: Text(u.createdAt != null ? Formatters.date(u.createdAt!) : '-', style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
    );
    final actions = Expanded(
      flex: 3,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined, size: 18), color: YawColors.textMuted, onPressed: () => _edit(context, u)),
        const SizedBox(width: 4),
        if (!isSelf)
          IconButton(tooltip: 'Hapus', icon: const Icon(Icons.delete_outline_rounded, size: 18), color: YawColors.error, onPressed: () => _confirmDelete(context, u)),
      ]),
    );
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
        child: Row(children: [avatar, const SizedBox(width: 10), info, createdAt, actions]),
      ),
    );
  }

  Widget _avatar(User u) {
    final hasAvatar = u.avatar != null && u.avatar!.isNotEmpty;
    final placeholder = Center(
      child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.w800, color: YawColors.primary)),
    );
    final bg = BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: YawColors.border));
    if (!hasAvatar) {
      return Container(width: 40, height: 40, decoration: bg, child: placeholder);
    }
    return Container(
      width: 40, height: 40,
      decoration: bg,
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: u.avatar!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }

  Widget _roleBadge(String role) {
    final c = role == 'admin' ? YawColors.secondary : (role == 'superadmin' ? YawColors.warning : YawColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: .14), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: .3))),
      child: Text(role.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5, color: c)),
    );
  }

  void _edit(BuildContext context, User u) {
    final nameCtrl = TextEditingController(text: u.name);
    final phoneCtrl = TextEditingController(text: u.phone ?? '');
    String role = u.role;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: YawColors.surface,
        title: const Text('Edit Pengguna'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama'), style: const TextStyle(color: YawColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. HP'), style: const TextStyle(color: YawColors.textPrimary)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'user', child: Text('User')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => role = v!,
          ),
        ]),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              await _saveUser(context, u, nameCtrl.text, phoneCtrl.text, role);
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUser(BuildContext context, User u, String name, String phone, String role) async {
    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.updateUser(u.id, {'name': name, 'phone': phone, 'role': role});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack('Pengguna diperbarui', YawColors.success));
      _load(refresh: true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }

  Future<void> _confirmDelete(BuildContext context, User u) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: YawColors.surface,
            title: const Text('Hapus pengguna?'),
            content: Text('${u.name} akan dihapus. Lanjutkan?'),
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: YawColors.error), child: const Text('Hapus')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.deleteUser(u.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack('Pengguna dihapus', YawColors.error));
      _load(refresh: true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }
}
