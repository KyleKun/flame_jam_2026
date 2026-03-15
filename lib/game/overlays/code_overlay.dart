import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeOverlay extends StatelessWidget {
  const CodeOverlay({super.key, required this.game});

  final MyGame game;

  static const _color1 = Color(0xFF1D8E4C);
  static const _color2 = Color(0xFF3CCB76);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cst) {
        final wide = cst.maxWidth > 900;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: wide ? const Alignment(0, -0.6) : Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 32,
                ),
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
                        colors: [_color1, _color2],
                      ).createShader(bounds),
                      child: Text(
                        'HACKER BRO',
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
                      'Mission: Legally infiltrate Brodaflix servers.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sniglet(
                        fontSize: 24,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tap the command blocks to build the correct code sequence.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sniglet(
                        fontSize: 21,
                        color: _color1.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 240,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: game.startCodeMinigame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _color1,
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
            ),
          ),
        );
      },
    );
  }
}
