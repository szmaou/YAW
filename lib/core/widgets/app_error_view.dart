import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.message, this.onRetry, this.icon});
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: YawColors.border)),
            child: Icon(icon ?? Icons.signal_wifi_off_rounded, color: YawColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('COBA LAGI')),
          ]
        ]),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.title, required this.subtitle, this.actionLabel, this.onAction, this.icon});
  final String title; final String subtitle; final String? actionLabel; final VoidCallback? onAction; final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon ?? Icons.inbox_outlined, size: 48, color: YawColors.textDim),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!.toUpperCase())),
          ]
        ]),
      ),
    );
  }
}

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: YawColors.primary));
}
