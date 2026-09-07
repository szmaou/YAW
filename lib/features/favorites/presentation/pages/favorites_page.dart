import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/network/mock_data.dart';
import '../../../../shared/widgets/vehicle_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider);
    final favVehicles = MockData.vehicles.where((v)=> fav.ids.contains(v.id)).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAVORITES'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border)),
      ),
      body: favVehicles.isEmpty
        ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite_border_rounded, size: 48, color: YawColors.textDim),
            const SizedBox(height:16),
            Text('Belum ada favorit', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height:8),
            const Text('Jelajahi kendaraan dan simpan yang kamu suka.', textAlign: TextAlign.center, style: TextStyle(color: YawColors.textMuted, fontSize:13)),
            const SizedBox(height:20),
            ElevatedButton(onPressed: ()=> context.go('/vehicles'), child: const Text('JELAJAHI KENDARAAN')),
          ])))
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isDesktop(context)?4 : Responsive.isTablet(context)?3:2,
              crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:.72),
            itemCount: favVehicles.length,
            itemBuilder: (_,i){
              final v = favVehicles[i];
              return VehicleCard(
                vehicle: v, isFavorite: true,
                onTap: ()=> context.push('/vehicles/${v.id}'),
                onFavorite: ()=> ref.read(favoritesProvider.notifier).toggle(v.id),
              );
            },
          ),
    );
  }
}
