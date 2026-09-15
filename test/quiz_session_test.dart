import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:do_you_know_ball/features/roster/roster_repository.dart';
import 'package:do_you_know_ball/features/roster/player.dart';
import 'package:do_you_know_ball/features/quiz/quiz_session.dart';

void main() {
  final json = jsonDecode(
    File('assets/rosters/steelers.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final roster = Roster.fromJson(json);
  test('bundled roster is valid and has 53 active players', () {
    expect(roster.players.length, 53);
    expect(roster.players.singleWhere((p) => p.name == 'T.J. Watt').number, 90);
  });
  test('100 seeded rounds have ten unique players and four valid choices', () {
    final sequences = <String>{};
    for (var seed = 0; seed < 100; seed++) {
      final quiz = QuizSession(roster, random: Random(seed));
      expect(quiz.questions.length, 10);
      expect(quiz.questions.map((q) => q.player.id).toSet().length, 10);
      sequences.add(quiz.questions.map((q) => q.player.id).join(','));
      for (final question in quiz.questions) {
        expect(question.options.map((p) => p.id).toSet().length, 4);
        expect(
          question.options.where((p) => p.id == question.player.id).length,
          1,
        );
        expect(question.options.every(roster.players.contains), isTrue);
      }
    }
    expect(sequences.length, greaterThan(1));
  });
  test(
    'answers lock, invalid choices fail, score and completion are correct',
    () {
      final quiz = QuizSession(roster, random: Random(1));
      expect(quiz.next(), isFalse);
      expect(quiz.answer('invalid-id'), isFalse);
      for (var i = 0; i < 10; i++) {
        final id = i.isEven
            ? quiz.current.player.id
            : quiz.current.options
                  .firstWhere((p) => p.id != quiz.current.player.id)
                  .id;
        expect(quiz.answer(id), isTrue);
        expect(quiz.answer(quiz.current.player.id), isFalse);
        if (i < 9) expect(quiz.next(), isTrue);
      }
      expect(quiz.complete, isTrue);
      expect(quiz.score, 5);
      expect(quiz.next(), isFalse);
      expect(QuizSession(roster).score, 0);
    },
  );
  test('invalid and ambiguous rosters fail before play', () {
    expect(
      () => Roster(team: 'PIT', updated: '', source: '', players: []),
      throwsFormatException,
    );
    expect(
      () => Roster(
        team: 'PIT',
        updated: '',
        source: '',
        players: [...roster.players, roster.players.first],
      ),
      throwsFormatException,
    );
    expect(
      () => Player.fromJson({
        'id': 'x',
        'name': 'X',
        'number': 100,
        'position': 'QB',
      }),
      throwsFormatException,
    );
    expect(
      () => Roster(
        team: 'PIT',
        updated: '',
        source: '',
        players: [
          ...roster.players,
          Player(
            id: 'new',
            name: 'New Player',
            number: roster.players.first.number,
            position: roster.players.first.position,
          ),
        ],
      ),
      throwsFormatException,
    );
  });
}
