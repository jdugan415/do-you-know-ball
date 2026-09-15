import 'package:flutter/material.dart';

import '../roster/roster_repository.dart';
import 'daily_challenge_card.dart';

class DailyGiftBanner extends StatelessWidget {
  const DailyGiftBanner({super.key, required this.repository});
  final RosterRepository repository;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF514024), Color(0xFF29241C)],
          ),
          border: Border.all(color: const Color(0xFFAA8340)),
        ),
        child: InkWell(
          key: const ValueKey('daily-gift-banner'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DailyChallengeScreen(repository: repository),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _GiftArtwork(),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A NEW CHALLENGE DAILY',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFFD983),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your daily\nchallenge is here.',
                            style: TextStyle(
                              fontSize: 23,
                              height: 1.12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFF5DD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unwrap 10 questions. Show you know ball.',
                  style: TextStyle(color: Color(0xFFE0D3BA), height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC83D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Open daily challenge',
                          style: TextStyle(
                            color: Color(0xFF211A0A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF211A0A),
                        size: 20,
                      ),
                    ],
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

class _GiftArtwork extends StatelessWidget {
  const _GiftArtwork();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 72,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFF95702D), Color(0x00514024)],
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.12,
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 64,
              color: Color(0xFFFFD36A),
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.auto_awesome, size: 19, color: Color(0xFFFFEBC0)),
          ),
          const Positioned(
            bottom: 1,
            left: 0,
            child: Icon(Icons.add, size: 14, color: Color(0xFFFFD36A)),
          ),
        ],
      ),
    ),
  );
}
