import 'package:flutter/material.dart';

import '../constants/text_constants.dart';
import 'app_card.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.onRetry,
    this.title = TextConstants.dashboardErrorTitle,
    super.key,
  });

  final String title;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(TextConstants.retry),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
