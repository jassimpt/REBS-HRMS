import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_page_heading.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_state.dart';
import '../../workspace/widgets/workspace_header.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/attendance_sync_controller.dart';
import '../widgets/attendance_sync_panel.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/attendance_event_item.dart';
import '../widgets/attendance_feedback_banner.dart';
import '../widgets/today_attendance_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final controller = context.watch<AttendanceController>();
    final state = controller.state;
    final data = dashboard.state.data;
    final summary = data == null ? null : controller.summarize(data);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth < 600 ? 20 : 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WorkspaceHeader(),
                  const SizedBox(height: 32),
                  AppPageHeading(
                    title: TextConstants.attendance,
                    subtitle: TextConstants.attendanceSubtitle,
                    isRefreshing:
                        dashboard.state.isLoading ||
                        dashboard.state.isRefreshing ||
                        state.isSubmitting,
                    onRefresh: () {
                      dashboard.load();
                      controller.load();
                    },
                  ),
                  const SizedBox(height: 24),
                  const AttendanceSyncPanel(),
                  if (state.feedback != null) ...[
                    AttendanceFeedbackBanner(
                      feedback: state.feedback!,
                      onAppSettings: controller.openAppSettings,
                      onLocationSettings: controller.openLocationSettings,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (dashboard.state.isLoading || state.isLoading)
                    const AppLoadingState()
                  else if (summary == null)
                    AppErrorState(onRetry: dashboard.load)
                  else ...[
                    TodayAttendanceCard(
                      record: summary.today,
                      timezone: data!.employee.office.timezone,
                      duration: summary.duration,
                    ),
                    const SizedBox(height: 20),
                    AttendanceActionCard(
                      summary: summary,
                      isBusy: state.isSubmitting,
                      onAction: (action) async {
                        final sync = context.read<AttendanceSyncController>();
                        if (await controller.submit(action, data)) {
                          await sync.syncNow();
                        }
                      },
                    ),
                    if (state.events.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        TextConstants.attendanceActivity,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      for (final event in state.events.reversed.take(10)) ...[
                        AttendanceEventItem(
                          event: event,
                          timezone: data.employee.office.timezone,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
