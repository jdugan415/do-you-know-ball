import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_you_know_ball/app.dart';
import 'package:do_you_know_ball/features/quiz/daily_challenge.dart';
import 'package:do_you_know_ball/features/quiz/quiz_screen.dart';
import 'package:do_you_know_ball/features/quiz/quiz_session.dart';
import 'package:do_you_know_ball/features/roster/roster_repository.dart';
import 'package:do_you_know_ball/features/teams/team.dart';

import 'app_test.dart' show TestRosterRepository, tapVisible;

List<List<String>> signature(QuizSession session) => [
  for (final q in session.questions)
    [q.player.id, ...q.options.map((p) => p.id)],
];

void main() {
  testWidgets(
    'gift entry is visible immediately and opens the daily challenge',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(BallApp(repository: TestRosterRepository()));
      await tester.pumpAndSettle();
      final banner = find.byKey(const ValueKey('daily-gift-banner'));
      expect(tester.getBottomRight(banner).dy, lessThan(640));
      expect(find.text('Open daily challenge').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Open daily challenge'));
      await tester.pumpAndSettle();
      expect(find.text('Play daily challenge →'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  test('UTC boundary changes the day and rotates the team', () async {
    final before = DailyChallenge(DateTime.parse('2026-09-15T18:59:59-05:00'));
    final after = DailyChallenge(DateTime.parse('2026-09-15T19:00:00-05:00'));
    expect(before.label, '2026-09-15');
    expect(after.label, '2026-09-16');
    final teams = await TestRosterRepository().loadTeams();
    expect(
      before.teamFor(teams).id,
      before.teamFor(teams.reversed.toList()).id,
    );
    expect(after.teamFor(teams).id, isNot(before.teamFor(teams).id));
    expect(() => before.teamFor([]), throwsFormatException);
  });

  test('same date repeats questions regardless of source order', () async {
    final repository = TestRosterRepository();
    final teams = await repository.loadTeams();
    final day = DailyChallenge(DateTime.utc(2026, 9, 15));
    final roster = await repository.load(day.teamFor(teams));
    final reordered = Roster(
      team: roster.team,
      teamId: roster.teamId,
      updated: roster.updated,
      source: roster.source,
      players: roster.players.reversed.toList(),
    );
    final first = DailyQuizSession(roster, day);
    final later = DailyQuizSession(
      reordered,
      DailyChallenge(DateTime.utc(2026, 9, 15, 23, 59)),
    );
    expect(signature(first), signature(later));
    expect(
      signature(first),
      isNot(
        signature(
          DailyQuizSession(roster, DailyChallenge(DateTime.utc(2026, 9, 16))),
        ),
      ),
    );
    expect(first.questions.map((q) => q.player.id).toSet().length, 10);
    expect(first.difficulty, QuizDifficulty.medium);
    for (final question in first.questions) {
      expect(question.options.map((p) => p.id).toSet().length, 4);
      expect(first.answer(question.player.id), isTrue);
      expect(first.answer(question.player.id), isFalse);
      first.next();
    }
    expect(first.complete, isTrue);
    expect(first.score, 10);
  });

  testWidgets('daily round completes, replays the same day, and exits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(BallApp(repository: TestRosterRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Daily challenge'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Play daily challenge →'));
    final screen = tester.widget<DailyQuizScreen>(find.byType(DailyQuizScreen));
    final label = 'Daily challenge • ${screen.challenge.label} UTC';
    expect(find.text(label), findsOneWidget);
    final original = signature(
      DailyQuizSession(screen.roster, screen.challenge),
    );
    for (var i = 0; i < 10; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('answer-0')));
      await tapVisible(
        tester,
        find.text(i == 9 ? 'See results →' : 'Next player →'),
      );
    }
    expect(find.text(label), findsOneWidget);
    await tapVisible(tester, find.text('Replay this daily challenge →'));
    final replay = tester.widget<DailyQuizScreen>(find.byType(DailyQuizScreen));
    expect(
      signature(DailyQuizSession(replay.roster, replay.challenge)),
      original,
    );
    expect(find.text('0 correct'), findsOneWidget);
    await tester.tap(find.byTooltip('Leave quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Play daily challenge →'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed daily load can be retried', (tester) async {
    await tester.pumpWidget(BallApp(repository: RetryDailyRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Daily challenge'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Play daily challenge →'));
    expect(
      find.text('Could not load the daily challenge. Please try again.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Play daily challenge →'));
    expect(find.byType(DailyQuizScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class RetryDailyRepository extends TestRosterRepository {
  bool fail = true;

  @override
  Future<Roster> load(NflTeam team) {
    if (fail) {
      fail = false;
      return Future.error(StateError('Unavailable'));
    }
    return super.load(team);
  }
}
