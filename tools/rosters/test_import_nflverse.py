import unittest
from import_nflverse import build_rosters

TEAM = {"id":"DAL", "name":"Dallas Cowboys", "file":"dal.json"}


def rows():
    return [{"team":"DAL", "status":"ACT", "season":"2026", "gsis_id":f"id-{i}",
             "full_name":f"Player {i}", "position":"QB", "jersey_number":str(i),
             "headshot_url":"https://static.www.nfl.com/image/upload/player"} for i in range(12)]


class ImportTests(unittest.TestCase):
    def test_filters_non_active_and_other_teams(self):
        data = rows() + [dict(rows()[0], team="NYG"), dict(rows()[0], status="RES")]
        result = build_rosters(data, [TEAM], 2026)["dal.json"]
        self.assertEqual(len(result["players"]), 12)
        self.assertEqual(result["teamId"], "DAL")

    def test_ambiguous_clues_excluded(self):
        data = rows()
        data[1]["jersey_number"] = "0"
        result = build_rosters(data, [TEAM], 2026)["dal.json"]
        self.assertEqual(result["excludedPlayers"], 2)
        self.assertEqual(len(result["players"]), 10)

    def test_bad_photos_fall_back_and_short_rosters_fail(self):
        data = rows()
        data[0]["headshot_url"] = "https://untrusted.example/image.png"
        self.assertIsNone(build_rosters(data, [TEAM], 2026)["dal.json"]["players"][0]["photoUrl"])
        with self.assertRaises(ValueError):
            build_rosters(data[:4], [TEAM], 2026)


if __name__ == '__main__':
    unittest.main()
