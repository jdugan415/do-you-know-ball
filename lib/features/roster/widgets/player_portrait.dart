import 'package:flutter/material.dart';

import '../player.dart';

/// Fixed-size portraits keep the page stable during loading and errors.
/// Names are deliberately excluded from quiz image semantics.
class PlayerPortrait extends StatelessWidget {
  const PlayerPortrait({
    super.key,
    required this.player,
    this.size = 144,
    this.revealName = false,
    this.imageProvider,
  });
  final Player player;
  final double size;
  final bool revealName;
  final ImageProvider? imageProvider;

  Widget _fallback() => ColoredBox(
    color: const Color(0xFF2D332B),
    child: Center(
      child: Icon(
        Icons.person_outline,
        size: size * .45,
        color: const Color(0xFFB8BEBD),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    label: revealName
        ? 'Portrait of ${player.name}'
        : 'Mystery player portrait',
    image: true,
    child: ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: size,
          height: size,
          child: player.photoUrl == null && imageProvider == null
              ? _fallback()
              : Image(
                  key: ValueKey(player.id),
                  image: imageProvider ?? NetworkImage(player.photoUrl!),
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, synchronous) =>
                      frame == null ? _fallback() : child,
                  errorBuilder: (context, error, stack) => _fallback(),
                ),
        ),
      ),
    ),
  );
}
