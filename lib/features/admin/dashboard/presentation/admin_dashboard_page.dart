import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/core/utils/formatters.dart';
import 'package:yaw/core/widgets/app_error_view.dart';
import 'package:yaw/features/admin/dashboard/data/admin_repository.dart';
import 'package:yaw/shared/models/order.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  late Future<DashboardSnapshot> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = _load();
  }

  Future<DashboardSnapshot> _load() async {
    final repo = ref.read(adminRepositoryProvider);
    final dashboard = await repo.getDashboard();
    final statistics = await repo.getStatistics();
    return DashboardSnapshot(dashboard: dashboard, statistics: statistics);
  }

  void _refresh() => setState(() => _snapshot = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: YawColors.border),
        ),
      ),
      body: FutureBuilder<DashboardSnapshot>(
        future: _snapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingView();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(data.dashboard),
                  const SizedBox(height: 16),
                  _buildSalesChart(data.statistics),
                  const SizedBox(height: 16),
                  _buildRecentOrders(data.dashboard),
                  const SizedBox(height: 16),
                  // Use `go` (not `push`) — admin lives inside the ShellRoute,
                  // push would duplicate the shell page key.
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _AdminAction(
                        icon: Icons.directions_car_rounded,
                        label: 'Kelola Kendaraan',
                        onTap: () => context.go('/admin/vehicles'),
                      ),
                      _AdminAction(
                        icon: Icons.category_rounded,
                        label: 'Kelola Kategori',
                        onTap: () => context.go('/admin/categories'),
                      ),
                      _AdminAction(
                        icon: Icons.people_rounded,
                        label: 'Kelola Users',
                        onTap: () => context.go('/admin/users'),
                      ),
                      _AdminAction(
                        icon: Icons.receipt_long_rounded,
                        label: 'Kelola Orders',
                        onTap: () => context.go('/admin/orders'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(AdminDashboardData d) {
    final cards = [
      (label: 'Total Vehicles', value: d.totalVehicles.toString(), icon: Icons.directions_car_rounded, color: YawColors.primary),
      (label: 'Total Orders', value: d.totalOrders.toString(), icon: Icons.receipt_long_rounded, color: YawColors.secondary),
      (label: 'Total Users', value: d.totalUsers.toString(), icon: Icons.people_rounded, color: YawColors.success),
      (label: 'Revenue', value: Formatters.compactIdr(d.totalRevenue), icon: Icons.payments_rounded, color: YawColors.warning),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards
          .map((c) => _StatCard(label: c.label, value: c.value, icon: c.icon, color: c.color))
          .toList(),
    );
  }

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static String _monthShort(String month) {
    if (month.length >= 7) {
      final mm = int.tryParse(month.substring(5, 7));
      if (mm != null && mm >= 1 && mm <= 12) return _monthNames[mm - 1];
    }
    return month;
  }

  Widget _buildSalesChart(AdminStatisticsData stats) {
    final monthly = stats.monthly;
    // Most recent 6 months (chronological oldest->newest).
    final recent = monthly.length > 6 ? monthly.sublist(monthly.length - 6) : monthly;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YawColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: YawColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Text(
              'SALES OVERVIEW',
              style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textMuted),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: YawColors.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: YawColors.border),
              ),
              child: Text(
                recent.isEmpty ? '' : '${recent.length} last months',
                style: const TextStyle(fontSize: 11, color: YawColors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recent.isEmpty)
          const AppEmptyView(
            title: 'Belum ada data penjualan',
            subtitle: 'Grafik muncul setelah ada transaksi.',
            icon: Icons.bar_chart_rounded,
          )
        else
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < recent.length; i++)
                  Expanded(
                    child: _buildBar(
                      value: recent[i].revenue,
                      max: _maxRevenue(recent),
                      label: _monthShort(recent[i].month),
                    ),
                  ),
              ],
            ),
          ),
      ]),
    );
  }

  static num _maxRevenue(List<MonthlyStat> list) {
    num m = 0;
    for (final e in list) {
      if (e.revenue > m) m = e.revenue;
    }
    return m == 0 ? 1 : m;
  }

  Widget _buildBar({required num value, required num max, required String label}) {
    final height = max == 0 ? 0.0 : (value / max) * 110;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [YawColors.primary, YawColors.primary.withValues(alpha: .4)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: YawColors.textDim)),
      ]),
    );
  }

  Widget _buildRecentOrders(AdminDashboardData d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YawColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: YawColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Text(
              'RECENT ORDERS',
              style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: YawColors.textMuted),
            ),
            const Spacer(),
            TextButton(onPressed: () => context.go('/admin/orders'), child: const Text('View all', style: TextStyle(color: YawColors.primary, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 8),
        if (d.recentOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Belum ada pesanan.', style: TextStyle(color: YawColors.textMuted)),
          )
        else
          ...d.recentOrders.map((o) => _recentRow(o)),
      ]),
    );
  }

  Widget _recentRow(Order o) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: YawColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: YawColors.border),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: YawColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: YawColors.border),
            ),
            child: const Icon(Icons.receipt_rounded, size: 16, color: YawColors.textMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.orderNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .4)),
              Text(o.userName ?? '-', style: const TextStyle(fontSize: 11, color: YawColors.textMuted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(Formatters.idr(o.total), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            _StatusChip(status: o.status),
          ]),
        ]),
      );
}

/// Simple holder pairing the dashboard + statistics calls so a single
/// `FutureBuilder` can drive the whole screen and pull-to-refresh reloads both.
class DashboardSnapshot {
  DashboardSnapshot({required this.dashboard, required this.statistics});
  final AdminDashboardData dashboard;
  final AdminStatisticsData statistics;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: YawColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: YawColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: .25)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 11, color: YawColors.textMuted)),
        ]),
      );
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: YawColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: YawColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: YawColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
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
      _ => YawColors.textDim,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: c),
      ),
    );
  }
}
