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

  static const int minimumCleanHits = 13;
  static const double _scrollSpeed = 212;
  static const double _hitWindow = 0.24;
  static const double _perfectWindow = 0.1;
  static const double _hitLineX = 284;

  final VoidCallback onWin;
  final List<_RhythmNote> _notes = <_RhythmNote>[];

  final TextPaint _titleText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF274A45),
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
    ),
  );
  final TextPaint _bodyText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF5D4C38),
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.18,
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
  final TextPaint _feedbackText = TextPaint(
    style: GoogleFonts.sniglet(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );
  final TextPaint _resultTitleText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF274A45),
      fontSize: 42,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.6,
    ),
  );

  double _songTime = 0;
  double _countIn = 1.15;
  double _pulseTime = 0;
  double _judgementTimer = 0;
  double _victoryDelay = 0;
  int _cleanHits = 0;
  int _perfectHits = 0;
  int _misses = 0;
  int _combo = 0;
  int _bestCombo = 0;
  bool _won = false;
  bool _roundEnded = false;
  bool _finishTriggered = false;
  String _judgement = 'Silence...';
  Color _judgementColor = const Color(0xFF8A6A3D);

  Rect get _boardRect => const Rect.fromLTWH(78, 72, 1124, 578);

  Rect get _infoCardRect => const Rect.fromLTWH(104, 100, 610, 108);

  Rect get _statsCardRect => const Rect.fromLTWH(736, 100, 440, 108);

  Rect get _staffRect => const Rect.fromLTWH(104, 230, 1072, 300);

  Rect get _feedbackRect => const Rect.fromLTWH(104, 554, 1072, 58);

  Rect get _retryButton => const Rect.fromLTWH(490, 484, 300, 64);

  List<double> get _laneYs => <double>[
    _staffRect.top + 214,
    _staffRect.top + 186,
    _staffRect.top + 158,
    _staffRect.top + 130,
    _staffRect.top + 102,
    _staffRect.top + 74,
    _staffRect.top + 46,
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
        _combo = 0;
        _misses += 1;
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

    if (_roundEnded) {
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
    _combo += 1;
    _bestCombo = math.max(_bestCombo, _combo);

    if (delta <= _perfectWindow) {
      _perfectHits += 1;
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
    _perfectHits = 0;
    _misses = 0;
    _combo = 0;
    _bestCombo = 0;
    _won = false;
    _roundEnded = false;
    _finishTriggered = false;
    _judgement = 'Silence...';
    _judgementColor = const Color(0xFF8A6A3D);
    _notes
      ..clear()
      ..addAll(_buildChart());
  }

  List<_RhythmNote> _buildChart() {
    return <_RhythmNote>[
      _RhythmNote(time: 1.2, lane: 4),
      _RhythmNote(time: 1.7, lane: 5),
      _RhythmNote(time: 2.2, lane: 3),
      _RhythmNote(time: 2.8, lane: 2, accent: true),
      _RhythmNote(time: 3.4, lane: 4),
      _RhythmNote(time: 4.1, lane: 1),
      _RhythmNote(time: 4.8, lane: 2),
      _RhythmNote(time: 5.3, lane: 4, accent: true),
      _RhythmNote(time: 6.0, lane: 5),
      _RhythmNote(time: 6.6, lane: 3),
      _RhythmNote(time: 7.2, lane: 2),
      _RhythmNote(time: 8.0, lane: 0, accent: true),
      _RhythmNote(time: 8.7, lane: 2),
      _RhythmNote(time: 9.4, lane: 3),
      _RhythmNote(time: 10.1, lane: 5),
      _RhythmNote(time: 10.8, lane: 6, accent: true),
      _RhythmNote(time: 11.4, lane: 4),
      _RhythmNote(time: 12.1, lane: 2),
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
      if ((tap - noteOffset).distance > 44) {
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
      _victoryDelay = 1.2;
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
        sheetRect.height + 26,
      ),
      image: game.images.fromCache('props/partitura.png'),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
    canvas.restore();

    final hitLineRect = Rect.fromLTWH(
      _hitLineX - 8,
      _staffRect.top - 16,
      16,
      _staffRect.height + 32,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hitLineRect, const Radius.circular(999)),
      Paint()..color = const Color(0xFFFFE190).withValues(alpha: pulse),
    );

    for (final barX in <double>[430, 590, 750, 910, 1070]) {
      canvas.drawLine(
        Offset(barX, _staffRect.top + 18),
        Offset(barX, _staffRect.bottom - 18),
        Paint()
          ..color = const Color(0xFFA98C68).withValues(alpha: 0.18)
          ..strokeWidth = 2.2,
      );
    }
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
      width: 34,
      height: 24,
    );
    canvas.drawOval(headRect, Paint()..color = noteColor);
    canvas.drawOval(
      headRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.restore();

    canvas.drawLine(
      Offset(center.dx + 12, center.dy - 4),
      Offset(center.dx + 12, center.dy - 68),
      Paint()
        ..color = noteColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - 2),
      6,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  void _renderHud(Canvas canvas) {
    final infoCard = RRect.fromRectAndRadius(
      _infoCardRect,
      const Radius.circular(24),
    );
    canvas.drawRRect(
      infoCard,
      Paint()..color = Colors.white.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      infoCard,
      Paint()
        ..color = const Color(0xFFE7D5B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _titleText.render(canvas, 'MOZART CONSEQUENCES', Vector2(128, 120));
    _bodyText.render(
      canvas,
      'Suit will not hear a word while Mozart plays.\nTap when a note reaches the gold line.',
      Vector2(128, 158),
    );

    final statsCard = RRect.fromRectAndRadius(
      _statsCardRect,
      const Radius.circular(24),
    );
    canvas.drawRRect(
      statsCard,
      Paint()..color = Colors.white.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      statsCard,
      Paint()
        ..color = const Color(0xFFE7D5B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final meterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _statsCardRect.left + 22,
        _statsCardRect.top + 18,
        _statsCardRect.width - 44,
        22,
      ),
      const Radius.circular(999),
    );
    final progress = (_cleanHits / minimumCleanHits).clamp(0.0, 1.0);
    canvas.drawRRect(
      meterRect,
      Paint()..color = const Color(0xFFE9DDC9).withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          _statsCardRect.left + 22,
          _statsCardRect.top + 18,
          (_statsCardRect.width - 44) * progress,
          22,
        ),
        const Radius.circular(999),
      ),
      Paint()..color = const Color(0xFFD4A347),
    );
    _scoreText.render(
      canvas,
      'CLEAN HITS $_cleanHits/$minimumCleanHits',
      Vector2(_statsCardRect.left + 22, _statsCardRect.top + 56),
    );
    _scoreText.render(
      canvas,
      'PERFECT $_perfectHits',
      Vector2(_statsCardRect.left + 22, _statsCardRect.top + 82),
    );
    _scoreText.render(
      canvas,
      'COMBO $_combo',
      Vector2(_statsCardRect.left + 230, _statsCardRect.top + 56),
    );
    _scoreText.render(
      canvas,
      'MISSES $_misses',
      Vector2(_statsCardRect.left + 230, _statsCardRect.top + 82),
    );
  }

  void _renderFeedback(Canvas canvas) {
    final feedbackRect = RRect.fromRectAndRadius(
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
        ? 'Silence... ${(_countIn * 3).ceil().clamp(1, 3)}'
        : isActive
        ? _judgement
        : 'Tap when a note reaches the gold line.';

    canvas.drawRRect(
      feedbackRect,
      Paint()..color = fillColor.withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      feedbackRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _feedbackText.render(
      canvas,
      text.toUpperCase(),
      Vector2(_feedbackRect.left + 28, _feedbackRect.top + 15),
    );
  }

  void _renderResultCard(Canvas canvas) {
    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(372, 204, 536, 324),
      const Radius.circular(34),
    );

    canvas.drawRRect(
      cardRect,
      Paint()..color = const Color(0xFFFFF7EC).withValues(alpha: 0.98),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(384, 216, 512, 300),
        const Radius.circular(26),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = _won ? const Color(0xFF274A45) : const Color(0xFF8D5B2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _resultTitleText.render(
      canvas,
      _won ? 'FIRST MOVEMENT OVER' : 'SUIT STILL SHOUTS',
      Vector2(_won ? 430 : 446, 246),
    );
    _drawWrappedText(
      canvas,
      _won
          ? 'Suit finally pauses Mozart.\nBig gets a few seconds to explain the Brodaflix mess.'
          : 'Need at least $minimumCleanHits clean hits before the first movement ends.\nStay on the gold line and play it again.',
      const Rect.fromLTWH(420, 310, 440, 92),
      GoogleFonts.sniglet(
        color: const Color(0xFF5D4C38),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    if (!_won) {
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
        'PLAY IT AGAIN',
        _retryButton,
        GoogleFonts.sniglet(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      );
    }
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
      rect.left,
      rect.top + ((rect.height - painter.height) / 2),
    );
    painter.paint(canvas, offset);
  }
}

class _RhythmNote {
  _RhythmNote({required this.time, required this.lane, this.accent = false});

  final double time;
  final int lane;
  final bool accent;
  bool hit = false;
  bool missed = false;
}
