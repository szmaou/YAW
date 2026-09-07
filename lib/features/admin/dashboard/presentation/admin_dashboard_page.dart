import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: ()=> context.go('/home')),
        actions: [
          IconButton(onPressed: ()=> context.go('/profile'), icon: const Icon(Icons.person_outline)),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
            children: const [
              _StatCard(label:'Total Vehicles', value:'128', icon: Icons.directions_car_rounded, color: YawColors.primary),
              _StatCard(label:'Total Orders', value:'342', icon: Icons.receipt_long_rounded, color: YawColors.secondary),
              _StatCard(label:'Total Users', value:'1,204', icon: Icons.people_rounded, color: YawColors.success),
              _StatCard(label:'Revenue', value:'Rp 4.2 M', icon: Icons.payments_rounded, color: YawColors.warning),
            ],
          ),
          const SizedBox(height:16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('SALES OVERVIEW', style: TextStyle(fontSize:11, letterSpacing:1.2, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: YawColors.border)),
                  child: const Text('Last 6 months', style: TextStyle(fontSize:11, color: YawColors.textMuted))),
              ]),
              const SizedBox(height:16),
              SizedBox(height: 120, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final h in [40, 65, 45, 90, 70, 110])
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal:4), child: Column(children:[
                    Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(
                      height: h.toDouble(), decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [YawColors.primary, YawColors.primary.withValues(alpha:.4)]),
                        borderRadius: BorderRadius.circular(8)),
                    ))),
                    const SizedBox(height:6),
                    Text(['Jan','Feb','Mar','Apr','Mei','Jun'][ [40,65,45,90,70,110].indexOf(h) ], style: const TextStyle(fontSize:10, color: YawColors.textDim)),
                  ]))),
              ])),
            ]),
          ),
          const SizedBox(height:16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('RECENT ORDERS', style: TextStyle(fontSize:11, letterSpacing:1.2, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
                const Spacer(),
                TextButton(onPressed: ()=> context.go('/admin/orders'), child: const Text('View all', style: TextStyle(color: YawColors.primary, fontSize:12))),
              ]),
              const SizedBox(height:8),
              ...List.generate(4, (i)=> Container(
                margin: const EdgeInsets.only(bottom:8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)),
                child: Row(children: [
                  Container(width:36,height:36, decoration: BoxDecoration(color: YawColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: YawColors.border)),
                    child: const Icon(Icons.receipt_rounded, size:16, color: YawColors.textMuted)),
                  const SizedBox(width:10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Text('YAW-2025090${i+1}-00${i+1}', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w700)),
                    Text(['Toyota GR Supra','Honda CR-V','Hyundai IONIQ 6','Yamaha XMAX'][i], style: const TextStyle(fontSize:11, color: YawColors.textMuted)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
                    Text(Formatters.idr([1200000000,750000000,1250000000,65000000][i]), style: const TextStyle(fontSize:11, fontWeight: FontWeight.w700)),
                    const SizedBox(height:2),
                    Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: [YawColors.warning,YawColors.success,YawColors.primary,YawColors.textDim][i].withValues(alpha:.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(['pending','completed','processing','pending'][i].toUpperCase(), style: TextStyle(fontSize:9, fontWeight: FontWeight.w800, color: [YawColors.warning,YawColors.success,YawColors.primary,YawColors.textDim][i]))),
                  ]),
                ]),
              )),
            ]),
          ),
          const SizedBox(height:16),
            // Use `go` (not `push`) — admin is outside ShellRoute, push would duplicate shell page.
            Wrap(spacing:10, runSpacing:10, children: [
              _AdminAction(icon: Icons.directions_car_rounded, label:'Kelola Kendaraan', onTap: ()=> context.go('/admin/vehicles')),
              _AdminAction(icon: Icons.category_rounded, label:'Kelola Kategori', onTap: ()=> context.go('/admin/categories')),
              _AdminAction(icon: Icons.people_rounded, label:'Kelola Users', onTap: ()=> context.go('/admin/users')),
              _AdminAction(icon: Icons.receipt_long_rounded, label:'Kelola Orders', onTap: ()=> context.go('/admin/orders')),
            ]),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label,value; final IconData icon; final Color color;
  @override Widget build(BuildContext context)=> Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Container(width:36,height:36, decoration: BoxDecoration(color: color.withValues(alpha:.14), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha:.25))), child: Icon(icon, color: color, size:18)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize:18, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(fontSize:11, color: YawColors.textMuted)),
    ]),
  );
}
class _AdminAction extends StatelessWidget {
  const _AdminAction({required this.icon, required this.label, required this.onTap});
  final IconData icon; final String label; final VoidCallback onTap;
  @override Widget build(BuildContext context)=> InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Container(padding: const EdgeInsets.symmetric(horizontal:14, vertical:12), decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children:[ Icon(icon, size:16, color: YawColors.primary), const SizedBox(width:8), Text(label, style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600))])));
}
