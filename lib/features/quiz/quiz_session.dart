import 'dart:math';

import '../roster/player.dart';
import '../roster/roster_repository.dart';

enum QuizDifficulty {
  easy('Easy', 2),
  medium('Medium', 4),
  hard('Hard', 6);

  const QuizDifficulty(this.label, this.optionCount);
  final String label;
  final int optionCount;
}

class QuizQuestion {
  QuizQuestion(this.player, List<Player> options)
    : options = List.unmodifiable(options);
  final Player player;
  final List<Player> options;
}

/// Pure Dart quiz rules, independent of Flutter and data providers.
class QuizSession {
  QuizDifficulty get difficulty => _difficulty;
  QuizDifficulty _difficulty = QuizDifficulty.medium;

  QuizSession.withDifficulty(
    Roster roster, {
    required QuizDifficulty difficulty,
    Random? random,
  }) {
    _difficulty = difficulty;
    final rng = random ?? Random();
    final pool = List<Player>.of(roster.players)..shuffle(rng);
    questions = List.unmodifiable(
      pool.take(10).map((player) {
        final distractors =
            roster.players.where((p) => p.id != player.id).toList()
              ..shuffle(rng);
        final options = [
          player,
          ...distractors.take(difficulty.optionCount - 1),
        ]..shuffle(rng);
        return QuizQuestion(player, options);
      }),
    );
  }

  QuizSession(Roster roster, {Random? random}) {
    final rng = random ?? Random();
    final pool = List<Player>.of(roster.players)..shuffle(rng);
    questions = List.unmodifiable(
      pool.take(10).map((player) {
        final distractors =
            roster.players.where((p) => p.id != player.id).toList()
              ..shuffle(rng);
        final options = [player, ...distractors.take(3)]..shuffle(rng);
        return QuizQuestion(player, options);
      }),
    );
  }
  late final List<QuizQuestion> questions;
  final List<String> _answers = [];
  int _index = 0;
  int _currentStreak = 0;
int _bestStreak = 0;

int get currentStreak => _currentStreak;
int get bestStreak => _bestStreak;
  int get index => _index;
  QuizQuestion get current => questions[_index];
  bool get answered => _answers.length > _index;
  bool get complete => _index == questions.length - 1 && answered;
  String? get selectedId => answered ? _answers[_index] : null;
  List<String> get answers => List.unmodifiable(_answers);
  int get score =>
      Iterable<int>.generate(_answers.length)
          .where((i) => questions[i].player.id == _answers[i])
          .length;
 bool answer(String id) {
  if (answered || !current.options.any((p) => p.id == id)) return false;

  _answers.add(id);

  if (id == current.player.id) {
    _currentStreak++;

    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }
  } else {
    _currentStreak = 0;
  }

  return true;
}

  bool next() {
    if (!answered || complete) return false;
    _index++;
    return true;
  }
}
