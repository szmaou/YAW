import 'package:flutter/material.dart';
import '../../app/theme.dart';

class YawButton extends StatelessWidget {
  const YawButton({super.key, required this.label, this.onPressed, this.isLoading=false, this.icon, this.outlined=false, this.expand=false});
  final String label; final VoidCallback? onPressed; final bool isLoading; final IconData? icon; final bool outlined; final bool expand;
  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width:18,height:18, child: CircularProgressIndicator(strokeWidth:2, color: YawColors.background))
        : Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon!=null) ...[Icon(icon,size:18), const SizedBox(width:8)],
            Text(label),
          ]);
    final btn = outlined
        ? OutlinedButton(onPressed: isLoading?null:onPressed, child: child)
        : ElevatedButton(onPressed: isLoading?null:onPressed, child: child);
    if (expand) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}

class YawGhostButton extends StatelessWidget {
  const YawGhostButton({super.key, required this.label, this.onPressed});
  final String label; final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(foregroundColor: YawColors.primary),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .6)),
  );
}
