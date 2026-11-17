import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';
import 'package:rebs_hrms/core/theme/app_theme.dart';
import 'package:rebs_hrms/features/attendance/states/attendance_sync_state.dart';
import 'package:rebs_hrms/features/attendance/widgets/attendance_sync_status_card.dart';

void main() {
  testWidgets('Sync Now starts a manual retry when actions are pending', (
    tester,
  ) async {
    var requested = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AttendanceSyncStatusCard(
            state: const AttendanceSyncState(
              isLoading: false,
              pendingCount: 2,
              feedback: SyncFeedback.serverUnavailable,
            ),
            onSync: () => requested = true,
          ),
        ),
      ),
    );
    expect(find.text(TextConstants.pendingActions(2)), findsOneWidget);
    await tester.tap(find.text(TextConstants.syncNow));
    expect(requested, isTrue);
  });

  testWidgets(
    'Sync Now cannot start a second pass while synchronization is running',
    (tester) async {
      var requested = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceSyncStatusCard(
              state: const AttendanceSyncState(
                isLoading: false,
                isSyncing: true,
                pendingCount: 1,
              ),
              onSync: () => requested = true,
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.text(TextConstants.syncNow));
      expect(requested, isFalse);
    },
  );

  testWidgets('Synchronization state fits narrow screens with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AttendanceSyncStatusCard(
              state: const AttendanceSyncState(
                isLoading: false,
                pendingCount: 2,
                rejectedCount: 1,
                connection: SyncConnection.offline,
              ),
              onSync: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text(TextConstants.syncOffline), findsOneWidget);
    expect(find.text(TextConstants.rejectedActions(1)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
