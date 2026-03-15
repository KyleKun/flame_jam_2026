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
      if (mounted) setState(() => _showThanks = true);
    });
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _canDismiss = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _canDismiss ? () => widget.game.returnToMainMenu() : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fade(_showFirstRole, Text('Art & Design', style: _roleStyle)),
            const SizedBox(height: 8),
            _fade(_showFirstName, Text('Bianca Pedroso', style: _nameStyle)),
            const SizedBox(height: 48),
            _fade(_showSecondRole, Text('Programming, Story & Music', style: _roleStyle)),
            const SizedBox(height: 8),
            _fade(_showSecondName, Text('Caio Pedroso', style: _nameStyle)),
            const SizedBox(height: 96),
            _fade(
              _showThanks,
              Text(
                'Thanks for playing!',
                style: GoogleFonts.sniglet(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fade(bool visible, Widget child) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
      child: child,
    );
  }

  TextStyle get _nameStyle => GoogleFonts.sniglet(
        color: Colors.white,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        shadows: const [
          Shadow(
            blurRadius: 10,
            color: Colors.black54,
            offset: Offset(2, 2),
          ),
        ],
      );

  TextStyle get _roleStyle => GoogleFonts.sniglet(
        color: Colors.white70,
        fontSize: 40,
        shadows: const [
          Shadow(
            blurRadius: 8,
            color: Colors.black45,
            offset: Offset(1, 1),
          ),
        ],
      );
}
