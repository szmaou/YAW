import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/utils/responsive.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (label: 'Home', icon: Icons.home_outlined, active: Icons.home_rounded, path: '/home'),
    (label: 'Vehicles', icon: Icons.directions_car_outlined, active: Icons.directions_car_rounded, path: '/vehicles'),
    (label: 'Favorites', icon: Icons.favorite_border, active: Icons.favorite_rounded, path: '/favorites'),
    (label: 'Orders', icon: Icons.receipt_long_outlined, active: Icons.receipt_long_rounded, path: '/orders'),
    (label: 'Profile', icon: Icons.person_outline, active: Icons.person_rounded, path: '/profile'),
  ];

  int _index(BuildContext c) {
    final loc = GoRouterState.of(c).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(children: [
          _Sidebar(index: _index(context)),
          Expanded(child: child),
        ]),
      );
    }
    final idx = _index(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon), selectedIcon: Icon(t.active), label: t.label)).toList(),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(color: YawColors.surface, border: Border(right: BorderSide(color: YawColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: YawColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('Y', style: TextStyle(fontWeight: FontWeight.w900, color: YawColors.background, fontSize: 18)))),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YAW', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 3, fontSize: 16)),
              Text('FUTURE MOBILITY', style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: YawColors.textMuted)),
            ])
          ]),
        ),
        const SizedBox(height: 8),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text('MENU', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: YawColors.textDim, fontWeight: FontWeight.w700))),
        ...List.generate(AppShell._tabs.length, (i) {
          final t = AppShell._tabs[i];
          final sel = i == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: InkWell(
              onTap: () => context.go(t.path),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? YawColors.primary.withValues(alpha: .12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? YawColors.primary.withValues(alpha: .3) : Colors.transparent),
                ),
                child: Row(children: [
                  Icon(sel ? t.active : t.icon, size: 18, color: sel ? YawColors.primary : YawColors.textMuted),
                  const SizedBox(width: 10),
                  Text(t.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? YawColors.primary : YawColors.textMuted)),
                ]),
              ),
            ),
          );
        }),
        const Spacer(),
        Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: YawColors.border)),
          child: const Row(children: [
            Icon(Icons.bolt_rounded, color: YawColors.primary, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Futuristic\nAutomotive', style: TextStyle(fontSize: 11, color: YawColors.textMuted, height: 1.3))),
          ])),
        const SizedBox(height: 12),
      ]),
    );
  }
}
