import 'dart:convert';

import 'package:flutter/services.dart';

import 'player.dart';

class Roster {
  Roster({
    required this.team,
    required this.updated,
    required this.source,
    required List<Player> players,
  }) : players = List.unmodifiable(players) {
    if (players.length < 10 ||
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
  const RosterRepository();
  Future<Roster> loadSteelers() async => Roster.fromJson(
    jsonDecode(await rootBundle.loadString('assets/rosters/steelers.json'))
        as Map<String, dynamic>,
  );
}
