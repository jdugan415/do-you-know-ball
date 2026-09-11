"""Import only the Active table from Steelers.com. Python standard library only.

Run from any directory: python tools/rosters/import_steelers.py
The site is fetched once (plus robots.txt); player profile pages are not crawled.
"""
import argparse
from datetime import date
from html.parser import HTMLParser
import json
from pathlib import Path
import re
from urllib.parse import urljoin, urlparse
from urllib.request import Request, urlopen
from urllib.robotparser import RobotFileParser

SOURCE = "https://www.steelers.com/team/players-roster/"
ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/rosters/steelers.json"
AGENT = "DoYouKnowBallRoster/0.2 (+https://github.com/jdugan415/do-you-know-ball)"


class RosterParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tables = []
        self.table = None
        self.row = None
        self.cell = None
        self.caption = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "table":
            self.table = {"caption": "", "rows": []}
        if self.table is None:
            return
        if tag == "caption":
            self.caption = True
        elif tag == "tr":
            self.row = {"cells": [], "sourceUrl": None, "photoUrl": None}
        elif tag == "td" and self.row is not None:
            self.cell = ""
        elif tag == "a" and self.cell is not None:
            href = attrs.get("href", "")
            if href.startswith("/team/players-roster/"):
                self.row["sourceUrl"] = urljoin(SOURCE, href)
        elif tag == "img" and self.cell is not None:
            src = attrs.get("src", "")
            if urlparse(src).hostname == "static.clubs.nfl.com":
                # The site's lazy-loading transform is a placeholder.
                self.row["photoUrl"] = src.replace("/t_lazy/", "/")

    def handle_data(self, data):
        if self.caption and self.table is not None:
            self.table["caption"] += data
        if self.cell is not None:
            self.cell += data

    def handle_endtag(self, tag):
        if tag == "caption":
            self.caption = False
        elif tag == "td" and self.cell is not None:
            self.row["cells"].append(" ".join(self.cell.split()))
            self.cell = None
        elif tag == "tr" and self.row is not None:
            if self.row["cells"]:
                self.table["rows"].append(self.row)
            self.row = None
        elif tag == "table" and self.table is not None:
            self.tables.append(self.table)
            self.table = None


def parse_roster(html, previous=None, updated=None):
    parser = RosterParser()
    parser.feed(html)
    tables = [t for t in parser.tables if t["caption"].strip() == "Active"]
    if len(tables) != 1:
        raise ValueError("Expected exactly one Active roster table; keeping old snapshot")
    old_ids = {p["name"]: p["id"] for p in (previous or {}).get("players", [])}
    players = []
    for row in tables[0]["rows"]:
        cells = row["cells"]
        if len(cells) < 3 or not cells[1].isdigit():
            raise ValueError("Incomplete player row; keeping old snapshot")
        name, number, position = cells[0], int(cells[1]), cells[2]
        if not name or not position or not 0 <= number <= 99 or not row["sourceUrl"]:
            raise ValueError("Invalid player identity or clue")
        players.append({
            "id": old_ids.get(name, re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")),
            "name": name, "number": number, "position": position,
            "photoUrl": row["photoUrl"], "sourceUrl": row["sourceUrl"],
            "photoCredit": "Photo: Pittsburgh Steelers / NFL" if row["photoUrl"] else None,
        })
    if not 10 <= len(players) <= 100:
        raise ValueError("Unexpected active roster size")
    for values in ([p["id"] for p in players], [p["name"] for p in players],
                   [(p["number"], p["position"]) for p in players]):
        if len(values) != len(set(values)):
            raise ValueError("Duplicate players or ambiguous clues")
    return {"schemaVersion": 1, "team": "Pittsburgh Steelers", "teamId": "PIT",
            "updated": updated or date.today().isoformat(), "source": SOURCE,
            "scope": "Active section only; excludes reserve and practice squad",
            "players": players}


def fetch(url):
    with urlopen(Request(url, headers={"User-Agent": AGENT}), timeout=20) as response:
        body = response.read(5_000_001)
        if len(body) > 5_000_000:
            raise ValueError("Source response exceeded size limit")
        return body.decode("utf-8")


def main():
    args = argparse.ArgumentParser(description=__doc__)
    args.add_argument("--html", type=Path, help="Parse a saved HTML page without network access")
    args.add_argument("--output", type=Path, default=OUTPUT)
    options = args.parse_args()
    if options.html:
        html = options.html.read_text(encoding="utf-8-sig")
    else:
        robots = RobotFileParser()
        robots.parse(fetch("https://www.steelers.com/robots.txt").splitlines())
        if not robots.can_fetch(AGENT, SOURCE):
            raise ValueError("The site's robots policy does not allow this fetch")
        html = fetch(SOURCE)
    previous = json.loads(options.output.read_text(encoding="utf-8-sig")) if options.output.exists() else None
    roster = parse_roster(html, previous)
    options.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = options.output.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(roster, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    temporary.replace(options.output)
    print(f"Saved {len(roster['players'])} active players; "
          f"{sum(bool(p['photoUrl']) for p in roster['players'])} photo URLs to {options.output}")


if __name__ == "__main__":
    main()
