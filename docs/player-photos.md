# Player photo and roster research

Research date: September 10, 2026.

## Recommendation

Keep the initial quiz offline with jersey-number/position clues. Use SportsDataIO as the first provider to evaluate for a publicly distributed photo feature because its documentation explicitly describes licensed NFL headshots. Obtain a quote and verify the proposed app use and player coverage before integration. No paid services have been purchased and no provider key is needed for version 0.1.

## Options

| Provider | What it offers | Fit and limitations |
| --- | --- | --- |
| SportsDataIO | NFL headshot endpoint, stable PlayerID, PreferredHostedHeadshotUrl, transparent backgrounds when available | Best candidate for a licensed public app. Headshot access requires contacting sales. Converted action portraits and official studio headshots are distinct offerings; confirm which is included. |
| TheSportsDB | Player search/lookup with image URLs; free and premium tiers | Worth a prototype coverage audit. Name searches can be ambiguous; full team search is restricted on the free tier. Image availability varies. Verify permitted use rather than assuming API access covers every image. |
| NFLverse | Downloadable roster datasets and headshot_url fields | Useful roster/ID candidate. An external image URL is not evidence of a separate photo license or a guarantee of availability. Review upstream providers and freshness before use. |

### Sources

- [SportsDataIO headshot product and access](https://sportsdata.io/developers/sports-player-headshots-api)
- [SportsDataIO NFL field definitions](https://sportsdata.io/developers/data-dictionary/nfl)
- [SportsDataIO authentication and endpoints](https://sportsdata.io/developers/api-documentation/nfl)
- [TheSportsDB API documentation](https://www.thesportsdb.com/documentation)
- [NFLverse data repository](https://github.com/nflverse/nflverse-data)
- [NFLreadr examples showing headshot_url](https://nflreadr.nflverse.com/)
- [Steelers official roster used for the bundled snapshot](https://www.steelers.com/team/players-roster/)

## Live coverage check

A GET to `https://www.thesportsdb.com/api/v1/json/123/searchplayers.php?p=T.J.%20Watt` returned Tony Watt of Partick Thistle, ID 34153648, with a thumbnail and no cutout. This is the wrong sport/player, so it must not be used for the Steelers quiz. This one check does not establish that T.J. Watt is absent from the database; it establishes that naive name matching is insufficient. A broader verified-ID audit is still needed.

## Proposed implementation

1. Maintain an explicit mapping from our stable player IDs to provider IDs. Confirm player name, sport, and roster membership; do not accept the first name-search result.
2. Fetch rosters and image metadata in a small server-side refresh job. Keep paid provider keys in server secrets, never in Dart code, assets, or GitHub. A compiled mobile app cannot keep a shared API key secret.
3. Publish a compact versioned roster containing verified HTTPS photo URLs, source, snapshot date, and image attribution/permission metadata.
4. Let the app load the bundled roster first and cache a validated update. Retain the last valid snapshot if fetching or validation fails. Never update the roster halfway through a round.
5. Display approved photos using `Image.network` with a fixed aspect ratio, a loading placeholder, and a jersey-number fallback on errors. Add Android INTERNET permission when enabling network images. In photo-only mode, skip missing images before selecting ten players, or explicitly fall back to clue mode.
6. Keep quiz-image semantic labels neutral (for example, 'Mystery player') so accessibility text does not reveal the answer. Show names and attribution in the results review.
7. Test missing/broken URLs, offline mode, slow responses, player trades, expired provider access, identity mismatch, and fewer than ten available portraits.

Version 0.1 only adds an optional validated HTTPS `photoUrl` field to the model; there is no live provider integration or photo quiz mode yet.
