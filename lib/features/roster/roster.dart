import 'player.dart';
import 'source_policy.dart';

class Roster {
  Roster({
    required this.team,
    this.teamId = 'PIT',
    required this.updated,
    required this.source,
    required List<Player> players,
    this.scope = 'Active roster snapshot',
    this.excludedPlayers = 0,
  }) : players = List.unmodifiable(players) {
    final date = DateTime.tryParse(updated);
    if (team.trim().isEmpty ||
        !RegExp(r'^[A-Z]{2,3}$').hasMatch(teamId) ||
        !isRosterSource(source) ||
        date == null ||
        date.toIso8601String().substring(0, 10) != updated ||
        date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const FormatException(
        'Invalid roster identity, source or snapshot date',
      );
    }
    if (players.length < 10 ||
        players.length > 100 ||
        players.map((p) => p.id).toSet().length != players.length ||
        players.map((p) => p.name).toSet().length != players.length ||
        players.map((p) => '${p.number}:${p.position}').toSet().length !=
            players.length) {
      throw const FormatException(
        'Roster requires unique players and unambiguous clues',
      );
    }
  }
  final String team, teamId, updated, source, scope;
  final int excludedPlayers;
  final List<Player> players;
  factory Roster.fromJson(Map<String, dynamic> json) => Roster(
    team: json['team'] as String,
    teamId: json['teamId'] as String,
    updated: json['updated'] as String,
    source: json['source'] as String,
    scope: json['scope'] as String? ?? 'Active roster snapshot',
    excludedPlayers: json['excludedPlayers'] as int? ?? 0,
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}
