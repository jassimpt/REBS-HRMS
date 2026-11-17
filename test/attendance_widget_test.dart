import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';
import 'package:rebs_hrms/core/theme/app_theme.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_summary_service.dart';
import 'package:rebs_hrms/features/attendance/states/attendance_state.dart';
import 'package:rebs_hrms/features/attendance/widgets/attendance_action_card.dart';
import 'package:rebs_hrms/features/attendance/widgets/attendance_event_item.dart';
import 'package:rebs_hrms/features/attendance/widgets/attendance_feedback_banner.dart';
import 'support/attendance_fixture.dart';
import 'support/dashboard_fixture.dart';

void main() {
  for (final width in [320.0, 768.0, 1024.0]) {
    testWidgets(
      'Attendance controls and pending event fit width $width with large text',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final event = attendanceFixture();
        final summary = AttendanceSummaryService().summarize(
          dashboardFixture(empty: true),
          [event],
        );
        AttendanceAction? action;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    AttendanceActionCard(
                      summary: summary,
                      isBusy: false,
                      onAction: (value) => action = value,
                    ),
                    AttendanceEventItem(event: event, timezone: 'Asia/Kolkata'),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text(TextConstants.pendingSync), findsOneWidget);
        await tester.tap(find.text(TextConstants.checkOut));
        expect(action, AttendanceAction.checkOut);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('A permanently denied permission offers app settings', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceFeedbackBanner(
            feedback: AttendanceFeedback.locationPermanentlyDenied,
            onAppSettings: () => opened = true,
            onLocationSettings: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text(TextConstants.openAppSettings));
    expect(opened, isTrue);
  });
}
