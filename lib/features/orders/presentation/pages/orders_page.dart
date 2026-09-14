import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../orders/data/order_repository.dart';
import '../../../../../shared/models/order.dart';
import '../../../../../shared/models/vehicle.dart';

final ordersListProvider = FutureProvider<Paginated<Order>>((ref) async {
  return ref.watch(orderRepositoryProvider).getOrders();
});

final orderDetailProvider = FutureProvider.family<Order, String>((ref, id) async {
  return ref.watch(orderRepositoryProvider).getOrder(id);
});

String _vehicleLabel(Order o) {
  if (o.items.isEmpty) return '-';
  return o.items.map((e) => '${e.vehicle.name} x${e.quantity}').join(', ');
}

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ordersListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ORDERS'), bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border))),
      body: async.when(
        loading: () => const AppLoadingView(),
        error: (e, _) => AppErrorView(message: e.toString(), onRetry: () => ref.invalidate(ordersListProvider)),
        data: (page) {
          final orders = page.data;
          if (orders.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.receipt_long_outlined, size:48, color: YawColors.textDim),
              const SizedBox(height:16),
              Text('Belum ada pesanan', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height:8),
              const Text('Kendaraan impianmu masih menunggu.\nMulai pesan sekarang.', textAlign: TextAlign.center, style: TextStyle(color: YawColors.textMuted, fontSize:13, height:1.5)),
              const SizedBox(height:20),
              ElevatedButton(onPressed: ()=> context.go('/vehicles'), child: const Text('JELAJAHI KENDARAAN')),
            ])));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height:10),
              itemBuilder: (_,i){
                final o = orders[i];
                return InkWell(
                  onTap: ()=> context.push('/orders/${o.id}'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize:13, letterSpacing:.5))),
                        _StatusChip(status: o.status),
                      ]),
                      const SizedBox(height:8),
                      Text(_vehicleLabel(o), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize:13, color: YawColors.textMuted)),
                      const SizedBox(height:8),
                      Row(children: [
                        Text(Formatters.idr(o.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text(o.createdAt != null ? Formatters.date(o.createdAt!) : '-', style: const TextStyle(fontSize:11, color: YawColors.textDim)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('DETAIL PESANAN'), bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border))),
      body: async.when(
        loading: () => const AppLoadingView(),
        error: (e, _) => AppErrorView(message: e.toString(), onRetry: () => ref.invalidate(orderDetailProvider(id))),
        data: (o) => SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children:[ const Text('Status', style: TextStyle(color: YawColors.textMuted, fontSize:12)), const Spacer(), _StatusChip(status: o.status)]),
              const Divider(height:24),
              _Row(label:'No. Pesanan', value:o.orderNumber),
              _Row(label:'Tanggal', value: o.createdAt != null ? Formatters.dateTime(o.createdAt!) : '-'),
              _Row(label:'Kendaraan', value: _vehicleLabel(o)),
              _Row(label:'Total', value: Formatters.idr(o.total), bold:true),
            ])),
          const SizedBox(height:14),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ALUR PESANAN', style: TextStyle(fontSize:10, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
              const SizedBox(height:12),
              ...['Pesanan dibuat','Menunggu konfirmasi admin','Diproses','Selesai'].map((s)=> Padding(
                padding: const EdgeInsets.symmetric(vertical:5),
                child: Row(children:[
                  Container(width:8,height:8,decoration: const BoxDecoration(color: YawColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width:10),
                  Text(s, style: const TextStyle(fontSize:13)),
                ]),
              )),
            ])),
        ])),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final c = switch(status){'pending'=> YawColors.warning,'confirmed'=> YawColors.primary,'processing'=> YawColors.secondary,'completed'=> YawColors.success,'cancelled'=> YawColors.error, _=> YawColors.textMuted};
    return Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: c.withValues(alpha:.14), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha:.3))), child: Text(status.toUpperCase(), style: TextStyle(fontSize:10, fontWeight: FontWeight.w800, letterSpacing:.6, color: c)));
  }
}
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold=false});
  final String label,value; final bool bold;
  @override Widget build(BuildContext context)=> Padding(padding: const EdgeInsets.symmetric(vertical:4), child: Row(children:[ SizedBox(width:110, child: Text(label, style: const TextStyle(fontSize:12, color: YawColors.textMuted))), Expanded(child: Text(value, style: TextStyle(fontSize:13, fontWeight: bold? FontWeight.w800: FontWeight.w500)))]));
}
