# Do You Know Ball?

A Flutter football knowledge app. Choose Pittsburgh, identify 10 random active players by jersey number and position, and review your score.

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

## Version 0.1

- Steelers selection card with dated roster snapshot.
- 10 distinct random players, four unique same-team choices each.
- Answers lock after selection; correct answer is shown immediately.
- Score, full answer review, replay, and exit confirmation.
- Offline play; no account, API key, analytics, or backend required.
- Scrollable layouts and accessible answer feedback.

## Project organization

```text
lib/
  main.dart                         Application entry point
  app.dart                          Theme and team selection
  features/
    roster/
      player.dart                   Player model, optional photo URL
      roster_repository.dart        Asset loading and roster validation
    quiz/
      quiz_session.dart             Randomization and scoring rules
      quiz_screen.dart              Question and feedback screen
      results_screen.dart           Score and answer review
assets/rosters/steelers.json         Verified roster snapshot
test/                              Rules and screen-flow tests
docs/                              Data and photo-provider research
```

The UI reads a `Roster` from `RosterRepository`; `QuizSession` operates on that roster independently of the data source. To add a team, provide the same JSON schema, add it to `pubspec.yaml`, expose its repository loader, and add a selection card. Replace Steelers-specific screen copy when expanding beyond this first team.

## Data

The 53 active players were transcribed from the [official Steelers roster](https://www.steelers.com/team/players-roster/) on September 10, 2026. Reserve and practice squad players are excluded. This is a dated snapshot, not a live roster feed. Before refreshing, verify team membership, jersey numbers, and positions; preserve IDs and update the snapshot date. Validation rejects duplicate players and ambiguous number/position clues.

Photos are not bundled or displayed in this version. The optional `photoUrl` model field is ready for a future verified source. See [photo research](docs/player-photos.md).

## Checks

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

GitHub Actions runs formatting, analysis, tests, and web compilation on pushes and pull requests.

## Next milestones

1. Verify a full round on an Android emulator or phone.
2. Integrate a photo source after confirming Steelers coverage and permitted use.
3. Add more teams and a scheduled roster refresh pipeline.
4. Add saved best scores and optional photo-only difficulty.
5. Replace the generated launcher icons, select a final application ID, and configure release signing before a store release.

Scores and in-progress rounds currently live in memory; closing the app resets them. The generated debug signing configuration is for development, not a Play Store release. This independent fan project is not affiliated with the NFL or Pittsburgh Steelers.

