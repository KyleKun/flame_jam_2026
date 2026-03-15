import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MinigameGameOverOverlay extends StatelessWidget {
  const MinigameGameOverOverlay({super.key, required this.game});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
          width: 520,
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 38),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.sniglet(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB23A48),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Time ran out before breakfast was ready.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sniglet(
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You sliced ${game.lastKitchenMinigameScore} / ${game.kitchenMinigameTargetScore} fruits.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sniglet(
                  fontSize: 24,
                  color: Colors.black54,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                height: 58,
                child: ElevatedButton(
                  onPressed: game.retryKitchenMinigame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe94560),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'RETRY',
                    style: GoogleFonts.sniglet(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
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
