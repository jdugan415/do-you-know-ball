# Roster provenance

Version 0.3 includes a separate snapshot for all 32 teams in `assets/rosters/`, indexed by `assets/teams.json`. Snapshot dates mean the date of import, not an assurance that the upstream provider updated every record on that date.

## Steelers

The existing [official Steelers roster](https://www.steelers.com/team/players-roster/) importer reads only the Active table and preserves its player/profile/photo associations. It runs manually and checks robots.txt. The existing `steelers.json` filename and player IDs remain stable.

## Other 31 teams

Source: [NFLverse roster release](https://github.com/nflverse/nflverse-data/releases/tag/rosters), `roster_2026.csv`. [Schema and seasonal scope](https://nflreadr.nflverse.com/reference/load_rosters.html).

Attribution: NFLverse contributors, roster data under [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/). Changes made by this project: filter to season 2026 and status ACT, retain quiz fields and existing headshot URLs, group by team, exclude incomplete/ambiguous clues, and serialize to JSON. Photos are external resources and are not covered merely by the dataset's license.

`tools/rosters/import_nflverse.py` makes one dataset request, validates every non-Steelers team before writing any snapshots, and keeps provider player IDs. Each snapshot documents the source, season, eligibility rule, import date, and excluded count. Use `--csv <file>` to reproduce an import offline. Failure to fetch does not overwrite existing snapshots.

The current import has 1,678 quiz-ready players and 1,666 photo URLs. Las Vegas has two ambiguous entries excluded; Tennessee has four. Twelve players have no accepted photo URL and use the built-in fallback. ACT counts vary by team; this is not a live transaction or game-day availability feed. Portraits may depict older uniforms.

NFLverse uses `LA` for the Rams and `LAC` for the Chargers. The catalog intentionally follows these IDs.

## In-app updates

The refresh button requests the selected team's published JSON from this GitHub repository. It rejects wrong-team, invalid-schema, stale-date, or invalid-source responses. Failed updates preserve the existing roster. A running quiz holds its original roster throughout the round. Updates are session-only; restart loads the bundled snapshot. Publishing a new importer output requires review and a Git commit, so the button does not imply a direct real-time refresh from the NFL.
