# Player photo and roster research

Research date: September 10, 2026.

Version 0.3 update: all 32 teams now use the shared portrait widget. The Steelers retain official-site image URLs; the other teams use headshot URLs associated with player IDs in NFLverse's 2026 roster data. The importer and app accept only HTTPS images from `static.clubs.nfl.com`, `static.www.nfl.com`, or `a.espncdn.com`. Twelve players have no accepted photo URL. See [data sources](data-sources.md) for the per-team import process and attribution. The provider evaluation below records the earlier research; no paid photo service is integrated.

## Portrait framing

All quiz and results portraits share `PlayerPortrait`. NFL-hosted images request a 400px square from the original asset with `c_thumb,g_face,z_0.65`: face detection centers the subject, with a looser crop to retain hair and shoulders. Existing low-resolution thumbnail transforms are removed. See [Cloudinary face-focused cropping](https://cloudinary.com/documentation/image_gravity). The source URL and attribution remain unchanged in roster data.

If a transformed image fails, the widget retries the original URL, then shows the placeholder. Other hosts keep their original image with a centered square crop. Face detection can vary by source photo; this is a shared automatic framing rule, not a manual review of every player.

## Provider recommendation

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

## Implemented in version 0.2

- `tools/rosters/import_steelers.py` fetches one Active table from Steelers.com, honors its `robots.txt`, rejects changed or incomplete markup, preserves stable IDs, and writes a temporary file before replacing the snapshot.
- The checked-in snapshot now has 53 official NFL-hosted portrait URLs plus the individual Steelers profile URL and a visible credit string for each player.
- `RosterApi` retrieves only the reviewed JSON snapshot published in this repository. The app keeps its bundled snapshot when GitHub is unavailable and never scrapes HTML inside the mobile app.
- Portraits use fixed dimensions, loading placeholders, and a fallback icon. Broken images do not prevent the number/position quiz from working.

The portrait URLs are reachable and source-hosted, but availability does not automatically grant permission for every kind of distribution. Before monetizing or publishing broadly, confirm NFL/Steelers image rights or obtain licensed headshots from SportsDataIO. A public fan project should retain attribution and be prepared to remove images if the rights holder requests it.
