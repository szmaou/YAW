import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/vehicle_card.dart';
import '../../../vehicles/presentation/providers/vehicle_providers.dart';
import '../../../vehicles/data/vehicle_repository.dart';
import '../../../../core/network/mock_data.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);
    final veh = ref.watch(vehicleListProvider);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, expandedHeight: 0, toolbarHeight: 56,
          title: Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: YawColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('Y', style: TextStyle(fontWeight: FontWeight.w900, color: YawColors.background)))),
            const SizedBox(width: 8),
            const Text('YAW', style: TextStyle(letterSpacing: 4, fontSize: 16)),
            const Spacer(),
            IconButton(onPressed: ()=> context.push('/vehicles'), icon: const Icon(Icons.search_rounded)),
            IconButton(onPressed: ()=> context.push('/profile'), icon: const Icon(Icons.person_outline)),
          ]),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1, color: YawColors.border)),
        ),
        SliverToBoxAdapter(child: _Hero(onExplore: ()=> context.go('/vehicles'))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(children: [
            const Text('KATEGORI POPULER', style: TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
            const Spacer(),
            TextButton(onPressed: ()=> context.go('/vehicles'), child: const Text('Lihat semua', style: TextStyle(color: YawColors.primary, fontSize: 12))),
          ]),
        )),
        SliverToBoxAdapter(child: SizedBox(height: 96, child: catsAsync.when(
          loading: ()=> ListView.separated(padding: const EdgeInsets.symmetric(horizontal:16), scrollDirection: Axis.horizontal, itemBuilder: (_,__)=> Container(width:120, decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12))), separatorBuilder: (_,__)=> const SizedBox(width:10), itemCount: 6),
          error: (e,_)=> AppErrorView(message: e.toString()),
          data: (cats)=> ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal:16), scrollDirection: Axis.horizontal,
            itemCount: cats.length, separatorBuilder: (_,__)=> const SizedBox(width:10),
            itemBuilder: (_,i){
              final c = cats[i];
              return InkWell(
                onTap: ()=> context.go('/vehicles?cat=${c.slug}'),
                borderRadius: BorderRadius.circular(14),
                child: Container(width: 120, decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)),
                      child: Icon(switch(c.slug){'suv'=> Icons.directions_car_rounded,'sedan'=> Icons.directions_car_filled,'ev'=> Icons.bolt_rounded,'motorcycle'=> Icons.two_wheeler_rounded, _=> Icons.category_rounded}, color: YawColors.primary, size: 18)),
                    const SizedBox(height:8),
                    Text(c.name, style: const TextStyle(fontSize:12, fontWeight: FontWeight.w700)),
                    Text(c.slug.toUpperCase(), style: const TextStyle(fontSize:9, letterSpacing:1, color: YawColors.textDim)),
                  ])),
              );
            }),
        ))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(children: [
            const Text('KENDARAAN UNGGULAN', style: TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
            const Spacer(),
            TextButton(onPressed: ()=> context.go('/vehicles'), child: const Text('Lihat semua', style: TextStyle(color:YawColors.primary, fontSize:12))),
          ]),
        )),
        if (veh.isLoading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: YawColors.primary))))
        else if (veh.error != null) SliverToBoxAdapter(child: AppErrorView(message: veh.error!, onRetry: ()=> ref.read(vehicleListProvider.notifier).load(refresh:true)))
        else SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((_,i){
              final v = veh.data[i];
              return VehicleCard(vehicle: v, onTap: ()=> context.push('/vehicles/${v.id}'), onFavorite: (){}, isFavorite: false);
            }, childCount: veh.data.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isDesktop(context)? 4 : Responsive.isTablet(context)? 3 : 2,
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .72),
          ),
        ),
        SliverToBoxAdapter(child: _WhySection()),
        SliverToBoxAdapter(child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [YawColors.primary.withValues(alpha:.18), YawColors.secondary.withValues(alpha:.18)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: YawColors.border)),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Siap menemukan kendaraan masa depan?', style: TextStyle(fontWeight: FontWeight.w800, fontSize:15)),
              SizedBox(height:6), Text('Jelajahi katalog lengkap dan pesan langsung dari aplikasi.', style: TextStyle(color:YawColors.textMuted, fontSize:12)),
            ])),
            const SizedBox(width:16),
            ElevatedButton(onPressed: ()=> GoRouter.of(context).go('/vehicles'), child: const Text('EXPLORE')),
          ]))),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(center: Alignment.topRight, radius: 1.4, colors: [YawColors.secondary.withValues(alpha:.18), Colors.transparent], stops: const [.0,.6]),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.all(isMobile?20:32),
        decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: YawColors.border)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: YawColors.primary.withValues(alpha:.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: YawColors.primary.withValues(alpha:.25))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bolt_rounded, size:12, color: YawColors.primary), SizedBox(width:4), Text('FUTURISTIC AUTOMOTIVE', style: TextStyle(fontSize:9, letterSpacing:1.2, fontWeight: FontWeight.w700, color: YawColors.primary))])),
            const SizedBox(height:14),
            Text('THE FUTURE\nOF MOBILITY', style: Theme.of(context).textTheme.displayMedium?.copyWith(height:.95, fontWeight: FontWeight.w900, fontSize: isMobile?28:40)),
            const SizedBox(height:10),
            const Text('Discover vehicles built for tomorrow.\nKurasi mobil, EV, dan motor premium dalam satu tempat.', style: TextStyle(color: YawColors.textMuted, fontSize:12, height:1.5)),
            const SizedBox(height:18),
            Wrap(spacing:10, runSpacing:10, children: [
              ElevatedButton.icon(onPressed: onExplore, icon: const Icon(Icons.explore_rounded, size:18), label: const Text('EXPLORE VEHICLES')),
              OutlinedButton(onPressed: onExplore, child: const Text('LIHAT KATALOG')),
            ]),
            const SizedBox(height:14),
            const Wrap(spacing:16, children: [
              _Stat(v:'120+', l:'Vehicles'), _Stat(v:'6', l:'Categories'), _Stat(v:'24/7', l:'Support'),
            ])
          ])),
          if (!isMobile) ...[
            const SizedBox(width:24),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16),
              child: AspectRatio(aspectRatio: 1.4, child: Image.network(MockData.vehicles.first.primaryImage, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: YawColors.surface2, child: const Icon(Icons.directions_car_rounded, size:48, color: YawColors.textDim))))),
            ),
          ]
        ]),
      ),
    );
  }
}
class _Stat extends StatelessWidget { const _Stat({required this.v, required this.l}); final String v,l; @override Widget build(BuildContext context)=> Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(v, style: const TextStyle(fontWeight: FontWeight.w800, color: YawColors.primary)), Text(l, style: const TextStyle(fontSize:10, color: YawColors.textDim))]); }

class _WhySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_rounded,'Kurasi Premium','Setiap kendaraan terverifikasi dan siap kirim.'),
      (Icons.speed_rounded,'Proses Cepat','Pesan online, konfirmasi admin, dan pengiriman terjadwal.'),
      (Icons.support_agent_rounded,'Support Responsif','Tim YAW siap bantu via chat & telepon.'),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('KENAPA YAW?', style: TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
      const SizedBox(height:12),
      LayoutBuilder(builder: (_,c){
        final cols = c.maxWidth > 700 ? 3 : 1;
        return GridView.builder(shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio: cols==1? 4.2 : 2.2), itemCount: items.length, itemBuilder: (_,i){
          final it = items[i];
          return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Row(children: [
              Container(width:40,height:40,decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)), child: Icon(it.$1, color: YawColors.primary, size:20)),
              const SizedBox(width:12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize:13)), const SizedBox(height:4), Text(it.$3, style: const TextStyle(color: YawColors.textMuted, fontSize:11, height:1.4))])),
            ]));
        });
      }),
    ]));
  }
}
