import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:do_you_know_ball/features/roster/roster_api.dart';

Map<String, dynamic> validRoster() => {
  'schemaVersion': 1,
  'team': 'Pittsburgh Steelers',
  'teamId': 'PIT',
  'updated': '2026-09-10',
  'source': 'https://www.steelers.com/team/players-roster/',
  'players': List.generate(
    10,
    (i) => {
      'id': 'player-$i',
      'name': 'Player $i',
      'number': i,
      'position': 'P$i',
      'photoUrl': null,
    },
  ),
};

void main() {
  test('fetches and validates the published roster snapshot', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode(validRoster()),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final roster = await const RosterApi()
        .copyWith(client: client)
        .fetchSteelers();
    expect(roster.teamId, 'PIT');
    expect(roster.players.length, 10);
  });

  test('rejects service failures and invalid team payloads', () async {
    for (final response in [
      http.Response('offline', 503),
      http.Response(jsonEncode({...validRoster(), 'teamId': 'GB'}), 200),
      http.Response(jsonEncode({...validRoster(), 'players': []}), 200),
    ]) {
      final client = MockClient((request) async => response);
      expect(
        () => const RosterApi().copyWith(client: client).fetchSteelers(),
        throwsFormatException,
      );
    }
  });
}

extension on RosterApi {
  RosterApi copyWith({http.Client? client}) =>
      RosterApi(client: client ?? this.client, timeout: timeout);
}
