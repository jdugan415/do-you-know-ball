import 'package:flutter/material.dart';

import 'features/roster/roster_repository.dart';
import 'features/quiz/quiz_screen.dart';

const gold = Color(0xFFFFC83D);
const ink = Color(0xFF101213);

class BallApp extends StatelessWidget {
  const BallApp({super.key, this.repository = const RosterRepository()});
  final RosterRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Do You Know Ball?',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        onPrimary: ink,
        surface: const Color(0xFF1C1F20),
      ),
      scaffoldBackgroundColor: ink,
      appBarTheme: const AppBarTheme(backgroundColor: ink, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
    home: TeamScreen(repository: repository),
  );
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.repository});
  final RosterRepository repository;
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<Roster> _roster;
  bool _refreshing = false;

  Future<void> _refresh(Roster current) async {
    setState(() => _refreshing = true);
    try {
      final refreshed = await widget.repository.refreshSteelers(current);
      if (!mounted) return;
      setState(() => _roster = Future.value(refreshed));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latest published roster loaded for this session.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Update unavailable. Your current roster is still ready to play.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _roster = widget.repository.loadSteelers();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'DYKB / FOOTBALL',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<Roster>(
            future: _roster,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('The roster could not be loaded.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() {
                          _roster = widget.repository.loadSteelers();
                        }),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final roster = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'THE ROSTER CHALLENGE',
                    style: TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Do you\nknow ball?',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your team. Ten players. Prove you know the roster.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFB8BEBD),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'CHOOSE YOUR TEAM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22251E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: gold),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.sports_football, color: gold, size: 36),
                            Spacer(),
                            Icon(Icons.check_circle, color: gold),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'PITTSBURGH',
                          style: TextStyle(
                            color: gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                        const Text(
                          'Steelers',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${roster.players.length} active players • 10 random questions',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Roster snapshot: ${roster.updated}',
                          style: const TextStyle(
                            color: Color(0xFFB8BEBD),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _refreshing ? null : () => _refresh(roster),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      _refreshing
                          ? 'Checking for updates…'
                          : 'Check roster updates',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizScreen(roster: roster),
                      ),
                    ),
                    child: const Text('Start Steelers quiz →'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use the portrait, jersey number, and position to identify each player. Photos need internet; number and position clues work offline.',
                    style: TextStyle(color: Color(0xFFB8BEBD), height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'More teams coming later.\nIndependent fan project. Not affiliated with the NFL or Steelers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB8BEBD),
                      height: 1.6,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
