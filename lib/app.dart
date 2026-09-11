import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/roster/roster_repository.dart';
import 'features/teams/team_screen.dart';

class BallApp extends StatelessWidget {
  const BallApp({super.key, this.repository = const RosterRepository()});
  final RosterRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Do You Know Ball?',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    home: TeamScreen(repository: repository),
  );
}
