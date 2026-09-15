import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_you_know_ball/app.dart';
import 'package:do_you_know_ball/features/teams/team.dart';
import 'package:do_you_know_ball/features/roster/roster.dart';
import 'package:do_you_know_ball/features/quiz/quiz_session.dart';

import 'app_test.dart' show TestRosterRepository, tapVisible;

void main() {
  final teams = (jsonDecode(
    File('assets/teams.json').readAsStringSync(),
  ) as List).map((t) => NflTeam.fromJson(t as Map<String, dynamic>)).toList();
  test('32 unique teams, balanced conferences and divisions', () {
    expect(teams.length, 32);
    expect(teams.map((t) => t.id).toSet().length, 32);
    expect(teams.map((t) => t.file).toSet().length, 32);
    for (final conference in ['AFC', 'NFC']) {
      expect(teams.where((t) => t.conference == conference).length, 16);
      for (final division in ['North', 'South', 'East', 'West']) {
        expect(
          teams
              .where(
                (t) => t.conference == conference && t.division == division,
              )
              .length,
          4,
        );
      }
    }
  });
  for (final team in teams) {
    test('${team.id} roster and ten full random rounds are valid', () {
      final roster = Roster.fromJson(
        jsonDecode(File('assets/rosters/${team.file}').readAsStringSync())
            as Map<String, dynamic>,
      );
      expect(roster.teamId, team.id);
      expect(roster.team, team.name);
      for (var seed = 0; seed < 10; seed++) {
        final quiz = QuizSession(roster, random: Random(seed));
        expect(quiz.questions.map((q) => q.player.id).toSet().length, 10);
        for (var i = 0; i < 10; i++) {
          expect(
            quiz.current.options.every((p) => roster.players.contains(p)),
            isTrue,
          );
          expect(quiz.current.options.map((p) => p.id).toSet().length, 4);
          expect(quiz.answer(quiz.current.player.id), isTrue);
          if (i < 9) expect(quiz.next(), isTrue);
        }
        expect(quiz.score, 10);
        expect(quiz.complete, isTrue);
      }
    });
  }
  testWidgets('filters and search lead to Cowboys quiz and back to teams', (
    tester,
  ) async {
    await tester.pumpWidget(BallApp(repository: TestRosterRepository()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cowboys');
    await tester.tap(find.widgetWithText(ChoiceChip, 'AFC'));
    await tester.pumpAndSettle();
    expect(find.text('No teams found. Try another search.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'NFC'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('team-DAL')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Start Cowboys quiz →'));
    expect(find.text('Dallas Cowboys challenge'), findsOneWidget);
    expect(find.text('DALLAS COWBOYS'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('answer-0')));
      await tapVisible(
        tester,
        find.text(i == 9 ? 'See results →' : 'Next player →'),
      );
    }
    expect(find.text('Dallas Cowboys • Round complete'), findsOneWidget);
    await tapVisible(tester, find.text('Back to teams'));
    expect(find.text('DYKB / FOOTBALL'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.enterText(find.byType(TextField), 'Steelers');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('team-PIT')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
