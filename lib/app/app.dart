import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/text_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/attendance/controllers/attendance_controller.dart';
import '../features/attendance/controllers/attendance_sync_controller.dart';
import '../features/workspace/controllers/workspace_controller.dart';
import '../features/workspace/screens/workspace_screen.dart';
import '../features/leave/controllers/leave_requests_controller.dart';
import '../features/leave/controllers/leave_form_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => LeaveRequestsController()),
        ChangeNotifierProvider(create: (_) => LeaveFormController()),
        ChangeNotifierProvider(
          create: (_) => AttendanceSyncController(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: TextConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const WorkspaceScreen(),
      ),
    );
  }
}
