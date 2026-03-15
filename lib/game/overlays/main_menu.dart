import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';

class MainMenuOverlay extends StatelessWidget {
  final MyGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'FLAME JAM',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Color(0xFFe94560),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2026',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 16,
              ),
            ),
            const SizedBox(height: 80),
            _MenuButton(
              label: 'START',
              onPressed: () => game.startGame(),
            ),
            const SizedBox(height: 20),
            _MenuButton(
              label: 'CREDITS',
              onPressed: () => game.showCredits(),
            ),
          ],
        ),
      ),
    );
  }

}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe94560),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
