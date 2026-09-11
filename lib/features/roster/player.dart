class Player {
  const Player({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    this.photoUrl,
  });
  final String id;
  final String name;
  final int number;
  final String position;

  /// Only populate with a verified, permitted HTTPS image URL.
  final String? photoUrl;

  factory Player.fromJson(Map<String, dynamic> json) {
    final player = Player(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      position: json['position'] as String,
      photoUrl: json['photoUrl'] as String?,
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
            Uri.tryParse(player.photoUrl!)?.host.isEmpty != false)) {
      throw const FormatException('Player photos must use HTTPS');
    }
    return player;
  }
}
