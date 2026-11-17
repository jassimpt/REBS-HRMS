import 'package:flutter/material.dart';

import '../constants/text_constants.dart';

class AppPageHeading extends StatelessWidget {
  const AppPageHeading({
    required this.title,
    required this.subtitle,
    required this.isRefreshing,
    required this.onRefresh,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final headingWidth = constraints.maxWidth >= 500
            ? constraints.maxWidth - 150
            : constraints.maxWidth;
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: headingWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: isRefreshing ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(TextConstants.refresh),
            ),
          ],
        );
      },
    );
  }
}
