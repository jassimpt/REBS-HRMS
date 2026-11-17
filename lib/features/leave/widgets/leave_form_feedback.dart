import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/colors.dart';
import '../states/leave_form_state.dart';

class LeaveFormFeedbackBanner extends StatelessWidget {
  const LeaveFormFeedbackBanner({required this.feedback, super.key});
  final LeaveFormFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final message = switch (feedback) {
      LeaveFormFeedback.submitted => TextConstants.leaveSubmitted,
      LeaveFormFeedback.unavailable => TextConstants.leaveSubmitOffline,
      LeaveFormFeedback.timeout => TextConstants.leaveSubmitTimeout,
      LeaveFormFeedback.serverRejected => TextConstants.leaveSubmitRejected,
      LeaveFormFeedback.serverError => TextConstants.leaveSubmitServerError,
      LeaveFormFeedback.invalidResponse => TextConstants.leaveInvalidResponse,
    };
    final success = feedback == LeaveFormFeedback.submitted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? AppColors.primaryContainer
            : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: success ? AppColors.onPrimaryContainer : AppColors.warning,
        ),
      ),
    );
  }
}
