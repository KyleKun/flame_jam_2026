import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugSkipOverlay extends StatelessWidget {
  final MyGame game;

  const DebugSkipOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            game.overlays.remove('debugSkip');
            game.skipCurrentMinigame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.85),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'SKIP',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
