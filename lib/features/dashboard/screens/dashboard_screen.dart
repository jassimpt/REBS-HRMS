import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/text_constants.dart';
import '../../workspace/widgets/workspace_header.dart';
import '../controllers/dashboard_controller.dart';
import '../../attendance/controllers/attendance_controller.dart';
import '../../attendance/widgets/attendance_sync_panel.dart';
import '../widgets/dashboard_content.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_page_heading.dart';
import '../../../core/widgets/app_loading_state.dart';
import '../widgets/dashboard_notice.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final state = controller.state;
    final data = state.data;
    final attendance = context.watch<AttendanceController>();
    final summary = data == null ? null : attendance.summarize(data);
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      title: TextConstants.overview,
                      subtitle: TextConstants.overviewSubtitle,
                      isRefreshing: state.isLoading || state.isRefreshing,
                      onRefresh: controller.load,
                    ),
                    const SizedBox(height: 24),
                    if (state.isRefreshing) ...[
                      const LinearProgressIndicator(
                        semanticsLabel: TextConstants.refreshing,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (state.notice != null) ...[
                      DashboardNoticeBanner(
                        notice: state.notice!,
                        hasCachedData: data != null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const AttendanceSyncPanel(hideWhenIdle: true),
                    if (state.isLoading)
                      const AppLoadingState()
                    else if (data == null)
                      AppErrorState(onRetry: controller.load)
                    else
                      DashboardContent(
                        data: summary!.dashboard,
                        todayRecord: summary.today,
                        workingDuration: summary.duration,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
