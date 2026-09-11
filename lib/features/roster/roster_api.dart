import 'dart:convert';

import 'package:http/http.dart' as http;

import 'roster_repository.dart';

/// Consumes the reviewed public snapshot, not HTML inside the mobile app.
class RosterApi {
  const RosterApi({this.client, this.timeout = const Duration(seconds: 10)});
  final http.Client? client;
  final Duration timeout;
  static final endpoint = Uri.https(
    'raw.githubusercontent.com',
    '/jdugan415/do-you-know-ball/main/assets/rosters/steelers.json',
  );

  Future<Roster> fetchSteelers() async {
    final connection = client ?? http.Client();
    try {
      final response = await connection.get(endpoint).timeout(timeout);
      if (response.statusCode != 200 || response.bodyBytes.length > 250000) {
        throw const FormatException('Roster service unavailable');
      }
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (json['schemaVersion'] != 1 || json['teamId'] != 'PIT') {
        throw const FormatException('Unsupported roster version or team');
      }
      return Roster.fromJson(json);
    } finally {
      if (client == null) connection.close();
    }
  }
}
