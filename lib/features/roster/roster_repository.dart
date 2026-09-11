import 'dart:convert';

import 'package:flutter/services.dart';

import 'roster_api.dart';
import 'roster.dart';
import '../teams/team.dart';
export 'roster.dart';

class RosterRepository {
  const RosterRepository({this.api = const RosterApi()});
  final RosterApi api;
  Future<List<NflTeam>> loadTeams() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/teams.json')) as List;
    final teams = data
        .map((t) => NflTeam.fromJson(t as Map<String, dynamic>))
        .toList();
    if (teams.length != 32 || teams.map((t) => t.id).toSet().length != 32) {
      throw const FormatException('Expected all 32 NFL teams');
    }
    return List.unmodifiable(teams);
  }

  Future<Roster> refresh(NflTeam team, Roster current) async {
    final refreshed = await api.fetch(team);
    if (DateTime.parse(refreshed.updated)
        .isBefore(DateTime.parse(current.updated))) {
      throw const FormatException('Received an older roster');
    }
    return refreshed;
  }

  Future<Roster> load(NflTeam team) async {
    final roster = Roster.fromJson(
      jsonDecode(await rootBundle.loadString('assets/rosters/${team.file}'))
          as Map<String, dynamic>,
    );
    if (roster.teamId != team.id || roster.team != team.name) {
      throw const FormatException('Roster does not match selected team');
    }
    return roster;
  }
}
