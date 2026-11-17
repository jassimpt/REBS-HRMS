import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_state.dart';
import '../../../core/widgets/app_page_heading.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../workspace/widgets/workspace_header.dart';
import '../controllers/leave_form_controller.dart';
import '../controllers/leave_requests_controller.dart';
import '../states/leave_form_state.dart';
import '../widgets/leave_content.dart';
import '../widgets/leave_requests_notice.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<LeaveRequestsController>();
    final dashboard = context.watch<DashboardController>();
    final state = requests.state;
    final data = state.data;
    final employee = dashboard.state.data?.employee;
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([requests.load(), dashboard.load()]);
          },
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
                      title: TextConstants.leave,
                      subtitle: TextConstants.leaveSubtitle,
                      isRefreshing: state.isLoading || state.isRefreshing,
                      onRefresh: () {
                        requests.load();
                        dashboard.load();
                      },
                    ),
                    const SizedBox(height: 24),
                    if (state.isRefreshing) ...[
                      const LinearProgressIndicator(
                        semanticsLabel: TextConstants.loadingLeave,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (state.failure != null || state.cacheError) ...[
                      LeaveRequestsNotice(state: state),
                      const SizedBox(height: 16),
                    ],
                    if (state.isLoading)
                      const AppLoadingState(label: TextConstants.loadingLeave)
                    else if (data == null)
                      AppErrorState(
                        title: TextConstants.leaveLoadErrorTitle,
                        onRetry: requests.load,
                      )
                    else
                      LeaveContent(
                        data: data,
                        timezone: employee?.office.timezone ?? 'UTC',
                        canApply: employee != null,
                        onSubmit: () async {
                          if (employee == null) return;
                          final form = context.read<LeaveFormController>();
                          final result = await form.submit(
                            snapshot: data,
                            employeeId: employee.id,
                            timezone: employee.office.timezone,
                          );
                          if (result != null) {
                            await requests.addSubmitted(result);
                            await dashboard.load();
                          } else if (form.state.feedback ==
                              LeaveFormFeedback.serverRejected) {
                            await requests.load();
                          }
                        },
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
