import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/app/app.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';

void main() {
  testWidgets('Workspace navigation changes the visible section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.text(TextConstants.overviewTitle), findsOneWidget);

    await tester.tap(find.text(TextConstants.attendance));
    await tester.pumpAndSettle();
    expect(find.text(TextConstants.attendanceTitle), findsOneWidget);
    expect(find.text(TextConstants.overviewTitle), findsNothing);

    await tester.tap(find.text(TextConstants.leave));
    await tester.pumpAndSettle();
    expect(find.text(TextConstants.leaveTitle), findsOneWidget);

    await tester.tap(find.text(TextConstants.overview));
    await tester.pumpAndSettle();
    expect(find.text(TextConstants.overviewTitle), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(667, 375),
    const Size(768, 1024),
    const Size(1366, 768),
  ]) {
    testWidgets('Workspace fits $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byType(size.width >= 720 ? NavigationRail : NavigationBar),
        findsOneWidget,
      );
      await tester.tap(find.text(TextConstants.leave));
      await tester.pumpAndSettle();
      expect(find.text(TextConstants.leaveTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
