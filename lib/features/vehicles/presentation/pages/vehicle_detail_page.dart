import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/yaw_button.dart';
import '../providers/vehicle_providers.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class VehicleDetailPage extends ConsumerStatefulWidget {
  const VehicleDetailPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<VehicleDetailPage> createState() => _S();
}
class _S extends ConsumerState<VehicleDetailPage> {
  int _imgIdx = 0;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vehicleDetailProvider(widget.id));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: ()=> context.pop()),
        title: const Text('DETAIL KENDARAAN'),
        actions: [
          Consumer(builder: (_,ref,__) {
            final isFav = ref.watch(favoritesProvider).isFav(widget.id);
            return IconButton(
              icon: Icon(isFav? Icons.favorite: Icons.favorite_border, color: isFav? YawColors.error: null),
              onPressed: ()=> ref.read(favoritesProvider.notifier).toggle(widget.id),
            );
          }),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border)),
      ),
      body: async.when(
        loading: ()=> const AppLoadingView(),
        error: (e,_)=> AppErrorView(message: e.toString(), onRetry: ()=> ref.invalidate(vehicleDetailProvider(widget.id))),
        data: (v){
          final images = v.images.isEmpty ? [''] : v.images;
          final isDesktop = Responsive.isDesktop(context);
          Widget gallery = Column(children: [
            AspectRatio(
              aspectRatio: isDesktop? 1.6 : 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(children: [
                  Positioned.fill(
                    child: images[_imgIdx].isNotEmpty
                      ? CachedNetworkImage(imageUrl: images[_imgIdx], fit: BoxFit.cover,
                          placeholder: (_,__)=> Container(color: YawColors.surface2),
                          errorWidget: (_,__,___)=> Container(color: YawColors.surface2, child: const Icon(Icons.directions_car_rounded, size:48, color: YawColors.textDim)))
                      : Container(color: YawColors.surface2, child: const Icon(Icons.directions_car_rounded, size:48, color: YawColors.textDim)),
                  ),
                  if (images.length>1) Positioned(
                    bottom: 12, left: 0, right: 0,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(images.length, (i)=> Container(
                      width: i==_imgIdx? 20:8, height: 8, margin: const EdgeInsets.symmetric(horizontal:3),
                      decoration: BoxDecoration(color: i==_imgIdx? YawColors.primary: Colors.white54, borderRadius: BorderRadius.circular(20)),
                    ))),
                  ),
                  Positioned(left: 8, top: 0, bottom: 0, child: Center(child: _NavBtn(icon: Icons.chevron_left_rounded, onTap: ()=> setState(()=> _imgIdx = (_imgIdx-1+images.length)%images.length)))),
                  Positioned(right: 8, top: 0, bottom: 0, child: Center(child: _NavBtn(icon: Icons.chevron_right_rounded, onTap: ()=> setState(()=> _imgIdx = (_imgIdx+1)%images.length)))),
                ]),
              ),
            ),
            if (images.length>1) SizedBox(height: 72, child: ListView.separated(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(top:10),
              itemCount: images.length, separatorBuilder: (_,__)=> const SizedBox(width:8),
              itemBuilder: (_,i)=> InkWell(
                onTap: ()=> setState(()=> _imgIdx=i),
                child: Container(
                  width: 72, decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: i==_imgIdx? YawColors.primary: YawColors.border, width: i==_imgIdx?2:1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: images[i].isNotEmpty
                    ? CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover, errorWidget: (_,__,___)=> Container(color: YawColors.surface2))
                    : Container(color: YawColors.surface2),
                ),
              ),
            )),
          ]);

          Widget specs = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SPESIFIKASI', style: TextStyle(fontSize:10, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
              const SizedBox(height:12),
              _SpecRow(icon: Icons.settings_outlined, label:'Mesin', value: v.engine ?? '-'),
              _SpecRow(icon: Icons.sync_alt_rounded, label:'Transmisi', value: v.transmission ?? '-'),
              _SpecRow(icon: Icons.local_gas_station_outlined, label:'Bahan Bakar', value: v.fuelType ?? '-'),
              _SpecRow(icon: Icons.calendar_today_outlined, label:'Tahun', value: '${v.year}'),
              _SpecRow(icon: Icons.palette_outlined, label:'Warna', value: v.color ?? '-'),
              _SpecRow(icon: Icons.inventory_2_outlined, label:'Stok', value: '${v.stock} unit'),
              _SpecRow(icon: Icons.category_outlined, label:'Kategori', value: v.category?.name ?? '-'),
            ]),
          );

          Widget buyCard = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: YawColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(Formatters.idr(v.price), style: const TextStyle(fontSize:22, fontWeight: FontWeight.w900)),
              const SizedBox(height:4),
              Row(children: [
                Container(width:8,height:8,decoration: BoxDecoration(color: v.isAvailable? YawColors.success: YawColors.error, shape: BoxShape.circle)),
                const SizedBox(width:6),
                Text(v.isAvailable? 'Tersedia': 'Tidak tersedia', style: TextStyle(fontSize:12, color: v.isAvailable? YawColors.success: YawColors.error, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('Stok ${v.stock}', style: const TextStyle(fontSize:12, color: YawColors.textMuted)),
              ]),
              const SizedBox(height:14),
              if (v.stock>0) Row(children: [
                Container(decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.remove_rounded, size:18), onPressed: _qty>1? ()=> setState(()=> _qty--): null),
                    Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(icon: const Icon(Icons.add_rounded, size:18), onPressed: _qty < v.stock ? ()=> setState(()=> _qty++): null),
                  ])),
                const SizedBox(width:12),
                Expanded(child: YawButton(label:'PESAN SEKARANG', icon: Icons.shopping_bag_outlined, onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Pesanan ${v.name} x$_qty ditambahkan. Total ${Formatters.idr(v.price*_qty)}'),
                    backgroundColor: YawColors.surface2,
                  ));
                  context.push('/orders');
                })),
              ]) else const Text('Stok habis — hubungi admin untuk pre-order.', style: TextStyle(color: YawColors.warning, fontSize:12)),
              const SizedBox(height:10),
              OutlinedButton.icon(onPressed: ()=> ref.read(favoritesProvider.notifier).toggle(v.id), icon: const Icon(Icons.favorite_border, size:16), label: const Text('SIMPAN KE FAVORIT')),
            ]),
          );

          if (isDesktop) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 5, child: gallery),
                  const SizedBox(width:20),
                  Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.brand.toUpperCase(), style: const TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.primary)),
                    const SizedBox(height:6),
                    Text(v.name, style: const TextStyle(fontSize:26, fontWeight: FontWeight.w900, height:1.1)),
                    const SizedBox(height:6),
                    Text(v.model, style: const TextStyle(color: YawColors.textMuted)),
                    const SizedBox(height:16),
                    buyCard,
                    const SizedBox(height:16),
                    specs,
                  ])),
                ]),
                const SizedBox(height:20),
                const Text('DESKRIPSI', style: TextStyle(fontSize:10, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
                const SizedBox(height:8),
                Text(v.description ?? '-', style: const TextStyle(color: YawColors.textMuted, height:1.6, fontSize:13)),
              ]),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              gallery,
              const SizedBox(height:16),
              Text(v.brand.toUpperCase(), style: const TextStyle(fontSize:11, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.primary)),
              const SizedBox(height:4),
              Text(v.name, style: const TextStyle(fontSize:22, fontWeight: FontWeight.w900)),
              Text(v.model, style: const TextStyle(color: YawColors.textMuted, fontSize:13)),
              const SizedBox(height:16),
              buyCard,
              const SizedBox(height:16),
              specs,
              const SizedBox(height:16),
              const Text('DESKRIPSI', style: TextStyle(fontSize:10, letterSpacing:1.4, fontWeight: FontWeight.w700, color: YawColors.textMuted)),
              const SizedBox(height:8),
              Text(v.description ?? '-', style: const TextStyle(color: YawColors.textMuted, height:1.6, fontSize:13)),
              const SizedBox(height:24),
            ]),
          );
        },
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon; final VoidCallback onTap;
  @override Widget build(BuildContext context)=> InkWell(
    onTap: onTap,
    child: Container(width:36,height:36, decoration: BoxDecoration(color: YawColors.background.withValues(alpha:.75), shape: BoxShape.circle, border: Border.all(color: YawColors.border)), child: Icon(icon, color: YawColors.textPrimary)),
  );
}
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.icon, required this.label, required this.value});
  final IconData icon; final String label; final String value;
  @override Widget build(BuildContext context)=> Padding(
    padding: const EdgeInsets.symmetric(vertical:7),
    child: Row(children: [
      Container(width:32,height:32, decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: YawColors.border)), child: Icon(icon, size:16, color: YawColors.textMuted)),
      const SizedBox(width:10),
      SizedBox(width:90, child: Text(label, style: const TextStyle(fontSize:12, color: YawColors.textMuted))),
      Expanded(child: Text(value, style: const TextStyle(fontSize:13, fontWeight: FontWeight.w600))),
    ]),
  );
}
