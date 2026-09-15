import 'dart:math';

import '../roster/roster_repository.dart';
import '../teams/team.dart';
import 'quiz_session.dart';

/// A UTC calendar day keeps the challenge consistent across time zones.
class DailyChallenge {
  DailyChallenge(DateTime now)
    : date = DateTime.utc(now.toUtc().year, now.toUtc().month, now.toUtc().day);

  final DateTime date;
  String get label => date.toIso8601String().substring(0, 10);
  int get seed => date.year * 10000 + date.month * 100 + date.day;

  NflTeam teamFor(List<NflTeam> teams) {
    if (teams.isEmpty) throw const FormatException('No teams available');
    final sorted = List<NflTeam>.of(teams)
      ..sort((a, b) => a.id.compareTo(b.id));
    final day = date.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    return sorted[day % sorted.length];
  }
}

class DailyQuizSession extends QuizSession {
  DailyQuizSession(Roster roster, this.challenge)
    : super(_orderedRoster(roster), random: Random(challenge.seed));

  final DailyChallenge challenge;

  // Source ordering must not change the day's questions or answer order.
  static Roster _orderedRoster(Roster roster) => Roster(
    team: roster.team,
    teamId: roster.teamId,
    updated: roster.updated,
    source: roster.source,
    scope: roster.scope,
    excludedPlayers: roster.excludedPlayers,
    players: List.of(roster.players)..sort((a, b) => a.id.compareTo(b.id)),
  );
}
