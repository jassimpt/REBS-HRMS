import 'package:flutter/material.dart';

import '../helpers/colors.dart';

enum StatusTone { neutral, success, warning }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    this.tone = StatusTone.neutral,
    super.key,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.neutral => (AppColors.textSecondary, AppColors.background),
      StatusTone.success => (
        AppColors.onPrimaryContainer,
        AppColors.primaryContainer,
      ),
      StatusTone.warning => (AppColors.warning, AppColors.warningContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
