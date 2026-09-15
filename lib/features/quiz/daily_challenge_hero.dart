import 'package:flutter/material.dart';

/// Decorative field artwork stays local and works without image downloads.
class DailyChallengeHero extends StatelessWidget {
  const DailyChallengeHero({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF324F37), Color(0xFF142B22)],
      ),
    ),
    child: Stack(
      children: [
        const Positioned.fill(
          child: ExcludeSemantics(child: CustomPaint(painter: _FieldPainter())),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF13251D),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF61704B)),
                ),
                child: const Text(
                  'THE DAILY HUDDLE',
                  style: TextStyle(
                    color: Color(0xFFFFD775),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Icon(
                Icons.sports_football,
                color: Color(0xFFFFC83D),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'New day.\nGame on.',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.08,
                  letterSpacing: -1.2,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFF8E8),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Put your roster knowledge on the field.',
                style: TextStyle(
                  color: Color(0xFFD1DCCD),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class DailyChallengeBadge extends StatelessWidget {
  const DailyChallengeBadge({
    super.key,
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF242D27),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF394538)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFFFD775)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD9E0D9),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FieldPainter extends CustomPainter {
  const _FieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0x187CD28A)
      ..strokeWidth = 1;
    for (var i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
      for (var y = 12.0; y < size.height; y += 24) {
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), line);
      }
    }
    canvas.drawCircle(
      Offset(size.width, size.height * 0.25),
      size.width * 0.35,
      Paint()
        ..color = const Color(0x147CD28A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24,
    );
  }

  @override
  bool shouldRepaint(covariant _FieldPainter oldDelegate) => false;
}
