import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/vehicle_card.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/vehicle_providers.dart';
import '../../data/vehicle_repository.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class VehicleListPage extends ConsumerStatefulWidget {
  const VehicleListPage({super.key});
  @override
  ConsumerState<VehicleListPage> createState() => _S();
}
class _S extends ConsumerState<VehicleListPage> {
  final _searchCtrl = TextEditingController();
  String? _brand, _fuel, _trans;
  double? _min, _max;
  String? _cat;
  bool _showFilter = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cat = GoRouterState.of(context).uri.queryParameters['cat'];
    if (cat != null && cat != _cat) {
      _cat = cat;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(vehicleListProvider.notifier).load(query: VehicleQuery(category: cat));
      });
    }
  }

  void _apply() {
    ref.read(vehicleListProvider.notifier).load(query: VehicleQuery(
      search: _searchCtrl.text.trim().isEmpty? null : _searchCtrl.text.trim(),
      brand: _brand, fuelType: _fuel, transmission: _trans, minPrice: _min, maxPrice: _max, category: _cat,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleListProvider);
    final favIds = ref.watch(favoritesProvider).ids;
    final cats = ref.watch(categoriesProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('VEHICLES'),
        actions: [
          IconButton(onPressed: ()=> setState(()=> _showFilter=!_showFilter), icon: Icon(_showFilter? Icons.close: Icons.tune_rounded)),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (_)=> _apply(),
            decoration: InputDecoration(
              hintText: 'Cari brand, model...',
              prefixIcon: const Icon(Icons.search_rounded, size:18),
              suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward_rounded, size:18), onPressed: _apply),
            ),
          ),
        ),
        if (_showFilter) Container(
          margin: const EdgeInsets.symmetric(horizontal:12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
          child: Column(children: [
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _cat, decoration: const InputDecoration(labelText: 'Kategori'), items: [const DropdownMenuItem(value:null, child: Text('Semua')), ...cats.map((c)=> DropdownMenuItem(value:c.slug, child: Text(c.name)))], onChanged: (v)=> setState(()=> _cat=v))),
              const SizedBox(width:8),
              Expanded(child: DropdownButtonFormField<String>(value: _brand, decoration: const InputDecoration(labelText: 'Brand'), items: const [DropdownMenuItem(value:null, child: Text('Semua')), DropdownMenuItem(value:'Toyota', child: Text('Toyota')), DropdownMenuItem(value:'Honda', child: Text('Honda')), DropdownMenuItem(value:'Hyundai', child: Text('Hyundai')), DropdownMenuItem(value:'Yamaha', child: Text('Yamaha')), DropdownMenuItem(value:'Tesla', child: Text('Tesla'))], onChanged: (v)=> setState(()=> _brand=v))),
            ]),
            const SizedBox(height:8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _fuel, decoration: const InputDecoration(labelText: 'Fuel'), items: const [DropdownMenuItem(value:null, child: Text('Semua')), DropdownMenuItem(value:'Petrol', child: Text('Petrol')), DropdownMenuItem(value:'Hybrid', child: Text('Hybrid')), DropdownMenuItem(value:'Electric', child: Text('Electric')), DropdownMenuItem(value:'Diesel', child: Text('Diesel'))], onChanged: (v)=> setState(()=> _fuel=v))),
              const SizedBox(width:8),
              Expanded(child: DropdownButtonFormField<String>(value: _trans, decoration: const InputDecoration(labelText: 'Transmisi'), items: const [DropdownMenuItem(value:null, child: Text('Semua')), DropdownMenuItem(value:'Automatic', child: Text('Automatic')), DropdownMenuItem(value:'Manual', child: Text('Manual')), DropdownMenuItem(value:'CVT', child: Text('CVT'))], onChanged: (v)=> setState(()=> _trans=v))),
            ]),
            const SizedBox(height:8),
            Row(children: [
              Expanded(child: TextField(decoration: const InputDecoration(labelText:'Min Price'), keyboardType: TextInputType.number, onChanged: (v)=> _min= double.tryParse(v))),
              const SizedBox(width:8),
              Expanded(child: TextField(decoration: const InputDecoration(labelText:'Max Price'), keyboardType: TextInputType.number, onChanged: (v)=> _max= double.tryParse(v))),
            ]),
            const SizedBox(height:10),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: (){ setState(()=> {_brand=null,_fuel=null,_trans=null,_min=null,_max=null,_cat=null}); _searchCtrl.clear(); _apply();}, child: const Text('RESET'))),
              const SizedBox(width:8),
              Expanded(child: ElevatedButton(onPressed: _apply, child: const Text('TERAPKAN'))),
            ]),
          ]),
        ),
        const SizedBox(height:8),
        Padding(padding: const EdgeInsets.symmetric(horizontal:12), child: Row(children: [
          Text('${state.total} kendaraan', style: const TextStyle(color: YawColors.textMuted, fontSize:12)),
          const Spacer(),
          if (state.isLoading) const SizedBox(width:16,height:16, child: CircularProgressIndicator(strokeWidth:2, color: YawColors.primary)),
        ])),
        const SizedBox(height:8),
        Expanded(child: Builder(builder: (_) {
          if (state.isLoading) return const AppLoadingView();
          if (state.error != null) return AppErrorView(message: state.error!, onRetry: ()=> ref.read(vehicleListProvider.notifier).load(refresh: true));
          if (state.data.isEmpty) return AppEmptyView(title: 'Tidak ada kendaraan', subtitle: 'Coba ubah filter atau kata kunci pencarian.', actionLabel: 'Reset Filter', onAction: _apply, icon: Icons.search_off_rounded);
          return RefreshIndicator(
            onRefresh: ()=> ref.read(vehicleListProvider.notifier).load(query: state.query, refresh: true),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.isDesktop(context)?4 : Responsive.isTablet(context)?3:2,
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72),
              itemCount: state.data.length + (state.hasMore?1:0),
              itemBuilder: (_,i){
                if (i>= state.data.length) {
                  // load more trigger
                  Future.microtask(()=> ref.read(vehicleListProvider.notifier).loadMore());
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: YawColors.primary)));
                }
                final v = state.data[i];
                final isFav = favIds.contains(v.id);
                return VehicleCard(vehicle: v, isFavorite: isFav, onTap: ()=> context.push('/vehicles/${v.id}'), onFavorite: ()=> ref.read(favoritesProvider.notifier).toggle(v.id));
              },
            ),
          );
        })),
      ]),
    );
  }
}
