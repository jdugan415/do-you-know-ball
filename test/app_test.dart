import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_you_know_ball/app.dart';
import 'package:do_you_know_ball/features/roster/roster_repository.dart';
import 'package:do_you_know_ball/features/teams/team.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });
  testWidgets('complete round, review results, replay and confirm exit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(BallApp(repository: TestRosterRepository()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Steelers');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('team-PIT')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('team-PIT')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('team-PIT')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Start Steelers quiz →'));
    for (var i = 0; i < 10; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('answer-0')));
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('answer-0')))
            .onPressed,
        isNull,
      );
      await tapVisible(
        tester,
        find.text(i == 9 ? 'See results →' : 'Next player →'),
      );
      expect(tester.takeException(), isNull);
    }
    expect(find.text('The final whistle'), findsOneWidget);
    await tapVisible(tester, find.text('Play another round →'));
    expect(find.text('QUESTION 1 / 10'), findsOneWidget);
    expect(find.text('0 correct'), findsOneWidget);
    await tester.tap(find.byTooltip('Leave quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    expect(find.text('Pittsburgh Steelers challenge'), findsOneWidget);
    await tester.tap(find.byTooltip('Leave quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Start Steelers quiz →'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small screen and large text remain usable', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(BallApp(repository: TestRosterRepository()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Steelers');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('team-PIT')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('team-PIT')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('team-PIT')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Start Steelers quiz →'));
    await tapVisible(tester, find.byKey(const ValueKey('answer-0')));
    expect(tester.takeException(), isNull);
  });
}

class TestRosterRepository extends RosterRepository {
  @override
  Future<List<NflTeam>> loadTeams() async =>
      (jsonDecode(File('assets/teams.json').readAsStringSync()) as List)
          .map((t) => NflTeam.fromJson(t as Map<String, dynamic>))
          .toList();
  @override
  Future<Roster> load(NflTeam team) async => Roster.fromJson(
    jsonDecode(File('assets/rosters/${team.file}').readAsStringSync())
        as Map<String, dynamic>,
  );
}
