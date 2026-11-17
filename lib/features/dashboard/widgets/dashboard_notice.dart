import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/colors.dart';
import '../states/dashboard_state.dart';

class DashboardNoticeBanner extends StatelessWidget {
  const DashboardNoticeBanner({
    required this.notice,
    required this.hasCachedData,
    super.key,
  });

  final DashboardNotice notice;
  final bool hasCachedData;

  @override
  Widget build(BuildContext context) {
    final message = switch (notice) {
      DashboardNotice.unavailable =>
        hasCachedData
            ? TextConstants.offlineCachedMessage
            : TextConstants.offlineMessage,
      DashboardNotice.timeout => TextConstants.timeoutMessage,
      DashboardNotice.serverError => TextConstants.serverErrorMessage,
      DashboardNotice.invalidResponse => TextConstants.invalidResponseMessage,
      DashboardNotice.cacheError => TextConstants.cacheErrorMessage,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasCachedData &&
                      notice != DashboardNotice.unavailable &&
                      notice != DashboardNotice.cacheError
                  ? '$message ${TextConstants.savedDataMessage}'
                  : message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
