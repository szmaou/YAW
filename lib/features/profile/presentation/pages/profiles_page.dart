import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/responsive.dart';

/// Data developer diambil dari docs/profiles/*.md.
class _Developer {
  const _Developer({required this.name, required this.image, required this.desc, this.link});
  final String name;
  final String image;
  final String desc;
  final String? link;
}

const _developers = <_Developer>[
  _Developer(
    name: 'Hasan',
    image: 'assets/images/profiles/hasan.png',
    desc:
        'Seorang Linux enthusiast, yang suka mengeksplorasi serta mengkonfigurasi operating system dan software open-source. '
        'Selain di dunia software, saya juga memiliki ketertarikan pada sisi hardware, mulai dari perakitan PC hingga bereksperimen '
        'dengan berbagai Project Microcontroller.',
    link: 'https://hasan.cnp.my.id/',
  ),
  _Developer(
    name: 'Fedly Pratama',
    image: 'assets/images/profiles/fedly.jpeg',
    desc:
        'Saya adalah seorang pelajar yang tertarik dengan dunia teknologi dan pemrograman. '
        'Saya senang mempelajari hal-hal baru, membuat website, serta mengembangkan kemampuan dalam bidang teknologi informasi.',
  ),
  _Developer(
    name: 'Ilham Makhrus Salam',
    image: 'assets/images/profiles/ilham.jpeg',
    desc:
        'Profesional IT dengan keahlian kuat dalam pengembangan dan manajemen perangkat lunak. '
        'Terampil dalam menggunakan berbagai tools programming dan framework modern untuk menciptakan solusi digital '
        'yang efisien, skalabel, dan user-friendly',
  ),
  _Developer(
    name: 'Farida Amelia Sholiha',
    image: 'assets/images/profiles/farida.jpeg',
    desc:
        'Saya adalah Farida Amelia Sholiha, siswi kelas XII PPLG 1 yang memiliki minat dalam bidang teknologi dan pemrograman. '
        'Saya senang mempelajari hal-hal baru. Saya juga terus berusaha mengembangkan kemampuan dan kreativitas untuk menjadi lebih baik lagi. '
        'Di luar teknologi saya juga memiliki hobi beternak dan senang merawat hewan. '
        'Bagi saya kegiatan tersebut mengajarkan tanggung jawab, kesabaran, dan ketekunan.',
  ),
  _Developer(
    name: 'Shinta Ramadhani',
    image: 'assets/images/profiles/shinta.jpeg',
    desc:
        'Saya adalah seorang yang memiliki kepribadian pendiam dan lebih suka mengamati daripada banyak berbicara. '
        'Saya cenderung membutuhkan waktu untuk memahami sesuatu dan lebih nyaman dengan penjelasan yang jelas. '
        'Saya juga memiliki ketertarikan pada teknologi dan pemrograman serta senang mencoba hal-hal yang menurut saya menarik.',
    link: 'https://cv.cnp.my.id/src/shinta/index.php',
  ),
];

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tablet + desktop memakai grid; mobile tetap list satu kolom.
    final isGrid = !Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIM PENGEMBANG'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: YawColors.border),
        ),
      ),
      // Batas lebar supaya di layar ultrawide gridnya tidak kebanyakan kolom.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              sliver: const SliverToBoxAdapter(child: _IntroHeader()),
            ),
            if (isGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  // Basis ukuran kartu ~360px; jumlah kolom menyesuaikan lebar.
                  // Tinggi sel tetap (extent) supaya kartu seragam & tidak ada yang terpotong.
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: Responsive.isDesktop(context) ? 620 : 580,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DeveloperCard(dev: _developers[i], compact: true),
                    childCount: _developers.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: _developers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _DeveloperCard(dev: _developers[i]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Intro header
// ---------------------------------------------------------------------------

class _IntroHeader extends StatelessWidget {
  const _IntroHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YawColors.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: YawColors.primary.withValues(alpha: .25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.rocket_launch_rounded, size: 22, color: YawColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tim pengembang di balik YAW — para siswa dan praktisi '
              'yang merancang, membangun, dan merawat marketplace kendaraan ini.',
              style: TextStyle(fontSize: 13, color: YawColors.textMuted, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Developer card — vertical layout: photo on top, info below
// ---------------------------------------------------------------------------

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.dev, this.compact = false});
  final _Developer dev;

  /// Mode grid: deskripsi dibatasi 8 baris (dipotong dengan '…') supaya
  /// tinggi kartu seragam dan tidak meluber dari sel grid.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: YawColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: YawColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Photo ──────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 4 / 3,
            child: _Photo(name: dev.name, image: dev.image),
          ),
          // ── Info ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  dev.desc,
                  style: const TextStyle(fontSize: 13, color: YawColors.textMuted, height: 1.55),
                  maxLines: compact ? 8 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
                if (dev.link != null) ...[
                  const SizedBox(height: 14),
                  _LinkChip(link: dev.link!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo — full-width, fallback to initial letter on error
// ---------------------------------------------------------------------------

class _Photo extends StatelessWidget {
  const _Photo({required this.name, required this.image});
  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ColoredBox(
      color: YawColors.surface2,
      child: Image.asset(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: YawColors.primary.withValues(alpha: .12),
                  border: Border.all(color: YawColors.primary.withValues(alpha: .35)),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: YawColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link chip — buka di browser eksternal via url_launcher;
// kalau gagal (mis. xdg-open tidak ada di Linux) fallback ke salin link.
// ---------------------------------------------------------------------------

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.link});
  final String link;

  Future<void> _open(BuildContext context) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (opened) return;
    // Fallback: salin link ke clipboard supaya tetap bisa dibuka manual.
    Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Link disalin — buka di browser kamu.')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: YawColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: YawColors.primary.withValues(alpha: .3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_rounded, size: 14, color: YawColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Lihat Selengkapnya',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: YawColors.primary.withValues(alpha: .9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(link, style: const TextStyle(fontSize: 11, color: YawColors.textDim)),
      ],
    );
  }
}