import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DogTrainingOverlay extends StatelessWidget {
  const DogTrainingOverlay({super.key, required this.game});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.78),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 32),
        margin: const EdgeInsets.symmetric(horizontal: 80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF38A55D), Color(0xFF2D88B8)],
              ).createShader(bounds),
              child: Text(
                'DOG TRAINING',
                style: GoogleFonts.sniglet(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Watch the commands, then repeat them\nin the same order.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sniglet(
                fontSize: 24,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 240,
              height: 62,
              child: ElevatedButton(
                onPressed: game.startDogTrainingMinigame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A55D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'START',
                  style: GoogleFonts.sniglet(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
