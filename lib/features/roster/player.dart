import 'source_policy.dart';

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    this.photoUrl,
    this.sourceUrl,
    this.photoCredit,
  });
  final String id;
  final String name;
  final int number;
  final String position;

  /// Source-hosted portrait; see docs/player-photos.md for usage limitations.
  final String? photoUrl;
  final String? sourceUrl;
  final String? photoCredit;

  factory Player.fromJson(Map<String, dynamic> json) {
    final player = Player(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      position: json['position'] as String,
      photoUrl: json['photoUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      photoCredit: json['photoCredit'] as String?,
    );
    if (player.id.isEmpty ||
        player.name.trim().isEmpty ||
        player.position.isEmpty ||
        player.number < 0 ||
        player.number > 99) {
      throw const FormatException('Invalid player data');
    }
    if (player.photoUrl != null &&
        (Uri.tryParse(player.photoUrl!)?.scheme != 'https' ||
            !{
              'static.clubs.nfl.com',
              'static.www.nfl.com',
              'a.espncdn.com',
            }.contains(Uri.tryParse(player.photoUrl!)?.host))) {
      throw const FormatException(
        'Player photos must use the approved NFL HTTPS host',
      );
    }
    if (player.sourceUrl != null && !isPlayerSource(player.sourceUrl!)) {
      throw const FormatException('Unrecognized player source');
    }
    if (player.photoUrl != null &&
        (player.sourceUrl == null ||
            player.photoCredit == null ||
            player.photoCredit!.trim().isEmpty)) {
      throw const FormatException('Photo source and credit required');
    }
    return player;
  }
}
