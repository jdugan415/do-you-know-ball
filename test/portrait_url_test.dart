import 'dart:convert';
import 'dart:io';

import 'package:do_you_know_ball/features/roster/portrait_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'replaces the low-resolution Steelers crop using the original asset',
    () {
      expect(
        portraitUrl(
          'https://static.clubs.nfl.com/image/upload/'
          't_thumb_squared/f_auto/steelers/i0mgz4emmzmehvg0ogkb.jpg',
        ),
        'https://static.clubs.nfl.com/image/upload/'
        'c_thumb,g_face,z_0.65,w_400,h_400/f_auto,q_auto/'
        'steelers/i0mgz4emmzmehvg0ogkb.jpg',
      );
    },
  );

  test('keeps other providers and unexpected paths intact', () {
    for (final url in [
      'https://a.espncdn.com/i/headshots/nfl/players/full/123.png',
      'https://example.com/image/upload/league/player.png',
      'https://static.www.nfl.com/other/player.png',
    ]) {
      expect(portraitUrl(url), url);
    }
  });

  test(
    'every bundled NFL portrait gets a crop without changing its identity',
    () {
      var checked = 0;
      for (final file in Directory(
        'assets/rosters',
      ).listSync().whereType<File>()) {
        if (!file.path.endsWith('.json')) continue;
        final roster =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        for (final player in roster['players'] as List) {
          final source = player['photoUrl'] as String?;
          if (source == null) continue;
          final original = Uri.parse(source);
          final cropped = Uri.parse(portraitUrl(source));
          expect(cropped.host, original.host);
          expect(cropped.pathSegments[1], original.pathSegments[1]);
          expect(cropped.pathSegments.last, original.pathSegments.last);
          if (original.host.endsWith('.nfl.com')) {
            expect(cropped.path, contains('c_thumb,g_face,z_0.65,w_400,h_400'));
            expect(cropped.path, isNot(contains('t_thumb_squared')));
            expect(portraitUrl(cropped.toString()), cropped.toString());
          }
          checked++;
        }
      }
      expect(checked, greaterThan(1600));
    },
  );
}
