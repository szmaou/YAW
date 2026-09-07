import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static ScreenType typeOf(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    if (w < Breakpoints.mobile) return ScreenType.mobile;
    if (w < Breakpoints.tablet) return ScreenType.tablet;
    return ScreenType.desktop;
  }
  static bool isMobile(BuildContext c) => typeOf(c) == ScreenType.mobile;
  static bool isTablet(BuildContext c) => typeOf(c) == ScreenType.tablet;
  static bool isDesktop(BuildContext c) => typeOf(c) == ScreenType.desktop;
  static bool isWide(BuildContext c) => !isMobile(c);
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, this.tablet, this.desktop});
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  @override
  Widget build(BuildContext context) {
    final t = Responsive.typeOf(context);
    if (t == ScreenType.desktop && desktop != null) return desktop!;
    if (t == ScreenType.tablet && tablet != null) return tablet!;
    return mobile;
  }
}

class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    double hPad = 16;
    if (w >= 1024) hPad = 32;
    else if (w >= 600) hPad = 24;
    return Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: child);
  }
}
