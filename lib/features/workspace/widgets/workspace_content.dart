import 'package:flutter/material.dart';

import '../../attendance/screens/attendance_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../leave/screens/leave_screen.dart';
import '../states/workspace_state.dart';

class WorkspaceContent extends StatelessWidget {
  const WorkspaceContent({required this.section, super.key});

  final WorkspaceSection section;

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      WorkspaceSection.overview => const DashboardScreen(),
      WorkspaceSection.attendance => const AttendanceScreen(),
      WorkspaceSection.leave => const LeaveScreen(),
    };
  }
}
