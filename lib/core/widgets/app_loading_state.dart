import 'package:flutter/material.dart';

import '../constants/text_constants.dart';
import 'app_card.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    this.label = TextConstants.loadingDashboard,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            CircularProgressIndicator(semanticsLabel: label),
            const SizedBox(height: 24),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
