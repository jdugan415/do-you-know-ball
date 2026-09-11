bool isRosterSource(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.userInfo.isNotEmpty) {
    return false;
  }
  return value == 'https://www.steelers.com/team/players-roster/' ||
      (uri.host == 'github.com' &&
          RegExp(
            r'^/nflverse/nflverse-data/releases/download/rosters/roster_\d{4}\.csv$',
          ).hasMatch(uri.path));
}

bool isPlayerSource(String value) {
  final uri = Uri.tryParse(value);
  return isRosterSource(value) ||
      (uri != null &&
          uri.scheme == 'https' &&
          uri.host == 'www.steelers.com' &&
          uri.path.startsWith('/team/players-roster/'));
}
