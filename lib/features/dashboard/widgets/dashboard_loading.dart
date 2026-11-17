import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_card.dart';

class DashboardLoading extends StatelessWidget {
  const DashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const CircularProgressIndicator(
              semanticsLabel: TextConstants.loadingDashboard,
            ),
            const SizedBox(height: 24),
            Text(
              TextConstants.loadingDashboard,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
