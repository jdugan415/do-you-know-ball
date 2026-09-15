import 'package:flutter/material.dart';

import '../roster/roster_repository.dart';
import 'daily_challenge.dart';
import 'quiz_screen.dart';
import 'daily_challenge_hero.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key, required this.repository});
  final RosterRepository repository;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daily challenge')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [DailyChallengeCard(repository: repository)],
          ),
        ),
      ),
    ),
  );
}

class DailyChallengeCard extends StatefulWidget {
  const DailyChallengeCard({super.key, required this.repository});
  final RosterRepository repository;

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard> {
  bool _loading = false;
  bool _failed = false;

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final challenge = DailyChallenge(DateTime.now());
    try {
      final teams = await widget.repository.loadTeams();
      final roster = await widget.repository.load(challenge.teamFor(teams));
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DailyQuizScreen(roster: roster, challenge: challenge),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: const Color(0xFF191E1C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: const BorderSide(color: Color(0xFF394538)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DailyChallengeHero(),
          const SizedBox(height: 28),
          const Text(
            'DAILY CHALLENGE',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'One team. Ten players. Medium difficulty. A new challenge every day at midnight UTC.',
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DailyChallengeBadge(
                icon: Icons.sports_football,
                label: '10 players',
              ),
              DailyChallengeBadge(icon: Icons.bolt, label: 'Medium'),
              DailyChallengeBadge(icon: Icons.replay, label: 'Replay anytime'),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading) ...[
            const LinearProgressIndicator(
              minHeight: 3,
              color: Color(0xFFFFC83D),
              backgroundColor: Color(0xFF394538),
            ),
            const SizedBox(height: 12),
          ],
          if (_failed)
            const Text('Could not load the daily challenge. Please try again.'),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              iconSize: 24,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
              backgroundBuilder: (context, states, child) {
                final disabled = states.contains(WidgetState.disabled);
                final pressed = states.contains(WidgetState.pressed);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: disabled
                          ? [const Color(0xFF394538), const Color(0xFF29312B)]
                          : pressed
                          ? [const Color(0xFFFFC83D), const Color(0xFFEBA11A)]
                          : [const Color(0xFFFFE293), const Color(0xFFFFBF2F)],
                    ),
                    border: Border.all(
                      color: disabled
                          ? const Color(0xFF4A554A)
                          : const Color(0xFFFFE8AD),
                    ),
                    boxShadow: disabled || pressed
                        ? []
                        : const [
                            BoxShadow(
                              color: Color(0x28FFC83D),
                              blurRadius: 18,
                              offset: Offset(0, 5),
                            ),
                          ],
                  ),
                  child: child,
                );
              },
              minimumSize: const Size.fromHeight(60),
              elevation: 0,
              backgroundColor: const Color(0xFFFFC83D),
              foregroundColor: const Color(0xFF101213),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _loading ? null : _start,
            icon: const Icon(Icons.today),
            label: Text(
              _loading ? 'Loading challenge…' : 'Play daily challenge →',
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 14, color: Color(0xFFA8B5AC)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Fresh lineup at 00:00 UTC',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFFA8B5AC)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
