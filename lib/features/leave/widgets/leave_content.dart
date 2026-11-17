import 'package:flutter/material.dart';

import '../models/leave_snapshot_model.dart';
import 'leave_application_form.dart';
import 'leave_balance_card.dart';
import 'leave_requests_list.dart';

class LeaveContent extends StatelessWidget {
  const LeaveContent({
    required this.data,
    required this.timezone,
    required this.canApply,
    required this.onSubmit,
    super.key,
  });

  final LeaveSnapshotModel data;
  final String timezone;
  final bool canApply;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final form = LeaveApplicationForm(
          timezone: timezone,
          canApply: canApply,
          onSubmit: onSubmit,
        );
        final balance = LeaveBalanceCard(balance: data.balance);
        final requests = LeaveRequestsList(requests: data.requests);
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              balance,
              const SizedBox(height: 20),
              form,
              const SizedBox(height: 32),
              requests,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                children: [balance, const SizedBox(height: 32), requests],
              ),
            ),
          ],
        );
      },
    );
  }
}
