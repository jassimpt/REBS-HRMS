import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/leave_form_controller.dart';
import '../models/leave_type.dart';
import '../states/leave_form_state.dart';
import 'leave_date_field.dart';
import 'leave_form_feedback.dart';

class LeaveApplicationForm extends StatelessWidget {
  const LeaveApplicationForm({
    required this.timezone,
    required this.onSubmit,
    this.canApply = true,
    super.key,
  });

  final String timezone;
  final VoidCallback onSubmit;
  final bool canApply;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LeaveFormController>();
    final state = controller.state;
    final theme = Theme.of(context);
    final enabled = canApply && !state.isSubmitting;
    final today = controller.today(timezone);
    final endMinimum = state.startDate == null
        ? today
        : CompanyClock.parseCalendarDate(state.startDate!);
    final firstEnd = endMinimum.isBefore(today) ? today : endMinimum;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TextConstants.applyForLeave, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          if (!canApply) ...[
            const Text(TextConstants.leaveNeedsEmployee),
            const SizedBox(height: 16),
          ],
          if (state.feedback != null) ...[
            LeaveFormFeedbackBanner(feedback: state.feedback!),
            const SizedBox(height: 20),
          ],
          DropdownButtonFormField<LeaveType>(
            key: ValueKey(state.type),
            initialValue: state.type,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: TextConstants.leaveType,
            ),
            items: const [
              DropdownMenuItem(
                value: LeaveType.casual,
                child: Text(TextConstants.casual),
              ),
              DropdownMenuItem(
                value: LeaveType.sick,
                child: Text(TextConstants.sick),
              ),
            ],
            onChanged: !enabled
                ? null
                : (value) {
                    if (value != null) controller.selectType(value);
                  },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final start = LeaveDateField(
                label: TextConstants.startDate,
                value: state.startDate,
                today: today,
                firstDate: today,
                enabled: enabled,
                onSelected: controller.selectStart,
                error: TextConstants.leaveValidation(
                  state.errors[LeaveField.startDate]?.name,
                ),
              );
              final end = LeaveDateField(
                label: TextConstants.endDate,
                value: state.endDate,
                today: today,
                firstDate: firstEnd,
                enabled: enabled,
                onSelected: controller.selectEnd,
                error: TextConstants.leaveValidation(
                  state.errors[LeaveField.endDate]?.name,
                ),
              );
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [start, const SizedBox(height: 24), end],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: start),
                  const SizedBox(width: 16),
                  Expanded(child: end),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (controller.requestedDays != null) ...[
            Text(
              TextConstants.leaveDays(controller.requestedDays!),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            TextConstants.calendarDaysNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.reasonController,
            enabled: enabled,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: TextConstants.leaveReason,
              alignLabelWithHint: true,
              hintText: TextConstants.leaveReasonHint,
              helperText: TextConstants.leaveReasonHelp,
              helperMaxLines: 3,
              errorText: TextConstants.leaveValidation(
                state.errors[LeaveField.reason]?.name,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (state.isSubmitting) ...[
            const LinearProgressIndicator(
              semanticsLabel: TextConstants.submittingLeave,
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: enabled ? onSubmit : null,
              icon: const Icon(Icons.send_outlined),
              label: const Text(TextConstants.submitLeave),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            ),
          ),
        ],
      ),
    );
  }
}
