import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/utils/formatters.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap, this.onFavorite, this.isFavorite=false, this.compact=false});
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: YawColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: YawColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: compact ? 1.35 : 1.6,
            child: Stack(children: [
              Positioned.fill(
                child: vehicle.primaryImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vehicle.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (_,__) => Container(color: YawColors.surface2),
                        errorWidget: (_,__,___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              Positioned(
                top: 10, right: 10,
                child: InkWell(
                  onTap: onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: YawColors.background.withValues(alpha: .75),
                      shape: BoxShape.circle,
                      border: Border.all(color: YawColors.border),
                    ),
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16, color: isFavorite ? YawColors.error : YawColors.textMuted),
                  ),
                ),
              ),
              if (vehicle.stock <= 0)
                Positioned(
                  left: 10, top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: YawColors.error, borderRadius: BorderRadius.circular(6)),
                    child: const Text('HABIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: .8)),
                  ),
                ),
              Positioned(
                left: 10, bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: YawColors.background.withValues(alpha: .85), borderRadius: BorderRadius.circular(20), border: Border.all(color: YawColors.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: vehicle.isAvailable? YawColors.success: YawColors.warning, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${vehicle.year} • ${vehicle.transmission ?? '-'} • ${vehicle.fuelType ?? '-'}',
                        style: const TextStyle(fontSize: 10, color: YawColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: .3)),
                  ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vehicle.brand.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: YawColors.primary)),
              const SizedBox(height: 2),
              Text(vehicle.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: YawColors.textPrimary)),
              const SizedBox(height: 6),
              Text(Formatters.idr(vehicle.price),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: YawColors.textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 12, color: YawColors.textDim),
                const SizedBox(width: 4),
                Text('Stok ${vehicle.stock}', style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
                const Spacer(),
                if (vehicle.color != null) Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: _colorFrom(vehicle.color!),
                    shape: BoxShape.circle, border: Border.all(color: YawColors.border),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: YawColors.surface2,
    child: const Center(child: Icon(Icons.directions_car_rounded, size: 40, color: YawColors.textDim)),
  );

  Color _colorFrom(String c) {
    final m = {'hitam':Colors.black,'putih':Colors.white,'silver':Colors.grey,'merah':Colors.red,'biru':Colors.blue,'abu':Colors.grey,'grey':Colors.grey,'black':Colors.black,'white':Colors.white,'red':Colors.red,'blue':Colors.blue};
    return m[c.toLowerCase()] ?? YawColors.textDim;
  }
}
