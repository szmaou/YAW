import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'router.dart';

class YawApp extends ConsumerWidget {
  const YawApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'YAW',
      debugShowCheckedModeBanner: false,
      theme: YawTheme.dark(),
      routerConfig: router,
    );
  }
}
