import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeSequenceMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  CodeSequenceMinigameComponent({required this.onWin})
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  final VoidCallback onWin;

  // ── Rounds ──

  late final List<_CodeRound> _rounds = <_CodeRound>[
    const _CodeRound(
      objective: 'Trace the viewer region',
      solution: <String>['region', '=', 'trace_region(account_id)'],
      bank: <String>[
        'trace_region(account_id)',
        'region',
        '=',
        'panic_mode()',
        'mute_alerts()',
      ],
    ),
    const _CodeRound(
      objective: 'Check stream health',
      solution: <String>['health', '=', 'check_health(region)'],
      bank: <String>[
        'health',
        '=',
        'check_health(region)',
        'skip_checks()',
        'fake_greenlight()',
      ],
    ),
    const _CodeRound(
      objective: 'Inspect the release build',
      solution: <String>['build', '=', 'inspect_release(region)'],
      bank: <String>[
        'build',
        '=',
        'inspect_release(region)',
        'guess_the_bug()',
        'wipe_history()',
      ],
    ),
    const _CodeRound(
      objective: 'Patch the player remotely',
      solution: <String>['patch', '=', 'hotfix_player(build)'],
      bank: <String>[
        'patch',
        '=',
        'hotfix_player(build)',
        'delete_player(build)',
        'ship_on_friday()',
      ],
    ),
    const _CodeRound(
      objective: 'Rebalance the stream traffic',
      solution: <String>['traffic', '=', 'rebalance_streams(region)'],
      bank: <String>[
        'traffic',
        '=',
        'rebalance_streams(region)',
        'max_ads(region)',
        'sleep(999)',
      ],
    ),
    const _CodeRound(
      objective: 'Compare the incident logs',
      solution: <String>['report', '=', 'compare_logs(region)'],
      bank: <String>[
        'report',
        '=',
        'compare_logs(region)',
        'forge_outage()',
        'close_ticket()',
      ],
    ),
  ];

  // ── Text styles ──

  final TextStyle _tokenStyle = GoogleFonts.spaceMono(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  final TextPaint _titlePaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFF7BD49E),
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );

  final TextPaint _objectivePaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFE7FFF0),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  );

  final TextPaint _labelPaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFF5A9E76),
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    ),
  );

  final TextPaint _badgePaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFE7FFF0),
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );

  final TextPaint _statusPaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFE8FFF0),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );

  final TextPaint _buttonPaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFFFF6F2),
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );

  final TextPaint _victoryTitlePaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFE7FFF0),
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );

  final TextPaint _victoryBodyPaint = TextPaint(
    style: GoogleFonts.spaceMono(
      color: const Color(0xFFA6E7BC),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.18,
    ),
  );

  // ── State ──

  final List<int> _selectedIndices = <int>[];
  int _roundIndex = 0;
  int _mistakes = 0;
  double _statusTimer = 0;
  double _lockTimer = 0;
  double _victoryDelay = 0;
  bool _locked = false;
  bool _won = false;
  bool _finishTriggered = false;
  bool _pendingAdvance = false;
  String _status = 'Tap blocks in order to build the command.';
  Color _statusColor = const Color(0xFF1F8B54);

  // ── Layout ──

  // Terminal.png frame (the window chrome)
  Rect get _frameRect => const Rect.fromLTWH(90, 30, 1100, 650);

  // The screen area below the terminal title bar (opaque black content area)
  Rect get _screenRect => Rect.fromLTWH(
    _frameRect.left + 4,
    _frameRect.top + 100,
    _frameRect.width - 8,
    _frameRect.height - 106,
  );

  // Command line panel
  Rect get _commandRect => Rect.fromLTWH(
    _screenRect.left + 16,
    _screenRect.top + 90,
    _screenRect.width - 32,
    90,
  );

  // Area where command tokens are laid out
  Rect get _commandTokenArea => Rect.fromLTWH(
    _commandRect.left + 16,
    _commandRect.top + 16,
    _commandRect.width - 32,
    _commandRect.height - 32,
  );

  // Bank panel
  Rect get _bankRect => Rect.fromLTWH(
    _screenRect.left + 16,
    _commandRect.bottom + 30,
    _screenRect.width - 32,
    186,
  );

  // Area where bank tokens are laid out
  Rect get _bankTokenArea => Rect.fromLTWH(
    _bankRect.left + 16,
    _bankRect.top + 16,
    _bankRect.width - 32,
    _bankRect.height - 32,
  );

  Rect get _resetButton => Rect.fromLTWH(
    _screenRect.right - 148,
    _bankRect.bottom + 14,
    130,
    38,
  );

  Rect get _statusRect => Rect.fromLTWH(
    _screenRect.left + 16,
    _bankRect.bottom + 16,
    _screenRect.width - 180,
    34,
  );

  _CodeRound get _currentRound => _rounds[_roundIndex];

  // ── Update ──

  @override
  void update(double dt) {
    super.update(dt);

    if (_statusTimer > 0) {
      _statusTimer = (_statusTimer - dt).clamp(0, double.infinity).toDouble();
    }

    if (_won) {
      _victoryDelay = (_victoryDelay - dt).clamp(0, double.infinity).toDouble();
      if (_victoryDelay == 0 && !_finishTriggered) {
        _finishTriggered = true;
        onWin();
      }
      return;
    }

    if (_lockTimer > 0) {
      _lockTimer = (_lockTimer - dt).clamp(0, double.infinity).toDouble();
      if (_lockTimer == 0) {
        _locked = false;
        if (_pendingAdvance) {
          _pendingAdvance = false;
          _advanceRound();
        }
      }
    }
  }

  // ── Render ──

  @override
  void render(Canvas canvas) {
    // 1. Dim overlay so room is visible but darkened
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF000000).withValues(alpha: 0.6),
    );

    // 2. Terminal window frame (title bar + chrome)
    paintImage(
      canvas: canvas,
      rect: _frameRect,
      image: game.images.fromCache('props/terminal.png'),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );

    // 3. Opaque black screen area (covers the prompt text in terminal.png)
    canvas.drawRRect(
      RRect.fromRectAndRadius(_screenRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0A0A0A),
    );

    // 4. Subtle CRT scanlines
    canvas.save();
    canvas.clipRect(_screenRect);
    for (var y = _screenRect.top; y < _screenRect.bottom; y += 3) {
      canvas.drawLine(
        Offset(_screenRect.left, y),
        Offset(_screenRect.right, y),
        Paint()..color = const Color(0xFF1A3020).withValues(alpha: 0.12),
      );
    }
    canvas.restore();

    _renderHeader(canvas);
    _renderCommand(canvas);
    _renderBank(canvas);
    _renderFooter(canvas);

    if (_won) {
      _renderVictory(canvas);
    }
  }

  void _renderHeader(Canvas canvas) {
    // Title
    _titlePaint.render(
      canvas,
      'BRODAFLIX REMOTE OPS',
      Vector2(_screenRect.left + 20, _screenRect.top + 14),
    );

    // Objective
    _objectivePaint.render(
      canvas,
      '// ${_currentRound.objective}',
      Vector2(_screenRect.left + 20, _screenRect.top + 40),
    );

    // STEP badge
    _drawBadge(
      canvas,
      rect: Rect.fromLTWH(
        _screenRect.right - 250,
        _screenRect.top + 14,
        112,
        30,
      ),
      label: 'STEP ${_roundIndex + 1}/${_rounds.length}',
      color: const Color(0xFF143D2A),
    );

    // ERR badge
    _drawBadge(
      canvas,
      rect: Rect.fromLTWH(
        _screenRect.right - 128,
        _screenRect.top + 14,
        108,
        30,
      ),
      label: 'ERR $_mistakes',
      color: _mistakes > 0
          ? const Color(0xFF6B2E28)
          : const Color(0xFF3A2420),
    );
  }

  void _renderCommand(Canvas canvas) {
    // Section label
    _labelPaint.render(
      canvas,
      'COMMAND:',
      Vector2(_commandRect.left + 4, _commandRect.top - 18),
    );

    // Panel
    final rRect =
        RRect.fromRectAndRadius(_commandRect, const Radius.circular(10));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFF111E16));
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = const Color(0xFF3CDA73).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Placed tokens
    for (final layout in _selectedLayouts()) {
      _drawTokenChip(
        canvas,
        layout.rect,
        layout.label,
        fill: const Color(0xFF1C5236),
        stroke: const Color(0xFF49DE84),
        textColor: const Color(0xFFD0FFE0),
      );
    }

    // Empty slots
    for (
      var i = _selectedIndices.length;
      i < _currentRound.solution.length;
      i++
    ) {
      final rect = _placeholderRectFor(i);
      final isNext = i == _selectedIndices.length;
      _drawSlot(canvas, rect, isNext: isNext);
    }
  }

  void _renderBank(Canvas canvas) {
    // Section label
    _labelPaint.render(
      canvas,
      'BLOCKS:',
      Vector2(_bankRect.left + 4, _bankRect.top - 18),
    );

    // Panel
    final rRect =
        RRect.fromRectAndRadius(_bankRect, const Radius.circular(10));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFF0E1A13));

    // Tokens
    for (final layout in _bankLayouts()) {
      if (layout.available) {
        _drawTokenChip(
          canvas,
          layout.rect,
          layout.label,
          fill: const Color(0xFF1A4E30),
          stroke: const Color(0xFF4AE78A),
          textColor: const Color(0xFFE8FFF0),
        );
      } else {
        _drawTokenChip(
          canvas,
          layout.rect,
          layout.label,
          fill: const Color(0xFF0C1A12),
          stroke: const Color(0xFF1C3426),
          textColor: const Color(0xFF3D5C4A),
        );
      }
    }
  }

  void _renderFooter(Canvas canvas) {
    // Status message
    final statusAlpha = _statusTimer > 0 ? 0.22 : 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(_statusRect, const Radius.circular(8)),
      Paint()..color = _statusColor.withValues(alpha: statusAlpha),
    );
    _statusPaint.render(
      canvas,
      '> $_status',
      Vector2(_statusRect.left + 12, _statusRect.top + 7),
    );

    // Reset button
    final resetColor = _selectedIndices.isEmpty
        ? const Color(0xFF3A2420)
        : const Color(0xFF7E352F);
    final resetRRect =
        RRect.fromRectAndRadius(_resetButton, const Radius.circular(10));
    canvas.drawRRect(resetRRect, Paint()..color = resetColor);
    _buttonPaint.render(
      canvas,
      'RESET',
      Vector2(_resetButton.left + 30, _resetButton.top + 8),
    );
  }

  void _renderVictory(Canvas canvas) {
    // Dim the screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(_screenRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0A0A0A).withValues(alpha: 0.88),
    );

    // Victory panel
    final panelRect = Rect.fromCenter(
      center: _screenRect.center,
      width: 620,
      height: 180,
    );
    final rRect =
        RRect.fromRectAndRadius(panelRect, const Radius.circular(16));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFF0D2A1C));
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = const Color(0xFF49DE84)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _victoryTitlePaint.render(
      canvas,
      'DIAGNOSTIC COMPLETE',
      Vector2(panelRect.left + 38, panelRect.top + 30),
    );
    _victoryBodyPaint.render(
      canvas,
      'No server fault found.\nBlue is about to report the bad news.',
      Vector2(panelRect.left + 38, panelRect.top + 80),
    );
  }

  // ── Interaction ──

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (_locked || _won) return;

    final tap = Offset(event.localPosition.x, event.localPosition.y);

    // Tap a placed token to rewind from that point
    for (final layout in _selectedLayouts()) {
      if (layout.rect.contains(tap)) {
        _selectedIndices.removeRange(layout.slotIndex, _selectedIndices.length);
        _setStatus('Rewound to that block.', const Color(0xFF216F93));
        return;
      }
    }

    // Reset button
    if (_resetButton.contains(tap) && _selectedIndices.isNotEmpty) {
      _selectedIndices.clear();
      _setStatus('Line cleared.', const Color(0xFF216F93));
      return;
    }

    // Bank tokens
    for (final layout in _bankLayouts()) {
      if (!layout.available || !layout.rect.contains(tap)) continue;
      _handleTokenTap(layout);
      return;
    }
  }

  void _handleTokenTap(_TokenLayout layout) {
    final expectedToken = _currentRound.solution[_selectedIndices.length];
    if (layout.label != expectedToken) {
      _mistakes += 1;
      _locked = true;
      _lockTimer = 0.18;
      MinigameSfx.playBomb();
      _setStatus('Wrong block.', const Color(0xFFAA514A));
      return;
    }

    _selectedIndices.add(layout.bankIndex);
    MinigameSfx.playSlice();

    if (_selectedIndices.length == _currentRound.solution.length) {
      _locked = true;
      _pendingAdvance = true;
      _lockTimer = 0.7;
      _setStatus(
        _roundIndex == _rounds.length - 1
            ? 'Diagnostics complete.'
            : 'Command accepted.',
        const Color(0xFF1F8B54),
      );
      return;
    }

    _setStatus('Locked in. Next block.', const Color(0xFF1F8B54));
  }

  void _advanceRound() {
    if (_roundIndex == _rounds.length - 1) {
      _won = true;
      _victoryDelay = 1.2;
      MinigameSfx.playWin();
      return;
    }

    _roundIndex += 1;
    _selectedIndices.clear();
    _setStatus('Next command.', const Color(0xFF1F8B54));
  }

  void _setStatus(String text, Color color) {
    _status = text;
    _statusColor = color;
    _statusTimer = 0.8;
  }

  // ── Drawing helpers ──

  void _drawBadge(
    Canvas canvas, {
    required Rect rect,
    required String label,
    required Color color,
  }) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(rRect, Paint()..color = color);
    _badgePaint.render(canvas, label, Vector2(rect.left + 14, rect.top + 7));
  }

  void _drawTokenChip(
    Canvas canvas,
    Rect rect,
    String label, {
    required Color fill,
    required Color stroke,
    required Color textColor,
  }) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rRect, Paint()..color = fill);
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    _drawTokenLabel(canvas, rect, label, color: textColor);
  }

  void _drawSlot(Canvas canvas, Rect rect, {required bool isNext}) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final borderColor = isNext
        ? const Color(0xFF3CDA73).withValues(alpha: 0.55)
        : const Color(0xFF2A5A3E).withValues(alpha: 0.35);
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isNext ? 2.0 : 1.5,
    );
    _drawTokenLabel(
      canvas,
      rect,
      '___',
      color: isNext
          ? const Color(0xFF7FD8A2)
          : const Color(0xFF3D6B50),
    );
  }

  void _drawTokenLabel(
    Canvas canvas,
    Rect rect,
    String label, {
    Color color = const Color(0xFFE6FFF0),
  }) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: _tokenStyle.copyWith(color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 16);

    painter.paint(
      canvas,
      Offset(
        rect.left + ((rect.width - painter.width) / 2),
        rect.top + ((rect.height - painter.height) / 2),
      ),
    );
  }

  // ── Layout helpers ──

  List<_TokenLayout> _bankLayouts() {
    return _layoutTokens(
      labels: _currentRound.bank,
      area: _bankTokenArea,
      availability: List<bool>.generate(
        _currentRound.bank.length,
        (index) => !_selectedIndices.contains(index),
      ),
    );
  }

  List<_SelectedTokenLayout> _selectedLayouts() {
    final labels = _selectedIndices
        .map((index) => _currentRound.bank[index])
        .toList(growable: false);
    return _layoutSelectedTokens(labels, _commandTokenArea);
  }

  Rect _placeholderRectFor(int slotIndex) {
    final layouts = _layoutSelectedTokens(
      _currentRound.solution,
      _commandTokenArea,
    );
    return layouts[slotIndex].rect;
  }

  List<_TokenLayout> _layoutTokens({
    required List<String> labels,
    required Rect area,
    required List<bool> availability,
  }) {
    var x = area.left;
    var y = area.top;
    var rowHeight = 0.0;
    final layouts = <_TokenLayout>[];

    for (var i = 0; i < labels.length; i++) {
      final labelSize = _measureLabel(labels[i]);
      final chipWidth = labelSize.width + 28;

      if (x + chipWidth > area.right && i > 0) {
        x = area.left;
        y += rowHeight + 12;
        rowHeight = 0;
      }

      final rect = Rect.fromLTWH(x, y, chipWidth, 46);
      layouts.add(
        _TokenLayout(
          bankIndex: i,
          label: labels[i],
          rect: rect,
          available: availability[i],
        ),
      );
      x = rect.right + 12;
      if (rect.height > rowHeight) rowHeight = rect.height;
    }

    return layouts;
  }

  List<_SelectedTokenLayout> _layoutSelectedTokens(
    List<String> labels,
    Rect area,
  ) {
    var x = area.left;
    var y = area.top;
    var rowHeight = 0.0;
    final layouts = <_SelectedTokenLayout>[];

    for (var i = 0; i < labels.length; i++) {
      final labelSize = _measureLabel(labels[i]);
      final width = labelSize.width + 28;
      if (x + width > area.right && i > 0) {
        x = area.left;
        y += rowHeight + 12;
        rowHeight = 0;
      }

      final rect = Rect.fromLTWH(x, y, width, 46);
      layouts.add(
        _SelectedTokenLayout(slotIndex: i, label: labels[i], rect: rect),
      );
      x = rect.right + 12;
      if (rect.height > rowHeight) rowHeight = rect.height;
    }

    return layouts;
  }

  Size _measureLabel(String label) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: _tokenStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size;
  }
}

class _CodeRound {
  const _CodeRound({
    required this.objective,
    required this.solution,
    required this.bank,
  });

  final String objective;
  final List<String> solution;
  final List<String> bank;
}

class _TokenLayout {
  const _TokenLayout({
    required this.bankIndex,
    required this.label,
    required this.rect,
    required this.available,
  });

  final int bankIndex;
  final String label;
  final Rect rect;
  final bool available;
}

class _SelectedTokenLayout {
  const _SelectedTokenLayout({
    required this.slotIndex,
    required this.label,
    required this.rect,
  });

  final int slotIndex;
  final String label;
  final Rect rect;
}
