# Do You Know Ball?

A Flutter football knowledge app for all 32 NFL teams. Choose a team, identify 10 random players using portraits and jersey clues, and review your score.

## Course submission

| Requirement | Deliverable |
| --- | --- |
| Demo video | **Pending recording.** [Recording outline](docs/demo-video.md) |
| Task list | [Completed and remaining tasks](TASKS.md) |
| Automated build | [GitHub Actions runs](https://github.com/jdugan415/do-you-know-ball/actions/workflows/flutter.yml) |

[![Flutter build](https://github.com/jdugan415/do-you-know-ball/actions/workflows/flutter.yml/badge.svg)](https://github.com/jdugan415/do-you-know-ball/actions/workflows/flutter.yml)

Each push and pull request runs formatting checks, analysis, tests, web compilation, and an Android debug build. To download the APK, open a successful Actions run and select **do-you-know-ball-android** under **Artifacts** (GitHub sign-in may be required). Unzip it to obtain `app-debug.apk`. Artifacts are retained for 30 days; use **Run workflow** to produce a fresh build. This development APK is suitable for demonstration, not a Play Store release.

## Run in Android Studio

1. Open this project folder (the folder containing `pubspec.yaml`), not just `android/`.
2. Enable the Flutter and Dart plugins. Set the Flutter SDK path to your installed Flutter SDK.
3. Run `flutter pub get` in the terminal.
4. Start an Android virtual device in Device Manager or connect an Android phone with USB debugging enabled.
5. Open `lib/main.dart`, select the device, and press Run.

On this computer Flutter is installed at `C:\Users\jackj\develop\flutter`. Until its `bin` folder is on PATH, use this PowerShell form:

```powershell
& 'C:\Users\jackj\develop\flutter\bin\flutter.bat' pub get
& 'C:\Users\jackj\develop\flutter\bin\flutter.bat' run
```

`flutter doctor -v` checks setup. If it reports Android licenses, run `flutter doctor --android-licenses` and review the agreements. A web preview is also supported with `flutter run -d chrome`.

## Version 0.3

- All 32 teams with searchable selection, AFC/NFC filters, and dated roster snapshots.
- 10 distinct random players, four unique same-team choices each.
- Additional Easy (2 choices) and Hard (6 choices) start buttons; the original quiz is Medium. Results offer replay at the selected level or the original Medium round.
- Answers lock after selection; correct answer is shown immediately.
- Score, full answer review, replay, and exit confirmation.
- Offline play; no account, API key, analytics, or backend required.
- Player portraits across all 32 teams with loading and offline fallbacks.
- A validated roster importer and optional published-snapshot refresh.
- Scrollable layouts and accessible answer feedback.

## Project organization

```text
lib/
  main.dart                         Application entry point
  app.dart                          Application configuration
  core/app_theme.dart               Shared visual theme
  features/
    roster/
      player.dart                   Player model, optional photo URL
      roster.dart                   Validated roster model
      roster_api.dart               Published JSON snapshot API
      roster_repository.dart        Asset loading and roster validation
      source_policy.dart            Accepted data and image sources
      widgets/player_portrait.dart  Shared photo with fallback
    teams/
      team.dart                     Team catalog model
      team_screen.dart              Search and conference filters
      team_detail_screen.dart       Selected team and roster updates
    quiz/
      quiz_session.dart             Randomization and scoring rules
      quiz_screen.dart              Question and feedback screen
      results_screen.dart           Score and answer review
assets/teams.json                   Catalog of 32 teams
assets/rosters/                     One JSON snapshot per team
tools/rosters/                      Reproducible importers and their tests
test/                              Rules and screen-flow tests
docs/                              Data and photo-provider research
```

The UI reads a selected team's `Roster` from `RosterRepository`; `QuizSession` operates independently of the data source. Team names, conference, division, accent colors, and filenames live in one catalog. The same quiz and results screens serve every team. API responses must match the selected team's ID and name before use.

The roster refresh button checks the latest reviewed JSON snapshot on GitHub for the selected team. Updates last for the current session; the bundled snapshot loads on the next app launch. Run the importers below, review the diff, run tests, and commit to publish refreshed data:

```sh
python tools/rosters/import_steelers.py
python tools/rosters/import_nflverse.py --season 2026
python -m unittest discover -s tools/rosters -p 'test_*.py'
```

## Data

Steelers data comes from the [official roster](https://www.steelers.com/team/players-roster/). The other 31 teams use the [NFLverse 2026 roster dataset](https://github.com/nflverse/nflverse-data/releases/tag/rosters), filtering to ACT players with usable, unique jersey-number/position clues. Six ambiguous entries were excluded in this import. Some source rosters contain fewer than 53 active players. The bundled snapshots contain 1,678 quiz-ready players and 1,666 photo URLs. Counts describe source data, not a guarantee that every image remains available.

NFLverse data is attributed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). This project filters and transforms its CSV into per-team JSON. Image rights remain with the respective providers. See [data sources](docs/data-sources.md) for provenance and limitations.

Photos are loaded from the NFL/Steelers image host with a neutral fallback. See [photo research](docs/player-photos.md) for rights and provider details.

## Checks

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

GitHub Actions runs the checks and builds described in the course submission section above.

## Next milestones

1. Verify a full round on an Android emulator or phone.
2. Confirm photo permissions for the intended distribution.
3. Automate reviewed roster refreshes.
4. Add saved best scores and optional photo-only difficulty.
5. Replace the generated launcher icons, select a final application ID, and configure release signing before a store release.

Scores and in-progress rounds currently live in memory; closing the app resets them. The generated debug signing configuration is for development, not a Play Store release. This independent fan project is not affiliated with the NFL or Pittsburgh Steelers.

