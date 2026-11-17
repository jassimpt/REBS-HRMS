import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';
import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/core/theme/app_theme.dart';
import 'package:rebs_hrms/features/leave/controllers/leave_form_controller.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/widgets/leave_application_form.dart';
import 'package:rebs_hrms/features/leave/widgets/leave_content.dart';
import 'package:rebs_hrms/features/leave/widgets/leave_date_field.dart';
import 'support/leave_fixture.dart';

void main() {
  for (final width in [320.0, 768.0, 1366.0]) {
    testWidgets(
      'Leave form and all statuses fit width $width with enlarged text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = LeaveFormController();
        final data = leaveSnapshotFixture(
          requests: [
            for (final status in LeaveRequestStatus.values)
              leaveRequestFixture(id: status.name, status: status),
          ],
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: controller,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LeaveContent(
                    data: data,
                    timezone: 'Asia/Kolkata',
                    canApply: true,
                    onSubmit: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(TextConstants.pending), findsOneWidget);
        expect(find.text(TextConstants.approved), findsOneWidget);
        expect(find.text(TextConstants.rejected), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }

  testWidgets(
    'Date picker updates Provider state and reason input stays in its controller',
    (tester) async {
      final controller = LeaveFormController();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: LeaveApplicationForm(
                  timezone: 'Asia/Kolkata',
                  onSubmit: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(LeaveDateField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        controller.state.startDate,
        CompanyClock.dateKey(DateTime.now(), 'Asia/Kolkata'),
      );
      await tester.enterText(find.byType(TextField), 'Personal appointments.');
      expect(controller.state.reason, 'Personal appointments.');
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('Local validation errors are displayed under their fields', (
    tester,
  ) async {
    final controller = LeaveFormController();
    await controller.submit(
      snapshot: leaveSnapshotFixture(),
      employeeId: 'REBS-1042',
      timezone: 'Asia/Kolkata',
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LeaveApplicationForm(
                timezone: 'Asia/Kolkata',
                onSubmit: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      find.text(TextConstants.leaveValidation('required')!),
      findsNWidgets(2),
    );
    expect(
      find.text(TextConstants.leaveValidation('reasonTooShort')!),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
