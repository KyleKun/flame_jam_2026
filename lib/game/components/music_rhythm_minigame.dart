import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MusicRhythmMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  MusicRhythmMinigameComponent({required this.onWin})
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  static const int minimumCleanHits = 34;
  static const double _scrollSpeed = 212;
  static const double _hitWindow = 0.24;
  static const double _perfectWindow = 0.1;
  static const double _hitLineX = 284;

  final VoidCallback onWin;
  final List<_RhythmNote> _notes = <_RhythmNote>[];

  final TextPaint _hudText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF5D4C38),
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
    ),
  );
  final TextPaint _scoreText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF274A45),
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );
  final TextStyle _feedbackStyle = GoogleFonts.sniglet(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );
  double _songTime = 0;
  double _countIn = 1.15;
  double _pulseTime = 0;
  double _judgementTimer = 0;
  double _victoryDelay = 0;
  int _cleanHits = 0;
  bool _won = false;
  bool _roundEnded = false;
  bool _finishTriggered = false;
  String _judgement = 'Silence...';
  Color _judgementColor = const Color(0xFF8A6A3D);

  Rect get _boardRect => const Rect.fromLTWH(78, 72, 1124, 578);

  Rect get _hudRect => const Rect.fromLTWH(104, 92, 1072, 58);

  Rect get _staffRect => const Rect.fromLTWH(104, 168, 1072, 380);

  Rect get _feedbackRect => const Rect.fromLTWH(390, 564, 500, 52);

  Rect get _retryButton => const Rect.fromLTWH(490, 440, 300, 64);

  List<double> get _laneYs => <double>[
    _staffRect.top + 340, // lane 0 – C
    _staffRect.top + 280, // lane 1 – D
    _staffRect.top + 210, // lane 2 – E
    _staffRect.top + 175, // lane 3 – F
    _staffRect.top + 130, // lane 4 – G
    _staffRect.top + 65, // lane 5 – A
  ];

  @override
  Future<void> onLoad() async {
    _resetRound();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _pulseTime += dt;
    if (_judgementTimer > 0) {
      _judgementTimer = math.max(0, _judgementTimer - dt);
    }

    if (_won) {
      _victoryDelay = math.max(0, _victoryDelay - dt);
      if (_victoryDelay <= 0 && !_finishTriggered) {
        _finishTriggered = true;
        onWin();
      }
      return;
    }

    if (_roundEnded) {
      return;
    }

    if (_countIn > 0) {
      _countIn = math.max(0, _countIn - dt);
      if (_countIn == 0) {
        _setJudgement('Play!', const Color(0xFFD3A13F));
      }
      return;
    }

    _songTime += dt;

    for (final note in _notes) {
      if (note.hit || note.missed) {
        continue;
      }

      if (_songTime - note.time > _hitWindow) {
        note.missed = true;
        MinigameSfx.playError();
        _setJudgement('Miss', const Color(0xFFD94B57));
      }
    }

    if (_notes.every((note) => note.hit || note.missed)) {
      _finishRound();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF081A17).withValues(alpha: 0.58),
    );

    _renderBoard(canvas);
    _renderHud(canvas);
    _renderStaff(canvas);
    _renderNotes(canvas);
    _renderFeedback(canvas);

    if (_roundEnded && !_won) {
      _renderResultCard(canvas);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final tap = Offset(event.localPosition.x, event.localPosition.y);
    if (_roundEnded) {
      if (!_won && _retryButton.contains(tap)) {
        _resetRound();
      }
      return;
    }

    if (_countIn > 0) {
      return;
    }

    final note = _pickNoteAt(tap);
    if (note == null) {
      _setJudgement('Off beat', const Color(0xFFC95A8A));
      return;
    }

    final delta = (_songTime - note.time).abs();
    note.hit = true;
    _cleanHits += 1;

    MinigameSfx.playNote(note.noteName);

    if (delta <= _perfectWindow) {
      _setJudgement('Perfect', const Color(0xFFFFC84A));
    } else {
      _setJudgement('Good', const Color(0xFF7FD1FF));
    }
  }

  void _resetRound() {
    _songTime = 0;
    _countIn = 1.15;
    _pulseTime = 0;
    _judgementTimer = 1.2;
    _victoryDelay = 0;
    _cleanHits = 0;
    _won = false;
    _roundEnded = false;
    _finishTriggered = false;
    _judgement = 'Silence...';
    _judgementColor = const Color(0xFF8A6A3D);
    _notes
      ..clear()
      ..addAll(_buildChart());
  }

  /// Twinkle Twinkle Little Star (full)
  List<_RhythmNote> _buildChart() {
    return <_RhythmNote>[
      // Line 1: C C G G A A G –
      _RhythmNote(time: 1.0, lane: 0, noteName: 'c'),
      _RhythmNote(time: 1.5, lane: 0, noteName: 'c'),
      _RhythmNote(time: 2.0, lane: 4, noteName: 'g'),
      _RhythmNote(time: 2.5, lane: 4, noteName: 'g'),
      _RhythmNote(time: 3.0, lane: 5, noteName: 'a'),
      _RhythmNote(time: 3.5, lane: 5, noteName: 'a'),
      _RhythmNote(time: 4.0, lane: 4, noteName: 'g', accent: true),
      // Line 2: F F E E D D C –
      _RhythmNote(time: 5.0, lane: 3, noteName: 'f'),
      _RhythmNote(time: 5.5, lane: 3, noteName: 'f'),
      _RhythmNote(time: 6.0, lane: 2, noteName: 'e'),
      _RhythmNote(time: 6.5, lane: 2, noteName: 'e'),
      _RhythmNote(time: 7.0, lane: 1, noteName: 'd'),
      _RhythmNote(time: 7.5, lane: 1, noteName: 'd'),
      _RhythmNote(time: 8.0, lane: 0, noteName: 'c', accent: true),
      // Line 3: G G F F E E D –
      _RhythmNote(time: 9.0, lane: 4, noteName: 'g'),
      _RhythmNote(time: 9.5, lane: 4, noteName: 'g'),
      _RhythmNote(time: 10.0, lane: 3, noteName: 'f'),
      _RhythmNote(time: 10.5, lane: 3, noteName: 'f'),
      _RhythmNote(time: 11.0, lane: 2, noteName: 'e'),
      _RhythmNote(time: 11.5, lane: 2, noteName: 'e'),
      _RhythmNote(time: 12.0, lane: 1, noteName: 'd', accent: true),
      // Line 4: G G F F E E D –
      _RhythmNote(time: 13.0, lane: 4, noteName: 'g'),
      _RhythmNote(time: 13.5, lane: 4, noteName: 'g'),
      _RhythmNote(time: 14.0, lane: 3, noteName: 'f'),
      _RhythmNote(time: 14.5, lane: 3, noteName: 'f'),
      _RhythmNote(time: 15.0, lane: 2, noteName: 'e'),
      _RhythmNote(time: 15.5, lane: 2, noteName: 'e'),
      _RhythmNote(time: 16.0, lane: 1, noteName: 'd', accent: true),
      // Line 5 (repeat line 1): C C G G A A G –
      _RhythmNote(time: 17.0, lane: 0, noteName: 'c'),
      _RhythmNote(time: 17.5, lane: 0, noteName: 'c'),
      _RhythmNote(time: 18.0, lane: 4, noteName: 'g'),
      _RhythmNote(time: 18.5, lane: 4, noteName: 'g'),
      _RhythmNote(time: 19.0, lane: 5, noteName: 'a'),
      _RhythmNote(time: 19.5, lane: 5, noteName: 'a'),
      _RhythmNote(time: 20.0, lane: 4, noteName: 'g', accent: true),
      // Line 6 (repeat line 2): F F E E D D C –
      _RhythmNote(time: 21.0, lane: 3, noteName: 'f'),
      _RhythmNote(time: 21.5, lane: 3, noteName: 'f'),
      _RhythmNote(time: 22.0, lane: 2, noteName: 'e'),
      _RhythmNote(time: 22.5, lane: 2, noteName: 'e'),
      _RhythmNote(time: 23.0, lane: 1, noteName: 'd'),
      _RhythmNote(time: 23.5, lane: 1, noteName: 'd'),
      _RhythmNote(time: 24.0, lane: 0, noteName: 'c', accent: true),
    ];
  }

  _RhythmNote? _pickNoteAt(Offset tap) {
    _RhythmNote? best;
    double bestDelta = double.infinity;

    for (final note in _notes) {
      if (note.hit || note.missed) {
        continue;
      }

      final timeDelta = (_songTime - note.time).abs();
      if (timeDelta > _hitWindow) {
        continue;
      }

      final noteOffset = Offset(_noteX(note), _laneYs[note.lane]);
      if ((tap - noteOffset).distance > 56) {
        continue;
      }

      if (timeDelta < bestDelta) {
        bestDelta = timeDelta;
        best = note;
      }
    }

    return best;
  }

  double _noteX(_RhythmNote note) {
    return _hitLineX + ((note.time - _songTime) * _scrollSpeed);
  }

  void _setJudgement(String text, Color color) {
    _judgement = text;
    _judgementColor = color;
    _judgementTimer = 0.85;
  }

  void _finishRound() {
    _roundEnded = true;
    _won = _cleanHits >= minimumCleanHits;
    if (_won) {
      _victoryDelay = 0.35;
      MinigameSfx.playWin();
    }
  }

  void _renderBoard(Canvas canvas) {
    final boardRRect = RRect.fromRectAndRadius(
      _boardRect,
      const Radius.circular(36),
    );

    canvas.drawShadow(
      Path()..addRRect(boardRRect),
      Colors.black.withValues(alpha: 0.45),
      22,
      true,
    );
    canvas.drawRRect(
      boardRRect,
      Paint()..color = const Color(0xFFFFF7EC).withValues(alpha: 0.98),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _boardRect.deflate(12),
        const Radius.circular(28),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      boardRRect,
      Paint()
        ..color = const Color(0xFF274A45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _renderStaff(Canvas canvas) {
    final pulse = 0.58 + (math.sin(_pulseTime * 6) * 0.16);
    final sheetRect = Rect.fromLTWH(
      _staffRect.left,
      _staffRect.top,
      _staffRect.width,
      _staffRect.height,
    );
    final sheetRRect = RRect.fromRectAndRadius(
      sheetRect,
      const Radius.circular(30),
    );

    canvas.drawShadow(
      Path()..addRRect(sheetRRect),
      Colors.black.withValues(alpha: 0.28),
      18,
      true,
    );
    canvas.drawRRect(
      sheetRRect,
      Paint()..color = const Color(0xFFFFFDF7).withValues(alpha: 0.98),
    );
    canvas.drawRRect(
      sheetRRect,
      Paint()
        ..color = const Color(0xFF8A6A3D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(sheetRect.deflate(12), const Radius.circular(20)),
    );
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
        sheetRect.left + 20,
        sheetRect.top - 2,
        sheetRect.width - 40,
        sheetRect.height,
      ),
      image: game.images.fromCache('props/partitura.png'),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
    canvas.restore();

    final hitLineRect = Rect.fromLTWH(
      _hitLineX - 12,
      _staffRect.top - 16,
      24,
      _staffRect.height + 32,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hitLineRect, const Radius.circular(999)),
      Paint()..color = const Color(0xFFFFE190).withValues(alpha: pulse),
    );
  }

  void _renderNotes(Canvas canvas) {
    for (final note in _notes) {
      if (note.hit || note.missed) {
        continue;
      }

      final x = _noteX(note);
      if (x < _staffRect.left - 80 || x > _staffRect.right + 80) {
        continue;
      }

      final y = _laneYs[note.lane];
      _drawNote(canvas, Offset(x, y), accent: note.accent);
    }
  }

  void _drawNote(Canvas canvas, Offset center, {required bool accent}) {
    final noteColor = accent
        ? const Color(0xFFFFA93A)
        : const Color(0xFF6A3FC7);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.22);
    final headRect = Rect.fromCenter(
      center: Offset.zero,
      width: 48,
      height: 34,
    );
    canvas.drawOval(headRect, Paint()..color = noteColor);
    canvas.drawOval(
      headRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    canvas.restore();

    canvas.drawLine(
      Offset(center.dx + 16, center.dy - 6),
      Offset(center.dx + 16, center.dy - 88),
      Paint()
        ..color = noteColor
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - 2),
      8,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  void _renderHud(Canvas canvas) {
    final hudRRect = RRect.fromRectAndRadius(
      _hudRect,
      const Radius.circular(18),
    );
    canvas.drawRRect(
      hudRRect,
      Paint()..color = Colors.white.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      hudRRect,
      Paint()
        ..color = const Color(0xFFE7D5B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _hudText.render(
      canvas,
      'Tap the note when they cross the yellow line',
      Vector2(_hudRect.left + 18, _hudRect.top + 17),
    );

    // Progress bar on the right side.
    final barLeft = _hudRect.right - 250;
    final meterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, _hudRect.top + 14, 160, 18),
      const Radius.circular(999),
    );
    final progress = (_cleanHits / minimumCleanHits).clamp(0.0, 1.0);
    canvas.drawRRect(
      meterRect,
      Paint()..color = const Color(0xFFE9DDC9).withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, _hudRect.top + 14, 160 * progress, 18),
        const Radius.circular(999),
      ),
      Paint()..color = const Color(0xFFD4A347),
    );
    _scoreText.render(
      canvas,
      '$_cleanHits/$minimumCleanHits',
      Vector2(barLeft + 175, _hudRect.top + 14),
    );
  }

  void _renderFeedback(Canvas canvas) {
    final feedbackRRect = RRect.fromRectAndRadius(
      _feedbackRect,
      const Radius.circular(18),
    );
    final isActive = _countIn > 0 || (_judgementTimer > 0 && !_roundEnded);
    final fillColor = _countIn > 0
        ? const Color(0xFF8A6A3D)
        : isActive
        ? _judgementColor
        : const Color(0xFF274A45);
    final text = _countIn > 0
        ? 'Get ready... ${(_countIn * 3).ceil().clamp(1, 3)}'
        : isActive
        ? _judgement
        : '';

    canvas.drawRRect(
      feedbackRRect,
      Paint()..color = fillColor.withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      feedbackRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final painter = TextPainter(
      text: TextSpan(text: text.toUpperCase(), style: _feedbackStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        _feedbackRect.left + (_feedbackRect.width - painter.width) / 2,
        _feedbackRect.top + (_feedbackRect.height - painter.height) / 2,
      ),
    );
  }

  void _renderResultCard(Canvas canvas) {
    _renderFailCard(canvas);
  }

  void _renderFailCard(Canvas canvas) {
    const cardBounds = Rect.fromLTWH(410, 230, 460, 290);
    final cardRRect = RRect.fromRectAndRadius(
      cardBounds,
      const Radius.circular(34),
    );

    canvas.drawRRect(
      cardRRect,
      Paint()..color = const Color(0xFFFFF7EC).withValues(alpha: 0.98),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cardBounds.deflate(12),
        const Radius.circular(26),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      cardRRect,
      Paint()
        ..color = const Color(0xFF8D5B2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawWrappedText(
      canvas,
      'FAILED',
      const Rect.fromLTWH(410, 260, 460, 56),
      GoogleFonts.sniglet(
        color: const Color(0xFFD94B57),
        fontSize: 46,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
      ),
    );

    _drawWrappedText(
      canvas,
      "Big bro won't let you talk until the music is over",
      const Rect.fromLTWH(440, 330, 400, 50),
      GoogleFonts.sniglet(
        color: const Color(0xFF5D4C38),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    final retryRRect = RRect.fromRectAndRadius(
      _retryButton,
      const Radius.circular(18),
    );
    canvas.drawRRect(retryRRect, Paint()..color = const Color(0xFF274A45));
    canvas.drawRRect(
      retryRRect,
      Paint()
        ..color = const Color(0xFFD4A347)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawWrappedText(
      canvas,
      'RETRY',
      _retryButton,
      GoogleFonts.sniglet(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }

  void _drawWrappedText(
    Canvas canvas,
    String text,
    Rect rect,
    TextStyle style, {
    TextAlign align = TextAlign.center,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: rect.width);

    final offset = Offset(
      rect.left + ((rect.width - painter.width) / 2),
      rect.top + ((rect.height - painter.height) / 2),
    );
    painter.paint(canvas, offset);
  }
}

class _RhythmNote {
  _RhythmNote({
    required this.time,
    required this.lane,
    required this.noteName,
    this.accent = false,
  });

  final double time;
  final int lane;
  final String noteName;
  final bool accent;
  bool hit = false;
  bool missed = false;
}
