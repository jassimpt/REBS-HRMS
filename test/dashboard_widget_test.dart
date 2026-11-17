import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';
import 'package:rebs_hrms/core/theme/app_theme.dart';
import 'package:rebs_hrms/features/dashboard/states/dashboard_state.dart';
import 'package:rebs_hrms/features/dashboard/widgets/dashboard_content.dart';
import 'package:rebs_hrms/core/widgets/app_loading_state.dart';
import 'package:rebs_hrms/features/dashboard/widgets/dashboard_notice.dart';
import 'support/dashboard_fixture.dart';

void main() {
  testWidgets('Dashboard shows an accessible loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AppLoadingState()),
      ),
    );
    expect(find.text(TextConstants.loadingDashboard), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets(
    'Saved data warning distinguishes server errors from network failure',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardNoticeBanner(
              notice: DashboardNotice.serverError,
              hasCachedData: true,
            ),
          ),
        ),
      );
      expect(
        find.textContaining(TextConstants.serverErrorMessage),
        findsOneWidget,
      );
      expect(
        find.textContaining(TextConstants.savedDataMessage),
        findsOneWidget,
      );
      expect(find.text(TextConstants.offlineCachedMessage), findsNothing);
    },
  );
  for (final width in [320.0, 667.0, 1024.0]) {
    testWidgets('Loaded dashboard fits width $width with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final data = dashboardFixture();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DashboardContent(
                data: data,
                todayRecord: data.attendance.single,
                workingDuration: const Duration(hours: 8, minutes: 15),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(data.employee.name), findsOneWidget);
      expect(find.text(TextConstants.checkedOut), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text(TextConstants.recentAttendance),
        400,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Empty attendance keeps the rest of the dashboard visible', (
    tester,
  ) async {
    final data = dashboardFixture(empty: true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: DashboardContent(
              data: data,
              todayRecord: null,
              workingDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );
    expect(find.text(TextConstants.noAttendanceTitle), findsOneWidget);
    expect(find.text(TextConstants.notCheckedIn), findsOneWidget);
    expect(find.text(data.employee.name), findsOneWidget);
  });
}
