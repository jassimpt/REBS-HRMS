import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/colors.dart';
import '../states/attendance_state.dart';

class AttendanceFeedbackBanner extends StatelessWidget {
  const AttendanceFeedbackBanner({
    required this.feedback,
    required this.onAppSettings,
    required this.onLocationSettings,
    super.key,
  });

  final AttendanceFeedback feedback;
  final VoidCallback onAppSettings;
  final VoidCallback onLocationSettings;

  @override
  Widget build(BuildContext context) {
    final message = switch (feedback) {
      AttendanceFeedback.checkedIn => TextConstants.checkInSuccess,
      AttendanceFeedback.checkedOut => TextConstants.checkOutSuccess,
      AttendanceFeedback.savedPending => TextConstants.attendanceSavedPending,
      AttendanceFeedback.rejected => TextConstants.attendanceRejected,
      AttendanceFeedback.storageError => TextConstants.attendanceStorageError,
      AttendanceFeedback.locationDenied => TextConstants.locationDenied,
      AttendanceFeedback.locationPermanentlyDenied =>
        TextConstants.locationPermanentlyDenied,
      AttendanceFeedback.locationDisabled => TextConstants.locationDisabled,
      AttendanceFeedback.locationUnavailable =>
        TextConstants.locationUnavailable,
      AttendanceFeedback.outsideOffice => TextConstants.outsideOffice,
      AttendanceFeedback.checkInRequired => TextConstants.checkInRequired,
      AttendanceFeedback.alreadyCheckedIn => TextConstants.alreadyCheckedIn,
      AttendanceFeedback.alreadyCheckedOut => TextConstants.alreadyCheckedOut,
      AttendanceFeedback.dayChanged => TextConstants.attendanceDayChanged,
    };
    final success =
        feedback == AttendanceFeedback.checkedIn ||
        feedback == AttendanceFeedback.checkedOut;
    final foreground = success
        ? AppColors.onPrimaryContainer
        : AppColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? AppColors.primaryContainer
            : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: foreground),
          ),
          if (feedback == AttendanceFeedback.locationPermanentlyDenied)
            TextButton(
              onPressed: onAppSettings,
              child: const Text(TextConstants.openAppSettings),
            ),
          if (feedback == AttendanceFeedback.locationDisabled)
            TextButton(
              onPressed: onLocationSettings,
              child: const Text(TextConstants.openLocationSettings),
            ),
        ],
      ),
    );
  }
}
