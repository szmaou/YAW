import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/app/theme.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashState();
}
class _SplashState extends ConsumerState<SplashPage> {
  @override
  void initState() { super.initState(); Future.microtask(()=> ref.read(authProvider.notifier).checkAuth()); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.topCenter, radius: 1.2,
            colors: [Color(0xFF0F2A3A), YawColors.background], stops: [0, .7]),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: YawColors.primary, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: YawColors.primary.withValues(alpha: .35), blurRadius: 24)]),
            child: const Center(child: Text('Y', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: YawColors.background)))),
          const SizedBox(height: 20),
          const Text('YAW', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 8, fontSize: 22)),
          const SizedBox(height: 6),
          const Text('THE FUTURE OF MOBILITY', style: TextStyle(fontSize: 10, letterSpacing: 3, color: YawColors.textMuted)),
          const SizedBox(height: 32),
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: YawColors.primary)),
        ])),
      ),
    );
  }
}
