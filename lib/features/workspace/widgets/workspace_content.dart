import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../attendance/screens/attendance_screen.dart';
import '../states/workspace_state.dart';
import 'workspace_header.dart';

class WorkspaceContent extends StatelessWidget {
  const WorkspaceContent({required this.section, super.key});

  final WorkspaceSection section;

  @override
  Widget build(BuildContext context) {
    if (section == WorkspaceSection.overview) return const DashboardScreen();
    if (section == WorkspaceSection.attendance) return const AttendanceScreen();
    final theme = Theme.of(context);
    final (title, subtitle, icon, emptyTitle, description) = switch (section) {
      WorkspaceSection.overview => (
        TextConstants.overview,
        TextConstants.overviewSubtitle,
        Icons.grid_view_rounded,
        TextConstants.overviewTitle,
        TextConstants.overviewDescription,
      ),
      WorkspaceSection.attendance => (
        TextConstants.attendance,
        TextConstants.attendanceSubtitle,
        Icons.schedule_rounded,
        TextConstants.attendanceTitle,
        TextConstants.attendanceDescription,
      ),
      WorkspaceSection.leave => (
        TextConstants.leave,
        TextConstants.leaveSubtitle,
        Icons.event_note_rounded,
        TextConstants.leaveTitle,
        TextConstants.leaveDescription,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 600 ? 20.0 : 40.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WorkspaceHeader(),
                  const SizedBox(height: 40),
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppEmptyState(
                    icon: icon,
                    title: emptyTitle,
                    description: description,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
