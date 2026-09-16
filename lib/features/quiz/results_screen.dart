import 'package:flutter/material.dart';

import '../../core/app_theme.dart' show gold;
import '../roster/roster_repository.dart';
import '../roster/widgets/player_portrait.dart';
import 'quiz_screen.dart';
import 'quiz_session.dart';
import 'daily_challenge.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.roster, required this.session});
  final Roster roster;
  final QuizSession session;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The final whistle')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.emoji_events_outlined, size: 56, color: gold),
              const SizedBox(height: 12),
              Text(
                '${session.score}/10',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                  color: gold,
                ),
              ),
              Text(
                session.score == 10
                    ? 'You know ball.'
                    : session.score >= 7
                    ? 'A strong showing.'
                    : 'Keep learning the roster.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${roster.team} • Round complete',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      'Best streak: ${session.bestStreak}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (session is DailyQuizSession) ...[
                Text(
                  'Daily challenge • ${(session as DailyQuizSession).challenge.label} UTC',
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => DailyQuizScreen(
                        roster: roster,
                        challenge: (session as DailyQuizSession).challenge,
                      ),
                    ),
                  ),
                  child: const Text('Replay this daily challenge →'),
                ),
                const Text(
                  'Or start a random round below.',
                  textAlign: TextAlign.center,
                ),
              ],
              Text(
                '${session.difficulty.label} difficulty',
                textAlign: TextAlign.center,
              ),
              if (session.difficulty != QuizDifficulty.medium)
                FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => DifficultyQuizScreen(
                        roster: roster,
                        difficulty: session.difficulty,
                      ),
                    ),
                  ),
                  child: Text('Play ${session.difficulty.label} again →'),
                ),
              if (session.difficulty != QuizDifficulty.medium)
                const Text(
                  'Or play the original Medium round below.',
                  textAlign: TextAlign.center,
                ),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(roster: roster),
                  ),
                ),
                child: const Text('Play another round →'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to teams'),
              ),
              const SizedBox(height: 24),
              const Text(
                'YOUR ROUND',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              for (final (i, question) in session.questions.indexed)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlayerPortrait(
                          player: question.player,
                          size: 48,
                          revealName: true,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          session.answers[i] == question.player.id
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: session.answers[i] == question.player.id
                              ? const Color(0xFF70D9A5)
                              : const Color(0xFFFFA6A6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${question.player.number} · ${question.player.position}',
                                style: const TextStyle(color: gold),
                              ),
                              Text(
                                question.player.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                session.answers[i] == question.player.id
                                    ? 'Correct'
                                    : 'You picked ${question.options.firstWhere((p) => p.id == session.answers[i]).name}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
