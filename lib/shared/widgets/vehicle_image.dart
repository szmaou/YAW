import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';

/// Gambar kendaraan yang tahan gagal sesaat (flaky network / backend restart).
///
/// - URL relatif backend (/uploads/...) otomatis dijadikan absolut.
/// - Saat unduh gagal (bukan URL kosong), tampil ikon + tombol retry
///   ketuk-untuk-coba-lagi, bukan placeholder mati.
/// - Dipakai di: kartu kendaraan (vehicles + home), hero home,
///   kelola kendaraan (admin), dan halaman detail kendaraan.
class VehicleImage extends StatefulWidget {
  const VehicleImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
    this.retryIconSize = 20,
  });
  final String imageUrl;
  final BoxFit fit;
  final double iconSize;
  final double retryIconSize;

  @override
  State<VehicleImage> createState() => _VehicleImageState();
}

class _VehicleImageState extends State<VehicleImage> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.resolveImageUrl(widget.imageUrl);
    if (url.isEmpty) return _fallback(context, canRetry: false);
    return CachedNetworkImage(
      // Key berubah tiap retry agar unduhan diulang (cache sukses tetap dipakai).
      key: ValueKey('$_attempt:$url'),
      imageUrl: url,
      fit: widget.fit,
      placeholder: (_, __) => Container(color: YawColors.surface2),
      errorWidget: (_, __, ___) => _fallback(context, canRetry: true),
    );
  }

  Widget _fallback(BuildContext context, {required bool canRetry}) {
    return Container(
      color: YawColors.surface2,
      child: Center(
        child: canRetry
            ? IconButton(
                tooltip: 'Muat ulang gambar',
                icon: Icon(Icons.refresh_rounded, size: widget.retryIconSize, color: YawColors.textDim),
                onPressed: () => setState(() => _attempt++),
              )
            : Icon(Icons.directions_car_rounded, size: widget.iconSize, color: YawColors.textDim),
      ),
    );
  }
}
