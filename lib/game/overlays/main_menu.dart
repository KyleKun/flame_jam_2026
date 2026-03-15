import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});

  final MyGame game;

  static const _backgroundImage = 'assets/images/ui/menu.png';
  static const _backgroundColor = Color(0xFF18101F);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;

        // Match BoxFit.contain layout for the 1280×720 background
        const imgAspect = 1280.0 / 720.0;
        final screenAspect = sw / sh;
        final double imgW, imgH, imgX, imgY;
        if (screenAspect > imgAspect) {
          imgH = sh;
          imgW = sh * imgAspect;
          imgX = (sw - imgW) / 2;
          imgY = 0;
        } else {
          imgW = sw;
          imgH = sw / imgAspect;
          imgX = 0;
          imgY = (sh - imgH) / 2;
        }

        // Scale everything relative to the displayed image
        final s = imgW / 1280.0;
        final buttonW = 360.0 * s;
        final buttonH = 105.0 * s;
        final spacing = 22.0 * s;

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _backgroundColor),
            Positioned.fill(
              child: Image.asset(_backgroundImage, fit: BoxFit.contain),
            ),
            Positioned(
              left: imgX + imgW / 2 - buttonW / 2,
              top: imgY + imgH * 0.58,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuButton(
                    label: 'START',
                    width: buttonW,
                    height: buttonH,
                    scale: s,
                    faceColor: const Color(0xFFFE8B34),
                    highlightColor: const Color(0xFFFFC06A),
                    shadowColor: const Color(0xFFB85510),
                    outlineColor: const Color(0xFF5C2A08),
                    glowColor: const Color(0xFFFEAB5E),
                    onPressed: game.startGame,
                  ),
                  SizedBox(height: spacing),
                  _MenuButton(
                    label: 'CREDITS',
                    width: buttonW,
                    height: buttonH,
                    scale: s,
                    faceColor: const Color(0xFF34A9FE),
                    highlightColor: const Color(0xFF7AD4FF),
                    shadowColor: const Color(0xFF1A6FBA),
                    outlineColor: const Color(0xFF0C3560),
                    glowColor: const Color(0xFF6EC8FE),
                    onPressed: game.showCredits,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.label,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.scale,
    required this.faceColor,
    required this.highlightColor,
    required this.shadowColor,
    required this.outlineColor,
    required this.glowColor,
  });

  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double scale;
  final Color faceColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color outlineColor;
  final Color glowColor;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final radius = 28.0 * s;
    final border = 4.0 * s;
    final shadowInset = widget.height * 0.16;
    final restingLift = widget.height * 0.05;
    final pressedLift = widget.height * 0.12;
    final bottomGap = widget.height * 0.09;
    final topOffset = _isPressed ? pressedLift : (_isHovered ? 0.0 : restingLift);

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : (_isHovered ? 1.035 : 1),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedRotation(
              turns: _isHovered && !_isPressed ? -0.003 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: shadowInset,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.shadowColor,
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(
                            color: widget.outlineColor,
                            width: border,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      top: topOffset,
                      left: 0,
                      right: 0,
                      bottom: _isPressed ? 0 : bottomGap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.highlightColor,
                              widget.faceColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(
                            color: widget.outlineColor,
                            width: border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.glowColor.withValues(
                                alpha: _isHovered ? 0.42 : 0,
                              ),
                              blurRadius: _isHovered ? 26 * s : 0,
                              spreadRadius: _isHovered ? s : 0,
                              offset: Offset(0, 12 * s),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 18 * s,
                              right: 18 * s,
                              top: 8 * s,
                              height: widget.height * 0.2,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: _isPressed ? 0.12 : 0.24,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Center(
                              child: _OutlinedText(
                                text: widget.label,
                                fontSize: widget.height * 0.32,
                                fillColor: Colors.white,
                                strokeColor: widget.outlineColor,
                                shadowColor: Colors.black.withValues(alpha: 0.35),
                                letterSpacing: 2 * s,
                                strokeWidth: 4 * s,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
    required this.shadowColor,
    required this.letterSpacing,
    required this.strokeWidth,
  });

  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final Color shadowColor;
  final double letterSpacing;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.sniglet(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: letterSpacing,
      height: 1,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: fillColor,
            shadows: [
              Shadow(
                color: shadowColor.withValues(alpha: 0.75),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
