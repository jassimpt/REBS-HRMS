import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../leave/models/leave_balance_model.dart';

class LeaveBalanceCard extends StatelessWidget {
  const LeaveBalanceCard({required this.balance, super.key});

  final LeaveBalanceModel balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextConstants.leaveBalance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${balance.total}',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            TextConstants.daysAvailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              Text(
                '${TextConstants.casual} · ${balance.casual}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${TextConstants.sick} · ${balance.sick}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
