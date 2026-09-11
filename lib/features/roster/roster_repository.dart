import 'dart:convert';

import 'package:flutter/services.dart';

import 'player.dart';
import 'roster_api.dart';

class Roster {
  Roster({
    required this.team,
    required this.updated,
    required this.source,
    required List<Player> players,
  }) : players = List.unmodifiable(players) {
    final date = DateTime.tryParse(updated);
    if (team != 'Pittsburgh Steelers' ||
        source != 'https://www.steelers.com/team/players-roster/' ||
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
        'Roster requires 10 unique players and unambiguous clues',
      );
    }
  }
  final String team;
  String get teamId => team == 'Pittsburgh Steelers' ? 'PIT' : '';
  final String updated;
  final String source;
  final List<Player> players;
  factory Roster.fromJson(Map<String, dynamic> json) => Roster(
    team: json['team'] as String,
    updated: json['updated'] as String,
    source: json['source'] as String,
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

class RosterRepository {
  const RosterRepository({this.api = const RosterApi()});
  final RosterApi api;
  Future<Roster> refreshSteelers(Roster current) async {
    final refreshed = await api.fetchSteelers();
    if (DateTime.parse(refreshed.updated)
        .isBefore(DateTime.parse(current.updated))) {
      throw const FormatException('Received an older roster');
    }
    return refreshed;
  }

  Future<Roster> loadSteelers() async => Roster.fromJson(
    jsonDecode(await rootBundle.loadString('assets/rosters/steelers.json'))
        as Map<String, dynamic>,
  );
}
