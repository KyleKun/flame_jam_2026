import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeOverlay extends StatelessWidget {
  const CodeOverlay({super.key, required this.game});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.48),
      child: SafeArea(
        child: Center(
          child: Container(
            width: 640,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
            decoration: BoxDecoration(
              color: const Color(0xFF07140D).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF3CCB76), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BRODAFLIX REMOTE OPS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE8FFF0),
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rebuild each command from left to right.',
                  style: GoogleFonts.spaceMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA5E7BB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wrong blocks add errors. Tap the command line to rewind from any spot.',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    color: const Color(0xFF9BC7AC),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 220,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: game.startCodeMinigame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D8E4C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'OPEN TERMINAL',
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
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
}
