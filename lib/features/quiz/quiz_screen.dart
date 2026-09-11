import 'package:flutter/material.dart';

import '../../core/app_theme.dart' show gold;
import '../roster/roster_repository.dart';
import '../roster/widgets/player_portrait.dart';
import 'quiz_session.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.roster});
  final Roster roster;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizSession session = QuizSession(widget.roster);
  bool _leaving = false;
  bool _dialogOpen = false;

  Future<void> _confirmExit() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this round?'),
        content: const Text('Your progress in this round will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (leave == true && mounted) {
      setState(() => _leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = session.current;
    final correct = session.selectedId == question.player.id;
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.roster.team} challenge'),
          leading: IconButton(
            onPressed: _confirmExit,
            icon: const Icon(Icons.close),
            tooltip: 'Leave quiz',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      Text(
                        'QUESTION ${session.index + 1} / 10',
                        style: const TextStyle(
                          color: gold,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text('${session.score} correct'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (session.index + 1) / 10,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Who is this player?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF34382A), Color(0xFF1C1F20)],
                      ),
                    ),
                    child: Column(
                      children: [
                        PlayerPortrait(player: question.player),
                        const SizedBox(height: 14),
                        Text(
                          widget.roster.team.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Semantics(
                          label: 'Jersey number ${question.player.number}',
                          excludeSemantics: true,
                          child: Text(
                            '${question.player.number}',
                            style: const TextStyle(
                              fontSize: 56,
                              height: 1.3,
                              fontWeight: FontWeight.w900,
                              color: gold,
                            ),
                          ),
                        ),
                        Text(
                          'POSITION  /  ${question.player.position}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        if (question.player.photoCredit != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            question.player.photoCredit!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB8BEBD),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final (i, option) in question.options.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(
                        key: ValueKey('answer-$i'),
                        onPressed: session.answered
                            ? null
                            : () => setState(() => session.answer(option.id)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          backgroundColor:
                              session.answered &&
                                  option.id == question.player.id
                              ? const Color(0xFF234938)
                              : session.selectedId == option.id
                              ? const Color(0xFF522B2D)
                              : const Color(0xFF1C1F20),
                          side: BorderSide(
                            color:
                                session.answered &&
                                    option.id == question.player.id
                                ? const Color(0xFF70D9A5)
                                : const Color(0xFF414747),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + i),
                              style: const TextStyle(
                                color: gold,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (session.answered &&
                                option.id == question.player.id)
                              const Icon(Icons.check_circle),
                            if (session.selectedId == option.id && !correct)
                              const Icon(Icons.cancel_outlined),
                          ],
                        ),
                      ),
                    ),
                  if (session.answered) ...[
                    const SizedBox(height: 8),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        correct
                            ? 'Correct. You know your roster!'
                            : 'The answer is ${question.player.name}.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (session.complete) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => ResultsScreen(
                                roster: widget.roster,
                                session: session,
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            session.next();
                          });
                        }
                      },
                      child: Text(
                        session.complete ? 'See results →' : 'Next player →',
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Choose one answer to continue.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
