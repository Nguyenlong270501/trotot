import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/appointment/presentation/widgets/appointment_bottom_bar.dart';

void main() {
  group('AppointmentBottomBar', () {
    testWidgets('should show cancel action and call callback', (tester) async {
      // Arrange
      var cancelTapCount = 0;
      final robot = AppointmentBottomBarRobot(tester);
      await robot.pump(
        showCancelAction: true,
        onCancelTap: () => cancelTapCount++,
      );

      // Assert
      robot.expectCancelActionVisible();

      // Act
      await robot.tapCancelAction();

      // Assert
      expect(cancelTapCount, 1);
    });
  });
}

class AppointmentBottomBarRobot {
  AppointmentBottomBarRobot(this.tester);

  final WidgetTester tester;

  Future<void> pump({
    required bool showCancelAction,
    required VoidCallback onCancelTap,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppointmentBottomBar(
              confirmed: false,
              onMessageTap: () {},
              onConfirmTap: () {},
              showCancelAction: showCancelAction,
              onCancelTap: onCancelTap,
            ),
          ),
        ),
      ),
    );
  }

  void expectCancelActionVisible() {
    expect(find.text('Hủy lịch hẹn'), findsOneWidget);
  }

  Future<void> tapCancelAction() async {
    await tester.tap(find.text('Hủy lịch hẹn'));
    await tester.pump();
  }
}
