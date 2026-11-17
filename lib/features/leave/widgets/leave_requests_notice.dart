import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/colors.dart';
import '../../../core/network/api_exception.dart';
import '../states/leave_requests_state.dart';

class LeaveRequestsNotice extends StatelessWidget {
  const LeaveRequestsNotice({required this.state, super.key});
  final LeaveRequestsState state;

  @override
  Widget build(BuildContext context) {
    final message = state.cacheError
        ? TextConstants.leaveCacheError
        : switch (state.failure) {
            ApiFailure.unavailable =>
              state.data == null
                  ? TextConstants.leaveOfflineNoCache
                  : TextConstants.leaveOfflineCached,
            ApiFailure.timeout => TextConstants.timeoutMessage,
            ApiFailure.server => TextConstants.leaveServerError,
            ApiFailure.invalidResponse ||
            null => TextConstants.leaveInvalidResponse,
          };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
      ),
    );
  }
}
