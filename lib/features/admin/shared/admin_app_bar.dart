import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/app/theme.dart';

/// Shared admin AppBar — admin pages live outside the ShellRoute so they
/// manage their own AppBar. Back navigates to the admin dashboard by default.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backTo = '/admin/dashboard',
    this.showBack = true,
  });

  final String title;
  final List<Widget>? actions;
  final String backTo;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.canPop() ? context.pop() : context.go(backTo),
            )
          : null,
      actions: [
        ...?actions,
        IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: YawColors.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
