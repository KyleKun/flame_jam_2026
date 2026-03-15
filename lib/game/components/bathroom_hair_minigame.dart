import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';

enum _HairTool { comb, gel, dryer }

class BathroomHairMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, DragCallbacks {
  BathroomHairMinigameComponent({required this.onWin})
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  static const List<_HairTool> _toolOrder = <_HairTool>[
    _HairTool.comb,
    _HairTool.gel,
    _HairTool.dryer,
  ];
  static const double _toolDuration = 1.45;
  static const double _finishDelayDuration = 0.4;

  final VoidCallback onWin;

  final Map<_HairTool, _ToolVisual> _tools = <_HairTool, _ToolVisual>{};
  final Map<int, _ActiveToolDrag> _activeDrags = <int, _ActiveToolDrag>{};

  double _pulseTime = 0;
  int _currentStepIndex = 0;
  double _currentStepProgress = 0;
  double _finishDelay = 0;
  bool _finished = false;
  bool _finishTriggered = false;

  Rect get _stageRect => const Rect.fromLTWH(188, 24, 904, 532);

  Rect get _toolDockRect => const Rect.fromLTWH(188, 568, 904, 140);

  Rect get _portraitRect => const Rect.fromLTWH(294, 44, 692, 692);

  Rect get _headZone => Rect.fromLTWH(
    _portraitRect.left + (_portraitRect.width * 0.34),
    _portraitRect.top + (_portraitRect.height * 0.03),
    _portraitRect.width * 0.32,
    _portraitRect.height * 0.18,
  );

  Rect get _progressHudRect => Rect.fromCenter(
    center: Offset(_headZone.center.dx, _headZone.top + 12),
    width: 312,
    height: 60,
  );

  _HairTool get _currentTool {
    final index = _currentStepIndex.clamp(0, _toolOrder.length - 1);
    return _toolOrder[index];
  }

  double get _overallProgress {
    final completedSteps = _currentStepIndex.clamp(0, _toolOrder.length);
    final currentProgress = _finished ? 0.0 : _currentStepProgress;
    return ((completedSteps + currentProgress) / _toolOrder.length).clamp(
      0.0,
      1.0,
    );
  }

  bool get _isCurrentToolOverHead {
    if (_finished) {
      return false;
    }

    final tool = _tools[_currentTool];
    if (tool == null || !tool.isHeld) {
      return false;
    }

    return _headZone
        .inflate(30)
        .contains(Offset(tool.position.x, tool.position.y));
  }

  @override
  Future<void> onLoad() async {
    _buildTools();
    _resetRun();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
    _updateToolReturn(dt);

    if (_finished) {
      _finishDelay = math.max(0, _finishDelay - dt);
      if (_finishDelay <= 0 && !_finishTriggered) {
        _finishTriggered = true;
        onWin();
      }
      return;
    }

    if (_isCurrentToolOverHead) {
      _currentStepProgress = (_currentStepProgress + (dt / _toolDuration))
          .clamp(0.0, 1.0);
      if (_currentStepProgress >= 1) {
        _completeCurrentTool();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF081A17).withValues(alpha: 0.64),
    );

    _renderStage(canvas);
    _renderPortrait(canvas);
    _renderProgressHud(canvas);
    _renderToolDock(canvas);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_finished) {
      return;
    }

    final point = event.localPosition.clone();
    final tool = _toolAt(point);
    if (tool == null || tool.type != _currentTool) {
      return;
    }

    tool.isHeld = true;
    _activeDrags[event.pointerId] = _ActiveToolDrag(
      tool: tool,
      grabOffset: point - tool.position,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final drag = _activeDrags[event.pointerId];
    if (drag == null || _finished) {
      return;
    }

    final pointer = event.localEndPosition.clone();
    drag.tool.position.setFrom(pointer - drag.grabOffset);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _releasePointer(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _releasePointer(event.pointerId);
  }

  void _buildTools() {
    _tools
      ..clear()
      ..addAll(<_HairTool, _ToolVisual>{
        _HairTool.comb: _ToolVisual(
          type: _HairTool.comb,
          assetPath: 'props/pente.png',
          accent: const Color(0xFF8B551B),
          home: Vector2(340, 638),
          artSize: Vector2(236, 154),
        ),
        _HairTool.gel: _ToolVisual(
          type: _HairTool.gel,
          assetPath: 'props/gel.png',
          accent: const Color(0xFF1D6F8A),
          home: Vector2(640, 638),
          artSize: Vector2(246, 154),
        ),
        _HairTool.dryer: _ToolVisual(
          type: _HairTool.dryer,
          assetPath: 'props/secador.png',
          accent: const Color(0xFF954A22),
          home: Vector2(940, 638),
          artSize: Vector2(268, 182),
        ),
      });
  }

  void _resetRun() {
    _pulseTime = 0;
    _currentStepIndex = 0;
    _currentStepProgress = 0;
    _finishDelay = 0;
    _finished = false;
    _finishTriggered = false;
    _activeDrags.clear();
    for (final tool in _tools.values) {
      tool
        ..position.setFrom(tool.home)
        ..isHeld = false;
    }
  }

  void _updateToolReturn(double dt) {
    for (final tool in _tools.values) {
      if (tool.isHeld) {
        continue;
      }

      final delta = tool.home - tool.position;
      if (delta.length < 0.2) {
        tool.position.setFrom(tool.home);
        continue;
      }

      tool.position.add(delta * math.min(1.0, dt * 10));
    }
  }

  void _completeCurrentTool() {
    final completedTool = _currentTool;
    _releaseTool(completedTool);
    MinigameSfx.playSlice();

    _currentStepIndex += 1;
    if (_currentStepIndex >= _toolOrder.length) {
      _currentStepProgress = 1;
      _finished = true;
      _finishDelay = _finishDelayDuration;
      MinigameSfx.playWin();
      return;
    }

    _currentStepProgress = 0;
  }

  void _releasePointer(int pointerId) {
    final drag = _activeDrags.remove(pointerId);
    if (drag == null) {
      return;
    }

    drag.tool.isHeld = false;
  }

  void _releaseTool(_HairTool toolType) {
    for (final entry in _activeDrags.entries.toList()) {
      if (entry.value.tool.type == toolType) {
        _releasePointer(entry.key);
      }
    }
  }

  void _renderStage(Canvas canvas) {
    final shadowRect = _stageRect.shift(const Offset(0, 12));
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(44)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    final stage = RRect.fromRectAndRadius(
      _stageRect,
      const Radius.circular(44),
    );
    canvas.drawRRect(stage, Paint()..color = const Color(0xFFF7EAD7));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _stageRect.deflate(12),
        const Radius.circular(34),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      stage,
      Paint()
        ..color = const Color(0xFF173730)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          _stageRect.left + 28,
          _stageRect.top + 18,
          _stageRect.width - 56,
          3,
        ),
        const Radius.circular(999),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }

  void _renderPortrait(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: _portraitRect,
      image: game.images.fromCache('chars/big2.png'),
      fit: BoxFit.contain,
      opacity: 1 - _overallProgress,
      filterQuality: FilterQuality.medium,
    );

    paintImage(
      canvas: canvas,
      rect: _portraitRect,
      image: game.images.fromCache('chars/big.png'),
      fit: BoxFit.contain,
      opacity: _overallProgress,
      filterQuality: FilterQuality.medium,
    );
  }

  void _renderProgressHud(Canvas canvas) {
    final hud = RRect.fromRectAndRadius(
      _progressHudRect,
      const Radius.circular(24),
    );
    final barRect = Rect.fromLTWH(
      _progressHudRect.left + 18,
      _progressHudRect.top + 14,
      _progressHudRect.width - 36,
      14,
    );
    final bar = RRect.fromRectAndRadius(barRect, const Radius.circular(999));
    const progressColor = Color(0xFFE7C86B);

    canvas.drawRRect(
      hud,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      hud,
      Paint()..color = const Color(0xFFFFF6E8).withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      hud,
      Paint()
        ..color = const Color(0xFFE0CDA8).withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(
      bar,
      Paint()..color = const Color(0xFFE8DDC9).withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      bar,
      Paint()
        ..color = const Color(0xFFD3BE98).withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.save();
    canvas.clipRRect(bar);
    canvas.drawRect(
      Rect.fromLTWH(
        barRect.left,
        barRect.top,
        barRect.width * _currentStepProgress,
        barRect.height,
      ),
      Paint()..color = progressColor.withValues(alpha: 0.94),
    );
    canvas.restore();

    const segmentWidth = 66.0;
    const segmentGap = 10.0;
    const segmentHeight = 6.0;
    final segmentTop = _progressHudRect.bottom - 16;
    final segmentStart =
        _progressHudRect.left +
        ((_progressHudRect.width - ((segmentWidth * 3) + (segmentGap * 2))) /
            2);

    for (var i = 0; i < _toolOrder.length; i++) {
      final rect = Rect.fromLTWH(
        segmentStart + (i * (segmentWidth + segmentGap)),
        segmentTop,
        segmentWidth,
        segmentHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(999)),
        Paint()
          ..color = progressColor.withValues(
            alpha: i <= _currentStepIndex ? 0.94 : 0.26,
          ),
      );
    }
  }

  void _renderToolDock(Canvas canvas) {
    final shadowRect = _toolDockRect.shift(const Offset(0, 10));
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(34)),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    final dock = RRect.fromRectAndRadius(
      _toolDockRect,
      const Radius.circular(34),
    );
    canvas.drawRRect(
      dock,
      Paint()..color = const Color(0xFFFFF7EC).withValues(alpha: 0.97),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _toolDockRect.deflate(12),
        const Radius.circular(26),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.drawRRect(
      dock,
      Paint()
        ..color = const Color(0xFF173730)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final dividerPaint = Paint()
      ..color = const Color(0xFF173730).withValues(alpha: 0.12)
      ..strokeWidth = 2;
    final firstDivider = _toolDockRect.left + (_toolDockRect.width / 3);
    final secondDivider = _toolDockRect.left + ((_toolDockRect.width / 3) * 2);
    canvas.drawLine(
      Offset(firstDivider, _toolDockRect.top + 20),
      Offset(firstDivider, _toolDockRect.bottom - 20),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(secondDivider, _toolDockRect.top + 20),
      Offset(secondDivider, _toolDockRect.bottom - 20),
      dividerPaint,
    );

    for (final tool in _tools.values) {
      _renderTool(canvas, tool);
    }
  }

  void _renderTool(Canvas canvas, _ToolVisual tool) {
    final toolIndex = _toolOrder.indexOf(tool.type);
    final isCompleted = toolIndex < _currentStepIndex;
    final isCurrent = !_finished && tool.type == _currentTool;
    final isLocked = toolIndex > _currentStepIndex;
    final pulse = isCurrent ? (math.sin(_pulseTime * 5.5) * 0.03) : 0.0;
    final scale = tool.isHeld
        ? 1.16
        : isCurrent
        ? 1.08 + pulse
        : isLocked
        ? 0.94
        : 0.97;
    final artRect = Rect.fromCenter(
      center: Offset(tool.position.x, tool.position.y - (isCurrent ? 6 : 0)),
      width: tool.artSize.x * scale,
      height: tool.artSize.y * scale,
    );

    paintImage(
      canvas: canvas,
      rect: artRect,
      image: game.images.fromCache(tool.assetPath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      opacity: isCompleted
          ? 0.38
          : isLocked
          ? 0.42
          : 1,
    );
  }

  _ToolVisual? _toolAt(Vector2 point) {
    final list = _tools.values.toList().reversed;
    for (final tool in list) {
      if (tool.hitRect.contains(Offset(point.x, point.y))) {
        return tool;
      }
    }
    return null;
  }
}

class _ToolVisual {
  _ToolVisual({
    required this.type,
    required this.assetPath,
    required this.accent,
    required this.home,
    required this.artSize,
  }) : position = home.clone();

  final _HairTool type;
  final String assetPath;
  final Color accent;
  final Vector2 home;
  final Vector2 artSize;
  final Vector2 position;
  bool isHeld = false;

  Rect get hitRect => Rect.fromCenter(
    center: Offset(position.x, position.y),
    width: artSize.x + 60,
    height: artSize.y + 46,
  );
}

class _ActiveToolDrag {
  _ActiveToolDrag({required this.tool, required this.grabOffset});

  final _ToolVisual tool;
  final Vector2 grabOffset;
}
