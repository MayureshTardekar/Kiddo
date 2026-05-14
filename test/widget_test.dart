import 'package:child_app/app/child_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> launchApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ChildApp());
    await tester.pump(const Duration(milliseconds: 1300));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const ValueKey('nav-home')).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> tapNav(WidgetTester tester, int index) async {
    const keys = [
      'nav-home',
      'nav-learn',
      'nav-quest',
      'nav-rewards',
      'nav-me'
    ];
    await tester.tap(find.byKey(ValueKey(keys[index])));
    await tester.pump();
  }

  testWidgets('launches into the upgraded dashboard', (tester) async {
    await launchApp(tester);

    expect(find.text('Kiddo Adventure'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Quiz Quest'), findsOneWidget);
    expect(find.text('Rewards'), findsWidgets);
  });

  testWidgets('practice shows A for Apple content and selected caption',
      (tester) async {
    await launchApp(tester);

    await tapNav(tester, 1);
    expect(find.text('A for Apple'), findsWidgets);
    expect(find.text('B for Ball'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('learning-letter_a')));
    await tester.pump();

    expect(find.text('A for Apple'), findsWidgets);
  });

  testWidgets('practice numbers show 1 through 5 examples', (tester) async {
    await launchApp(tester);

    await tapNav(tester, 1);
    await tester.tap(find.text('Numbers'));
    await tester.pump();

    expect(find.text('1 for One Piece'), findsOneWidget);
    expect(find.text('5 for Five Rockets'), findsOneWidget);
  });

  testWidgets('quiz correct answer increases score', (tester) async {
    await launchApp(tester);

    await tapNav(tester, 2);
    tester
        .widget<ElevatedButton>(
          find.byKey(const ValueKey('correct-answer')).last,
        )
        .onPressed!();
    await tester.pump();

    expect(find.text('Score 10'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('voice narrator toggle updates setting text', (tester) async {
    await launchApp(tester);

    await tapNav(tester, 4);
    expect(find.text('Voice narrator is on'), findsOneWidget);

    tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).onChanged!(
      false,
    );
    await tester.pump();

    expect(find.text('Voice narrator is off'), findsOneWidget);
  });
}
