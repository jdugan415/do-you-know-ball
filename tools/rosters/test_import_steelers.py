import unittest
from import_steelers import parse_roster


def table(caption="Active", count=12):
    rows = "".join(f'<tr><td><a href="/team/players-roster/player-{i}/">Player {i}</a>'
                   f'<img src="https://static.clubs.nfl.com/image/upload/t_lazy/player{i}.jpg"></td>'
                   f'<td>{i}</td><td>QB</td></tr>' for i in range(count))
    return f'<table><caption>{caption}</caption><tbody>{rows}</tbody></table>'


class ImportTests(unittest.TestCase):
    def test_active_only_and_photo_identity(self):
        roster = parse_roster(table() + table("Practice Squad"))
        self.assertEqual(len(roster["players"]), 12)
        self.assertEqual(roster["players"][0]["photoUrl"],
                         "https://static.clubs.nfl.com/image/upload/player0.jpg")
        self.assertTrue(roster["players"][0]["sourceUrl"].endswith("player-0/"))

    def test_preserve_existing_ids(self):
        old = {"players": [{"id": "stable-provider-id", "name": "Player 0"}]}
        self.assertEqual(parse_roster(table(), old)["players"][0]["id"], "stable-provider-id")

    def test_changed_markup_and_incomplete_data_fail(self):
        for html in ("<html>Blocked</html>", table("Practice Squad"), table(count=3),
                     table() + table(), table().replace("<td>1</td>", "<td>0</td>")):
            with self.subTest(html=html[:30]), self.assertRaises(ValueError):
                parse_roster(html)

    def test_missing_photo_keeps_player(self):
        html = table().replace('src="https://static.clubs.nfl.com/', 'src="https://other.example/')
        self.assertTrue(all(p["photoUrl"] is None for p in parse_roster(html)["players"]))


if __name__ == "__main__":
    unittest.main()
