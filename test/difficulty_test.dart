import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_you_know_ball/app.dart';
import 'package:do_you_know_ball/features/quiz/quiz_screen.dart';
import 'package:do_you_know_ball/features/quiz/quiz_session.dart';
import 'package:do_you_know_ball/features/roster/roster_repository.dart';

import 'app_test.dart' show TestRosterRepository, tapVisible;

void main() {
  final roster = Roster.fromJson(
    jsonDecode(File('assets/rosters/steelers.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final difficulty in QuizDifficulty.values) {
    test('${difficulty.label} choices and scoring', () {
      final quiz = QuizSession.withDifficulty(
        roster,
        difficulty: difficulty,
        random: Random(42),
      );
      expect(quiz.questions.map((q) => q.player.id).toSet().length, 10);
      for (final question in quiz.questions) {
        expect(
          question.options.map((p) => p.id).toSet().length,
          difficulty.optionCount,
        );
        expect(
          question.options.where((p) => p.id == question.player.id).length,
          1,
        );
        expect(quiz.answer(question.player.id), isTrue);
        expect(quiz.answer(question.player.id), isFalse);
        quiz.next();
      }
      expect(quiz.complete, isTrue);
      expect(quiz.score, 10);
      expect(QuizSession(roster).difficulty, QuizDifficulty.medium);
    });
  }

  for (final difficulty in [QuizDifficulty.easy, QuizDifficulty.hard]) {
    testWidgets('${difficulty.label} selection, completion and replay', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
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
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('team-PIT')));
      await tapVisible(tester, find.text('Start ${difficulty.label} quiz →'));
      expect(find.text('${difficulty.label} difficulty'), findsOneWidget);
      for (var i = 0; i < 10; i++) {
  await tapVisible(
    tester,
    find.byKey(ValueKey('answer-${difficulty.optionCount - 1}')),
  );

  final afterAnswer = tester.takeException();
  if (afterAnswer != null) {
    fail('OVERFLOW AFTER ANSWERING QUESTION ${i + 1}: $afterAnswer');
  }

  await tapVisible(
    tester,
    find.text(i == 9 ? 'See results →' : 'Next player →'),
  );

  final afterNext = tester.takeException();
  if (afterNext != null) {
    fail('OVERFLOW AFTER LEAVING QUESTION ${i + 1}: $afterNext');
  }
}
      await tapVisible(tester, find.text('Play ${difficulty.label} again →'));
      expect(
        tester
            .widget<DifficultyQuizScreen>(find.byType(DifficultyQuizScreen))
            .difficulty,
        difficulty,
      );
      expect(find.text('0 correct'), findsOneWidget);
final exception = tester.takeException();
if (exception != null) {
  debugPrint('ACTUAL FLUTTER ERROR: $exception');
}
expect(tester.takeException(), isNull);  }
}
