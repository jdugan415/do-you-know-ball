"""Import all non-Steelers teams from one current-season NFLverse CSV.

Only ACT players with valid number/position clues are eligible. All teams are
validated before any files are written. Steelers retain their official-site importer.
"""
import argparse
from collections import Counter
import csv
from datetime import date
import io
import json
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
BASE = "https://github.com/nflverse/nflverse-data/releases/download/rosters"
PHOTO_HOSTS = {"static.www.nfl.com", "static.clubs.nfl.com", "a.espncdn.com"}


def build_rosters(rows, teams, season, updated=None):
    output = {}
    for team in teams:
        if team["id"] == "PIT":
            continue
        eligible = [r for r in rows if r["team"] == team["id"] and
                    r["status"] == "ACT" and r["season"] == str(season)]
        players = []
        skipped = 0
        for row in eligible:
            number = row.get("jersey_number", "")
            position = row.get("position", "").strip()
            name = row.get("full_name", "").strip()
            identity = row.get("gsis_id", "").strip()
            if not number.isdigit() or not 0 <= int(number) <= 99 or not position or not name or not identity:
                skipped += 1
                continue
            photo = row.get("headshot_url", "")
            parsed = urlparse(photo)
            if parsed.scheme != "https" or parsed.hostname not in PHOTO_HOSTS:
                photo = None
            players.append({"id": identity, "name": name, "number": int(number),
                            "position": position, "photoUrl": photo,
                            "sourceUrl": f"{BASE}/roster_{season}.csv",
                            "photoCredit": "Photo: NFL / source via NFLverse" if photo else None})
        # A number+position question must identify only one player.
        clues = Counter((p["number"], p["position"]) for p in players)
        unique = [p for p in players if clues[p["number"], p["position"]] == 1]
        skipped += len(players) - len(unique)
        players = sorted(unique, key=lambda p: p["name"])
        if not 10 <= len(players) <= 100:
            raise ValueError(f"{team['id']}: insufficient valid active players ({len(players)})")
        if len({p['id'] for p in players}) != len(players) or len({p['name'] for p in players}) != len(players):
            raise ValueError(f"{team['id']}: duplicate identity")
        output[team["file"]] = {"schemaVersion": 1, "teamId": team["id"],
            "team": team["name"], "updated": updated or date.today().isoformat(),
            "source": f"{BASE}/roster_{season}.csv", "season": season,
            "scope": "NFLverse ACT players with valid, unique number/position clues",
            "excludedPlayers": skipped,
            "dataCredit": "NFLverse roster data, CC BY 4.0; filtered and transformed for this quiz",
            "players": players}
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--season', type=int, default=date.today().year)
    parser.add_argument('--csv', type=Path, help='Use local CSV for reproducible offline imports')
    args = parser.parse_args()
    if args.csv:
        content = args.csv.read_text(encoding='utf-8-sig')
    else:
        request = Request(f'{BASE}/roster_{args.season}.csv', headers={
            'User-Agent': 'DoYouKnowBallRoster/0.3 (github.com/jdugan415/do-you-know-ball)'})
        with urlopen(request, timeout=30) as response:
            body = response.read(10_000_001)
            if len(body) > 10_000_000:
                raise ValueError('Dataset exceeds expected size')
            content = body.decode('utf-8-sig')
    teams = json.loads((ROOT / 'assets/teams.json').read_text(encoding='utf-8'))
    if len(teams) != 32 or len({t['id'] for t in teams}) != 32:
        raise ValueError('Expected 32 unique teams')
    rosters = build_rosters(list(csv.DictReader(io.StringIO(content))), teams, args.season)
    for filename, roster in rosters.items():
        target = ROOT / 'assets/rosters' / filename
        temporary = target.with_suffix('.json.tmp')
        temporary.write_text(json.dumps(roster, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
        temporary.replace(target)
        print(f"{roster['teamId']}: {len(roster['players'])} players, "
              f"{sum(bool(p['photoUrl']) for p in roster['players'])} photos, "
              f"{roster['excludedPlayers']} excluded")


if __name__ == '__main__':
    main()
