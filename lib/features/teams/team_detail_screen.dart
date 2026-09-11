import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../quiz/quiz_screen.dart';
import '../roster/roster_repository.dart';
import 'team.dart';

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({
    super.key,
    required this.team,
    required this.repository,
  });
  final NflTeam team;
  final RosterRepository repository;
  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late Future<Roster> _roster;
  bool _refreshing = false;
  @override
  void initState() {
    super.initState();
    _roster = widget.repository.load(widget.team);
  }

  Future<void> _refresh(Roster current) async {
    setState(() => _refreshing = true);
    try {
      final next = await widget.repository.refresh(widget.team, current);
      if (!mounted) return;
      setState(() => _roster = Future.value(next));
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.team.name)),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<Roster>(
            future: _roster,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return TextButton(
                  onPressed: () => setState(() {
                    _roster = widget.repository.load(widget.team);
                  }),
                  child: const Text('Could not load this roster. Try again'),
                );
              }
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final roster = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Icon(
                    Icons.sports_football,
                    color: Color(widget.team.color),
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.team.nickname,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${widget.team.conference} ${widget.team.division}',
                    style: const TextStyle(color: gold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${roster.players.length} quiz-ready players • 10 random questions',
                  ),
                  const SizedBox(height: 8),
                  Text('Roster snapshot: ${roster.updated}'),
                  const SizedBox(height: 8),
                  Text(
                    roster.source.contains('nflverse')
                        ? 'Roster data: NFLverse • CC BY 4.0'
                        : 'Roster data: Steelers.com',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB8BEBD),
                    ),
                  ),
                  if (roster.excludedPlayers > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${roster.excludedPlayers} players excluded because their clues were missing or ambiguous.',
                        style: const TextStyle(fontSize: 12),
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
                    child: Text('Start ${widget.team.nickname} quiz →'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use the portrait, jersey number, and position to identify each player. Photos need internet; number and position clues work offline.',
                    style: TextStyle(color: Color(0xFFB8BEBD), height: 1.6),
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
