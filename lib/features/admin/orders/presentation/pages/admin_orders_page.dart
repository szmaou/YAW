import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/core/utils/formatters.dart';
import 'package:yaw/core/widgets/app_error_view.dart';
import 'package:yaw/features/admin/shared/admin_app_bar.dart';
import 'package:yaw/features/orders/data/order_repository.dart';
import 'package:yaw/shared/models/order.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});
  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  final List<Order> _orders = [];
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
      _orders.clear();
      _page = 1;
    }
    setState(() => _loading = true);
    try {
      final res = await ref.read(orderRepositoryProvider).getOrders(page: _page, limit: 20);
      setState(() {
        _orders
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
    if (_loadingMore || _orders.length >= _total) return;
    setState(() => _loadingMore = true);
    _page++;
    try {
      final res = await ref.read(orderRepositoryProvider).getOrders(page: _page, limit: 20);
      setState(() {
        _orders.addAll(res.data);
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
    Widget body;
    if (_loading && _orders.isEmpty) {
      body = const AppLoadingView();
    } else if (_error != null && _orders.isEmpty) {
      body = AppErrorView(message: _error!, onRetry: () => _load(refresh: true));
    } else if (_orders.isEmpty) {
      body = ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Belum ada pesanan.', style: TextStyle(color: YawColors.textMuted))),
        ],
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _orders.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (i >= _orders.length) {
              if (_orders.length >= _total) return const SizedBox.shrink();
              Future.microtask(() => _loadMore());
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: YawColors.primary)));
            }
            return _row(_orders[i]);
          },
        ),
      );
    }
    return Scaffold(
      appBar: const AdminAppBar(title: 'KELOLA PESANAN'),
      body: body,
    );
  }

  Widget _row(Order o) => InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(flex: 4, child: Text(o.orderNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .4))),
              Expanded(flex: 4, child: Text(o.userName ?? '-', style: const TextStyle(fontSize: 11, color: YawColors.textMuted))),
              Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: _StatusChip(status: o.status))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(Formatters.idr(o.total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
              Text(o.createdAt != null ? Formatters.date(o.createdAt!) : '-', style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
              const SizedBox(width: 8),
              Text('${o.items.length} item', style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
              const SizedBox(width: 8),
              _StatusDropdown(order: o, onChanged: (s) => _changeStatus(context, o, s)),
            ]),
          ]),
        ),
      );

  Future<void> _changeStatus(BuildContext context, Order o, String status) async {
    final repo = ref.read(orderRepositoryProvider);
    try {
      await repo.updateStatus(o.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack('Status diubah menjadi $status', YawColors.success));
      _load(refresh: true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final c = switch (status) {
      'pending' => YawColors.warning,
      'confirmed' => YawColors.primary,
      'processing' => YawColors.secondary,
      'completed' => YawColors.success,
      'cancelled' => YawColors.error,
      _ => YawColors.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: .14), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: .3))),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5, color: c)),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order, required this.onChanged});
  final Order order;
  final ValueChanged<String> onChanged;

  static const _options = ['pending', 'confirmed', 'processing', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    final current = _options.contains(order.status) ? order.status : 'pending';
    return SizedBox(
      width: 130,
      child: DropdownButton<String>(
        value: current,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 11, color: YawColors.textMuted),
        dropdownColor: YawColors.surface,
        items: _options.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 11)))).toList(),
        onChanged: (v) {
          if (v != null && v != current) onChanged(v);
        },
      ),
    );
  }
}
