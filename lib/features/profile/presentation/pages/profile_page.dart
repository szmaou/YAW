import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final u = auth.user;

    if (u == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PROFILE'), bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border))),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[
          const Icon(Icons.person_outline, size:48, color: YawColors.textDim),
          const SizedBox(height:12),
          const Text('Belum login'),
          const SizedBox(height:12),
          ElevatedButton(onPressed: ()=> context.go('/login'), child: const Text('MASUK')),
        ])),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE'), bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height:1,color:YawColors.border))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: YawColors.border)),
            child: Row(children: [
              Container(width:56,height:56, decoration: BoxDecoration(color: YawColors.primary.withValues(alpha:.15), shape: BoxShape.circle, border: Border.all(color: YawColors.primary.withValues(alpha:.3))),
                child: Center(child: Text(u.name.isNotEmpty? u.name[0].toUpperCase(): '?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize:22, color: YawColors.primary)))),
              const SizedBox(width:14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize:15)),
                Text(u.email, style: const TextStyle(color: YawColors.textMuted, fontSize:12)),
                const SizedBox(height:6),
                Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:3), decoration: BoxDecoration(color: u.isAdmin? YawColors.secondary.withValues(alpha:.15): YawColors.primary.withValues(alpha:.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: u.isAdmin? YawColors.secondary.withValues(alpha:.3): YawColors.primary.withValues(alpha:.25))),
                  child: Text(u.role.toUpperCase(), style: TextStyle(fontSize:10, fontWeight: FontWeight.w800, letterSpacing:.6, color: u.isAdmin? YawColors.secondary: YawColors.primary))),
              ])),
            ]),
          ),
          const SizedBox(height:14),
          _Tile(icon: Icons.edit_outlined, label: 'Edit Profil', onTap: ()=> _showEdit(context, ref)),
          _Tile(icon: Icons.receipt_long_outlined, label: 'Pesanan Saya', onTap: ()=> context.push('/orders')),
          _Tile(icon: Icons.favorite_border, label: 'Favorit', onTap: ()=> context.push('/favorites')),
          _Tile(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: (){}),
          const SizedBox(height:14),
          OutlinedButton.icon(onPressed: () async { await ref.read(authProvider.notifier).logout(); if(context.mounted) context.go('/login'); }, icon: const Icon(Icons.logout_rounded, size:18), label: const Text('KELUAR'), style: OutlinedButton.styleFrom(foregroundColor: YawColors.error, side: const BorderSide(color: YawColors.error))),
          const SizedBox(height:12),
          const Center(child: Text('YAW v1.0.0 • Futuristic Automotive', style: TextStyle(fontSize:11, color: YawColors.textDim))),
        ]),
      ),
    );
  }

  void _showEdit(BuildContext c, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: ref.read(authProvider).user?.name ?? '');
    final phoneCtrl = TextEditingController(text: ref.read(authProvider).user?.phone ?? '');
    showModalBottomSheet(context: c, isScrollControlled: true, backgroundColor: YawColors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_)=> Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left:16, right:16, top:16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children:[
          const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height:12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText:'Nama')),
          const SizedBox(height:12),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText:'No. HP')),
          const SizedBox(height:16),
          ElevatedButton(onPressed: (){ Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Profil diperbarui (mock)'))); }, child: const Text('SIMPAN')),
          const SizedBox(height:16),
        ])));
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, this.onTap});
  final IconData icon; final String label; final VoidCallback? onTap;
  @override Widget build(BuildContext context)=> InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: const EdgeInsets.only(bottom:8),
      padding: const EdgeInsets.symmetric(horizontal:12, vertical:12),
      decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
      child: Row(children: [
        Container(width:36,height:36, decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)), child: Icon(icon, size:18, color: YawColors.textMuted)),
        const SizedBox(width:10),
        Expanded(child: Text(label, style: const TextStyle(fontSize:13, fontWeight: FontWeight.w600))),
        const SizedBox(width:8),
        const Icon(Icons.chevron_right_rounded, size:18, color: YawColors.textDim),
      ]),
    ),
  );
}
