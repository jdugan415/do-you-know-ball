class NflTeam {
  const NflTeam({
    required this.id,
    required this.name,
    required this.nickname,
    required this.conference,
    required this.division,
    required this.color,
    required this.file,
  });
  final String id, name, nickname, conference, division, file;
  final int color;
  factory NflTeam.fromJson(Map<String, dynamic> json) {
    final file = json['file'] as String;
    if (!RegExp(r'^[a-z]+\.json$').hasMatch(file)) {
      throw const FormatException('Invalid roster filename');
    }
    return NflTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      conference: json['conference'] as String,
      division: json['division'] as String,
      color: int.parse('FF${json['color']}', radix: 16),
      file: file,
    );
  }
}
