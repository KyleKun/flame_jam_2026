import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsOverlay extends StatefulWidget {
  final MyGame game;

  const CreditsOverlay({super.key, required this.game});

  @override
  State<CreditsOverlay> createState() => _CreditsOverlayState();
}

class _CreditsOverlayState extends State<CreditsOverlay> {
  bool _showFirstRole = false;
  bool _showFirstName = false;
  bool _showSecondRole = false;
  bool _showSecondName = false;
  bool _showMadeWith = false;
  bool _showThanks = false;
  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    // Precache the font, then start the whole sequence.
    GoogleFonts.pendingFonts([
      GoogleFonts.sniglet(),
    ]).then((_) => _startSequence());
  }

  void _startSequence() {
    if (!mounted) return;
    setState(() => _showFirstRole = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showFirstName = true);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showSecondRole = true);
    });
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _showSecondName = true);
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _showMadeWith = true);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _showThanks = true);
    });
    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted) setState(() => _canDismiss = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Scale relative to the 1280×720 design size.
      final s = (constraints.maxWidth / 1280.0).clamp(0.0, 1.0);

      return GestureDetector(
        onTap: _canDismiss ? () => widget.game.returnToMainMenu() : null,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fade(_showFirstRole,
                  Text('Art & Design', style: _roleStyle(s))),
              SizedBox(height: 8 * s),
              _fade(_showFirstName,
                  Text('Bianca Pedroso', style: _nameStyle(s))),
              SizedBox(height: 48 * s),
              _fade(_showSecondRole,
                  Text('Programming, Story & Music', style: _roleStyle(s))),
              SizedBox(height: 8 * s),
              _fade(_showSecondName,
                  Text('Caio Pedroso', style: _nameStyle(s))),
              SizedBox(height: 64 * s),
              _fade(
                _showMadeWith,
                Text(
                  'Made with Flutter & Flame for the Flame Game Jam 2026',
                  style: _roleStyle(s),
                ),
              ),
              SizedBox(height: 32 * s),
              _fade(
                _showThanks,
                Text(
                  'Thanks for playing!',
                  style: GoogleFonts.sniglet(
                    color: Colors.white,
                    fontSize: 34 * s,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        blurRadius: 12 * s,
                        color: Colors.black54,
                        offset: Offset(2 * s, 2 * s),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _fade(bool visible, Widget child) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
      child: child,
    );
  }

  TextStyle _nameStyle(double s) => GoogleFonts.sniglet(
        color: Colors.white,
        fontSize: 64 * s,
        fontWeight: FontWeight.w700,
        shadows: [
          Shadow(
            blurRadius: 10 * s,
            color: Colors.black54,
            offset: Offset(2 * s, 2 * s),
          ),
        ],
      );

  TextStyle _roleStyle(double s) => GoogleFonts.sniglet(
        color: Colors.white70,
        fontSize: 40 * s,
        shadows: [
          Shadow(
            blurRadius: 8 * s,
            color: Colors.black45,
            offset: Offset(s, s),
          ),
        ],
      );
}
