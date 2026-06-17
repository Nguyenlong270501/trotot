import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotot/features/map_search/presentation/widgets/map_filter_result_bar.dart';

void main() {
  group('MapFilterResultBar', () {
    testWidgets('should hide navigation when only one marker is rendered', (
      tester,
    ) async {
      // Arrange
      final robot = MapFilterResultBarRobot(tester);

      // Act
      await robot.pump(pinnedCount: 1);

      // Assert
      robot.expectNavigationNotVisible();
    });

    testWidgets('should show index and invoke navigation when markers are rendered', (
      tester,
    ) async {
      // Arrange
      var previousTapCount = 0;
      var nextTapCount = 0;
      final robot = MapFilterResultBarRobot(tester);

      // Act
      await robot.pump(
        pinnedCount: 3,
        focusedIndex: 2,
        onPrevious: () => previousTapCount++,
        onNext: () => nextTapCount++,
      );
      await robot.tapPrevious();
      await robot.tapNext();

      // Assert
      robot.expectIndexVisible('2/3');
      expect(previousTapCount, 1);
      expect(nextTapCount, 1);
    });
  });
}

class MapFilterResultBarRobot {
  MapFilterResultBarRobot(this.tester);

  final WidgetTester tester;

  Future<void> pump({
    required int pinnedCount,
    int focusedIndex = 1,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) {
          return MaterialApp(
            home: Scaffold(
              body: MapFilterResultBar(
                count: pinnedCount,
                pinnedCount: pinnedCount,
                focusedIndex: focusedIndex,
                onPrevious: onPrevious ?? () {},
                onNext: onNext ?? () {},
                onClear: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> tapPrevious() async {
    await tester.tap(find.byIcon(Icons.chevron_left));
  }

  Future<void> tapNext() async {
    await tester.tap(find.byIcon(Icons.chevron_right));
  }

  void expectNavigationNotVisible() {
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  }

  void expectIndexVisible(String index) {
    expect(find.text(index), findsOneWidget);
  }
}
