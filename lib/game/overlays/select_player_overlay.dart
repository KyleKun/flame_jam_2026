import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPlayerOverlay extends StatefulWidget {
  const SelectPlayerOverlay({super.key, required this.game});

  final MyGame game;

  @override
  State<SelectPlayerOverlay> createState() => _SelectPlayerOverlayState();
}

class _SelectPlayerOverlayState extends State<SelectPlayerOverlay>
    with SingleTickerProviderStateMixin {
  static const _bgImage = 'assets/images/ui/select_player.png';

  // Character hit regions as fractions of the 1280×720 source image.
  static const _chars = [
    // Top row
    _Char('chubby', 0.29, 0.16, 0.46, 0.52),
    _Char('bro1', 0.50, 0.16, 0.67, 0.52),
    _Char('suit', 0.71, 0.16, 0.89, 0.52),
    // Bottom row
    _Char('blonde', 0.07, 0.56, 0.25, 0.82),
    _Char('blue', 0.29, 0.56, 0.46, 0.82),
    _Char('strong', 0.50, 0.56, 0.67, 0.82),
    _Char('big', 0.72, 0.56, 0.89, 0.82),
  ];

  late final AnimationController _bounce;
  int? _hovered;
  bool _showMsg = false;
  bool _fadingOut = false;
  double _fadeOpacity = 0;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _startFadeOut() {
    setState(() => _fadingOut = true);
    // Animate opacity to 1 over 800ms
    Future.delayed(const Duration(milliseconds: 16), _tickFade);
  }

  void _tickFade() {
    if (!mounted) return;
    setState(() {
      _fadeOpacity += 0.04; // ~800ms at 60fps (50 frames × 0.02 ≈ 1.0, but 0.04 gives ~400ms which matches better)
    });
    if (_fadeOpacity >= 1.0) {
      _fadeOpacity = 1.0;
      widget.game.overlays.remove('selectPlayer');
      widget.game.startGameFromSelect();
    } else {
      Future.delayed(const Duration(milliseconds: 16), _tickFade);
    }
  }

  // ---------- helpers ----------

  _Layout _layout(BoxConstraints c) {
    const aspect = 1280.0 / 720.0;
    final sw = c.maxWidth, sh = c.maxHeight;
    final sa = sw / sh;
    // BoxFit.contain — fit inside, letterbox the rest
    if (sa > aspect) {
      final dw = sh * aspect;
      return _Layout(dw, sh, (sw - dw) / 2, 0);
    } else {
      final dh = sw / aspect;
      return _Layout(sw, dh, 0, (sh - dh) / 2);
    }
  }

  int? _hitTest(Offset pos, _Layout ly) {
    final fx = (pos.dx - ly.ox) / ly.dw;
    final fy = (pos.dy - ly.oy) / ly.dh;
    for (var i = 0; i < _chars.length; i++) {
      final c = _chars[i];
      if (fx >= c.l && fx <= c.r && fy >= c.t && fy <= c.b) return i;
    }
    return null;
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cst) {
      final ly = _layout(cst);

      return MouseRegion(
        cursor: (_hovered != null && !_showMsg) || _showMsg
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onHover: (e) {
          if (_showMsg) return;
          final h = _hitTest(e.localPosition, ly);
          if (h != _hovered) setState(() => _hovered = h);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            if (_showMsg && !_fadingOut) {
              _startFadeOut();
            } else if (!_showMsg) {
              final h = _hitTest(d.localPosition, ly);
              if (h != null) {
                setState(() {
                  _hovered = h;
                  _showMsg = true;
                });
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF96E6FF)),
              Positioned.fill(
                child: Image.asset(_bgImage, fit: BoxFit.contain),
              ),

              // Bouncing arrow
              if (_hovered != null && !_showMsg)
                AnimatedBuilder(
                  animation: _bounce,
                  builder: (_, __) {
                    final i = _hovered!;
                    final c = _chars[i];
                    final s = ly.dw / 1280.0;
                    final aw = 44.0 * s, ah = 32.0 * s;
                    final cx = ly.ox + (c.l + c.r) / 2 * ly.dw;
                    final topRow = i < 3;
                    final double ay;
                    if (topRow) {
                      // Above frame, bounce upward
                      ay = ly.oy + c.t * ly.dh - ah - 16 * s -
                          _bounce.value * 14 * s;
                    } else {
                      // Below frame, bounce downward
                      ay = ly.oy + c.b * ly.dh + 16 * s +
                          _bounce.value * 14 * s;
                    }
                    return Positioned(
                      left: cx - aw / 2,
                      top: ay,
                      child: CustomPaint(
                        size: Size(aw, ah),
                        painter: _ArrowPainter(pointUp: !topRow),
                      ),
                    );
                  },
                ),

              // Message box
              if (_showMsg)
                Positioned(
                  left: ly.ox,
                  right: ly.ox,
                  bottom: ly.oy,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 48 * ly.dw / 1280.0,
                      vertical: 32 * ly.dw / 1280.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 3.5 * ly.dw / 1280.0,
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.sniglet(
                          fontSize: 28 * ly.dw / 1280.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Interesting, but... You have no choice.\n'
                                'In a house of brothers, there is ',
                          ),
                          TextSpan(
                            text: 'No Protagonist!',
                            style: GoogleFonts.sniglet(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Fade to black
              if (_fadingOut)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: _fadeOpacity),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ---------- data classes ----------

class _Char {
  const _Char(this.name, this.l, this.t, this.r, this.b);
  final String name;
  final double l, t, r, b;
}

class _Layout {
  const _Layout(this.dw, this.dh, this.ox, this.oy);
  final double dw, dh, ox, oy;
}

// ---------- arrow painter ----------

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({this.pointUp = false});
  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path;
    if (pointUp) {
      // Triangle pointing up
      path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      // Triangle pointing down
      path = Path()
        ..moveTo(size.width / 2, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..close();
    }

    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.pointUp != pointUp;
}
