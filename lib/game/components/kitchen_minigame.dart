import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';

class KitchenMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, DragCallbacks {
  static const int minimumScore = 100;
  static const double minimumRoundDuration = 60;
  static const double _trailLifetime = 0.17;

  KitchenMinigameComponent({required this.onWin, required this.onLose})
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  final VoidCallback onWin;
  final ValueChanged<int> onLose;

  final math.Random _random = math.Random();
  final Set<FruitTargetComponent> _targets = <FruitTargetComponent>{};
  final Map<int, Vector2> _lastSlashPointByPointer = <int, Vector2>{};
  final Map<int, int> _strokeIdByPointer = <int, int>{};
  final List<_SlashTrailPoint> _trailPoints = <_SlashTrailPoint>[];

  final TextPaint _titleText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF1A1028),
      fontSize: 30,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
    ),
  );
  final TextPaint _bodyText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF4A4458),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
  );
  final TextPaint _scoreText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF1A1028),
      fontSize: 26,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
    ),
  );
  final TextPaint _hintText = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
  );
  final TextPaint _timerText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF1A1028),
      fontSize: 22,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.2,
    ),
  );
  static const _fruitAssets = <String>[
    'props/morango.png',
    'props/abacaxi.png',
    'props/banana.png',
    'props/laranja.png',
    'props/melancia.png',
  ];

  int _score = 0;
  double _spawnCooldown = 0.55;
  double _hintTimer = 2.6;
  double _flashAlpha = 0;
  double _elapsedTime = 0;
  double _stunTimer = 0;
  Color _flashColor = Colors.white;
  double _shakeTime = 0;
  bool _won = false;
  bool _lost = false;
  int _nextStrokeId = 0;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.black.withValues(alpha: 0.2),
        priority: 0,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hintTimer > 0) {
      _hintTimer = math.max(0, _hintTimer - dt);
    }

    if (_trailPoints.isNotEmpty) {
      for (final point in _trailPoints) {
        point.age += dt;
      }
      _trailPoints.removeWhere((point) => point.age >= _trailLifetime);
    }

    if (_flashAlpha > 0) {
      _flashAlpha = math.max(0, _flashAlpha - dt * 2.6);
    }

    if (_shakeTime > 0) {
      _shakeTime = math.max(0, _shakeTime - dt);
    }

    if (_stunTimer > 0) {
      _stunTimer = math.max(0, _stunTimer - dt);
    }

    if (_won || _lost) {
      return;
    }

    _elapsedTime += dt;

    _spawnCooldown -= dt;
    if (_spawnCooldown <= 0) {
      _spawnBurst();
      final intensity = (_elapsedTime / minimumRoundDuration).clamp(0.0, 1.0);
      _spawnCooldown = 0.94 - (intensity * 0.26) + _random.nextDouble() * 0.14;
    }

    if (_elapsedTime >= minimumRoundDuration) {
      if (_score >= minimumScore) {
        _completeMinigame();
      } else {
        _failMinigame();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    final shakeStrength = _shakeTime <= 0 ? 0 : 14 * (_shakeTime / 0.22);
    if (shakeStrength > 0) {
      canvas.translate(
        (_random.nextDouble() - 0.5) * shakeStrength,
        (_random.nextDouble() - 0.5) * shakeStrength,
      );
    }

    super.render(canvas);
    _renderSlashTrail(canvas);
    _renderHud(canvas);

    if (_flashAlpha > 0) {
      final flashPaint = Paint()
        ..color = _flashColor.withValues(alpha: _flashAlpha);
      canvas.drawRect(size.toRect(), flashPaint);
    }
    canvas.restore();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final point = event.localPosition.clone();
    final strokeId = ++_nextStrokeId;
    _lastSlashPointByPointer[event.pointerId] = point;
    _strokeIdByPointer[event.pointerId] = strokeId;
    _trailPoints.add(_SlashTrailPoint(position: point, strokeId: strokeId));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final current = event.localEndPosition.clone();
    final previous =
        _lastSlashPointByPointer[event.pointerId] ??
        event.localStartPosition.clone();
    final strokeId = _strokeIdByPointer[event.pointerId] ?? ++_nextStrokeId;

    _lastSlashPointByPointer[event.pointerId] = current;
    _strokeIdByPointer[event.pointerId] = strokeId;

    if (_won || _lost) {
      return;
    }

    if (previous.distanceTo(current) < 6) {
      return;
    }

    _appendTrail(previous, current, strokeId);

    if (_stunTimer > 0) {
      return;
    }

    _sliceAcrossPath(previous, current);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _lastSlashPointByPointer.remove(event.pointerId);
    _strokeIdByPointer.remove(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _lastSlashPointByPointer.remove(event.pointerId);
    _strokeIdByPointer.remove(event.pointerId);
  }

  void _renderHud(Canvas canvas) {
    // --- Top-left info card ---
    final topCard = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 24, 440, 120),
      const Radius.circular(20),
    );
    canvas.drawRRect(topCard, Paint()..color = Colors.white);
    canvas.drawRRect(
      topCard,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _titleText.render(canvas, 'FRUITS FOR LUNCH', Vector2(48, 38));
    _bodyText.render(
      canvas,
      '1 fruit = 1 point\n1 bomb = -5 points',
      Vector2(48, 76),
    );

    // --- Top-right score card ---
    const scoreCardWidth = 280.0;
    final scoreCard = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1280 - scoreCardWidth - 28, 24, scoreCardWidth, 120),
      const Radius.circular(20),
    );
    canvas.drawRRect(scoreCard, Paint()..color = Colors.white);
    canvas.drawRRect(
      scoreCard,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const scoreX = 1280 - scoreCardWidth - 28 + 20;
    _timerText.render(canvas, _buildTimerLabel(), Vector2(scoreX, 36));
    _scoreText.render(
      canvas,
      'CUTS $_score/$minimumScore',
      Vector2(scoreX, 68),
    );

    const progressWidth = scoreCardWidth - 40;
    final progressRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(scoreX, 106, progressWidth, 18),
      const Radius.circular(999),
    );
    canvas.drawRRect(progressRect, Paint()..color = const Color(0xFFE8E4EF));

    final fillRatio = (_score / minimumScore).clamp(0, 1).toDouble();
    if (fillRatio > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(scoreX, 106, progressWidth * fillRatio, 18),
        const Radius.circular(999),
      );
      canvas.drawRRect(fillRect, Paint()..color = const Color(0xFFe94560));
    }

    if (_hintTimer > 0 && !_won) {
      final hintRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(350, 620, 580, 58),
        const Radius.circular(20),
      );
      canvas.drawRRect(
        hintRect,
        Paint()..color = Colors.black.withValues(alpha: 0.45),
      );
      _hintText.render(
        canvas,
        'Hold the mouse button and drag to cut.',
        Vector2(392, 637),
      );
    }
  }

  void _spawnBurst() {
    final intensity = (_elapsedTime / minimumRoundDuration).clamp(0.0, 1.0);
    final count = intensity > 0.55
        ? 3 + _random.nextInt(2)
        : 2 + _random.nextInt(2);
    final shouldAddBomb = _random.nextDouble() < 0.28;
    final bombIndex = shouldAddBomb ? _random.nextInt(count) : -1;

    for (var i = 0; i < count; i++) {
      final spawnX = 130 + _random.nextDouble() * (size.x - 260);
      final launchHeight = 116 + _random.nextDouble() * 28;
      final horizontalPush = spawnX < size.x / 2
          ? 110 + _random.nextDouble() * 170
          : -110 - _random.nextDouble() * 170;

      final isBomb = i == bombIndex;
      final assetPath = isBomb
          ? 'props/bomb.png'
          : _fruitAssets[_random.nextInt(_fruitAssets.length)];

      final target = FruitTargetComponent(
        assetPath: assetPath,
        isBomb: isBomb,
        displayHeight: launchHeight,
        position: Vector2(spawnX, size.y + 70),
        velocity: Vector2(
          horizontalPush + (_random.nextDouble() - 0.5) * 120,
          -890 - _random.nextDouble() * 260,
        ),
        rotationSpeed: (_random.nextDouble() - 0.5) * 4.8,
        onMissed: _handleMissedFruit,
        onSliced: _handleSlicedTarget,
      );
      _targets.add(target);
      add(target);
    }
  }

  void _handleSlicedTarget(FruitTargetComponent target) {
    _targets.remove(target);

    if (target.isBomb) {
      _score = math.max(0, _score - 5);
      MinigameSfx.playBomb();
      _hintTimer = 0;
      _stunTimer = 0.35;
      _flashColor = const Color(0xFFFF4D6D);
      _flashAlpha = 0.28;
      _shakeTime = 0.22;
      _spawnBombBurst(target.position);
      add(
        FloatingTextComponent(
          text: '-5',
          color: const Color(0xFFFF2244),
          position: target.position.clone(),
        ),
      );
      return;
    }

    _score++;
    MinigameSfx.playSlice();
    _spawnFruitBurst(target);
    add(
      FloatingTextComponent(
        text: '+1',
        color: Colors.white,
        position: target.position.clone(),
      ),
    );

    if (_elapsedTime >= minimumRoundDuration && _score >= minimumScore) {
      _completeMinigame();
    }
  }

  void _handleMissedFruit(FruitTargetComponent target) {
    _targets.remove(target);
    if (_won || target.isBomb) {
      return;
    }

    add(
      FloatingTextComponent(
        text: 'MISS',
        color: const Color(0xFFFFD1A6),
        position: target.position.clone(),
      ),
    );
  }

  void _completeMinigame() {
    if (_won || _lost) {
      return;
    }

    _won = true;
    _hintTimer = 0;
    _flashColor = Colors.white;
    _flashAlpha = 0.24;
    MinigameSfx.playWin();

    for (final target in _targets.toList()) {
      target.freeze();
      target.removeFromParent();
    }
    _targets.clear();

    for (var i = 0; i < 36; i++) {
      final color = <Color>[
        const Color(0xFFFFD166),
        const Color(0xFFFF7A59),
        const Color(0xFF5DD39E),
        const Color(0xFF74C0FC),
      ][_random.nextInt(4)];

      add(
        BurstParticleComponent(
          position: Vector2(
            540 + (_random.nextDouble() - 0.5) * 220,
            350 + (_random.nextDouble() - 0.5) * 110,
          ),
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 520,
            -80 - _random.nextDouble() * 240,
          ),
          color: color,
          radius: 5 + _random.nextDouble() * 6,
          lifetime: 0.8 + _random.nextDouble() * 0.5,
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (isMounted) {
        removeFromParent();
      }
      onWin();
    });
  }

  void _failMinigame() {
    if (_won || _lost) {
      return;
    }

    _lost = true;
    _hintTimer = 0;
    _flashColor = const Color(0xFFFF4D6D);
    _flashAlpha = 0.22;
    _shakeTime = 0.16;

    for (final target in _targets.toList()) {
      target.freeze();
      target.removeFromParent();
    }
    _targets.clear();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (isMounted) {
        removeFromParent();
      }
      onLose(_score);
    });
  }

  void _spawnFruitBurst(FruitTargetComponent target) {
    final image = game.images.fromCache(target.assetPath);
    final halfSourceSize = Vector2(image.width / 2, image.height.toDouble());

    add(
      FruitHalfComponent(
        assetPath: target.assetPath,
        srcPosition: Vector2.zero(),
        srcSize: halfSourceSize,
        displayHeight: target.displayHeight,
        position: target.position.clone() + Vector2(-12, -4),
        velocity: Vector2(
          -180 - _random.nextDouble() * 120,
          -120 - _random.nextDouble() * 80,
        ),
        rotationSpeed: -2.8 - _random.nextDouble() * 2.0,
      ),
    );
    add(
      FruitHalfComponent(
        assetPath: target.assetPath,
        srcPosition: Vector2(image.width / 2, 0),
        srcSize: halfSourceSize,
        displayHeight: target.displayHeight,
        position: target.position.clone() + Vector2(12, 4),
        velocity: Vector2(
          180 + _random.nextDouble() * 120,
          -120 - _random.nextDouble() * 80,
        ),
        rotationSpeed: 2.8 + _random.nextDouble() * 2.0,
      ),
    );

    final juiceColor = _juiceColorForAsset(target.assetPath);
    for (var i = 0; i < 14; i++) {
      add(
        BurstParticleComponent(
          position: target.position.clone(),
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 480,
            -50 - _random.nextDouble() * 260,
          ),
          color: juiceColor,
          radius: 4 + _random.nextDouble() * 6,
          lifetime: 0.45 + _random.nextDouble() * 0.25,
        ),
      );
    }
  }

  void _spawnBombBurst(Vector2 origin) {
    for (var i = 0; i < 18; i++) {
      add(
        BurstParticleComponent(
          position: origin.clone(),
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 620,
            -20 - _random.nextDouble() * 320,
          ),
          color: i.isEven ? const Color(0xFFFF6B6B) : const Color(0xFFFFD166),
          radius: 4 + _random.nextDouble() * 7,
          lifetime: 0.5 + _random.nextDouble() * 0.4,
        ),
      );
    }

    add(BombPulseComponent(position: origin.clone()));
  }

  Color _juiceColorForAsset(String assetPath) {
    if (assetPath.contains('banana')) {
      return const Color(0xFFFFE066);
    }
    if (assetPath.contains('abacaxi')) {
      return const Color(0xFFFFD43B);
    }
    if (assetPath.contains('laranja') || assetPath.contains('orange')) {
      return const Color(0xFFFF922B);
    }
    if (assetPath.contains('melancia') || assetPath.contains('watermelon')) {
      return const Color(0xFFFF6B8A);
    }
    if (assetPath.contains('morango')) {
      return const Color(0xFFFF4D6D);
    }
    return const Color(0xFFFF6B6B);
  }

  double _distanceFromSegmentToPoint(
    Vector2 start,
    Vector2 end,
    Vector2 point,
  ) {
    final segment = end - start;
    final segmentLengthSquared = segment.length2;
    if (segmentLengthSquared == 0) {
      return point.distanceTo(start);
    }

    final t = ((point - start).dot(segment) / segmentLengthSquared).clamp(
      0.0,
      1.0,
    );
    final projection = start + (segment * t);
    return point.distanceTo(projection);
  }

  void _appendTrail(Vector2 start, Vector2 end, int strokeId) {
    final direction = end - start;
    final distance = direction.length;
    final steps = math.max(1, (distance / 10).ceil());

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final point = start + (direction * t);
      _trailPoints.add(
        _SlashTrailPoint(position: point.clone(), strokeId: strokeId),
      );
    }

    if (_trailPoints.length > 80) {
      _trailPoints.removeRange(0, _trailPoints.length - 80);
    }
  }

  void _sliceAcrossPath(Vector2 start, Vector2 end) {
    final direction = end - start;
    final distance = direction.length;
    final steps = math.max(1, (distance / 18).ceil());
    var previousPoint = start;

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final currentPoint = start + (direction * t);

      for (final target in _targets.toList()) {
        if (!target.isSliceable) {
          continue;
        }
        final hitDistance = _distanceFromSegmentToPoint(
          previousPoint,
          currentPoint,
          target.position,
        );
        if (hitDistance <= target.hitRadius) {
          target.slice();
        }
      }

      previousPoint = currentPoint;
    }
  }

  void _renderSlashTrail(Canvas canvas) {
    if (_trailPoints.length < 2) {
      return;
    }

    for (var i = 1; i < _trailPoints.length; i++) {
      final previous = _trailPoints[i - 1];
      final current = _trailPoints[i];
      if (previous.strokeId != current.strokeId) {
        continue;
      }

      final progress = (math.max(previous.age, current.age) / _trailLifetime)
          .clamp(0.0, 1.0);
      final alpha = 1 - progress;
      final outerWidth = 20 - progress * 11;
      final innerWidth = 8 - progress * 4;

      final glowPaint = Paint()
        ..color = const Color(0x88A6F4FF).withValues(alpha: 0.85 * alpha)
        ..strokeWidth = outerWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..strokeWidth = innerWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        previous.position.toOffset(),
        current.position.toOffset(),
        glowPaint,
      );
      canvas.drawLine(
        previous.position.toOffset(),
        current.position.toOffset(),
        corePaint,
      );
      canvas.drawCircle(
        current.position.toOffset(),
        innerWidth * 0.52,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.9),
      );
    }
  }

  String _buildTimerLabel() {
    final totalSecondsRemaining = math.max(
      0,
      (minimumRoundDuration - _elapsedTime).ceil(),
    );

    if (_elapsedTime >= minimumRoundDuration && _score < minimumScore) {
      return 'OVERTIME';
    }

    final minutes = totalSecondsRemaining ~/ 60;
    final seconds = totalSecondsRemaining % 60;
    return 'TIME ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class FruitTargetComponent extends SpriteComponent
    with HasGameReference<MyGame> {
  FruitTargetComponent({
    required this.assetPath,
    required this.isBomb,
    required this.displayHeight,
    required this.velocity,
    required this.rotationSpeed,
    required this.onMissed,
    required this.onSliced,
    required super.position,
  }) : super(anchor: Anchor.center, priority: 20);

  final String assetPath;
  final bool isBomb;
  final double displayHeight;
  final Vector2 velocity;
  final double rotationSpeed;
  final ValueChanged<FruitTargetComponent> onMissed;
  final ValueChanged<FruitTargetComponent> onSliced;

  bool _resolved = false;

  bool get isSliceable => !_resolved;
  double get hitRadius => math.min(size.x, size.y) * (isBomb ? 0.34 : 0.38);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(assetPath));
    final aspectRatio = sprite!.srcSize.x / sprite!.srcSize.y;
    size = Vector2(displayHeight * aspectRatio, displayHeight);
    scale = Vector2.all(0.84);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.18, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_resolved) {
      return;
    }

    position += velocity * dt;
    velocity.y += 920 * dt;
    angle += rotationSpeed * dt;

    if (position.y > 820 || position.x < -180 || position.x > 1460) {
      _resolved = true;
      onMissed(this);
      removeFromParent();
    }
  }

  void freeze() {
    _resolved = true;
  }

  void slice() {
    if (_resolved) {
      return;
    }

    _resolved = true;
    onSliced(this);
    removeFromParent();
  }
}

class FruitHalfComponent extends SpriteComponent with HasGameReference<MyGame> {
  FruitHalfComponent({
    required this.assetPath,
    required this.srcPosition,
    required this.srcSize,
    required this.displayHeight,
    required this.velocity,
    required this.rotationSpeed,
    required super.position,
  }) : super(anchor: Anchor.center, priority: 18);

  final String assetPath;
  final Vector2 srcPosition;
  final Vector2 srcSize;
  final double displayHeight;
  final Vector2 velocity;
  final double rotationSpeed;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(assetPath),
      srcPosition: srcPosition,
      srcSize: srcSize,
    );
    final aspectRatio = srcSize.x / srcSize.y;
    size = Vector2(displayHeight * aspectRatio, displayHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    velocity.y += 980 * dt;
    angle += rotationSpeed * dt;
    opacity = math.max(0, opacity - dt * 1.1);

    if (opacity <= 0 || position.y > 860) {
      removeFromParent();
    }
  }
}

class BurstParticleComponent extends PositionComponent {
  BurstParticleComponent({
    required super.position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.lifetime,
  }) : super(anchor: Anchor.center, priority: 26);

  final Vector2 velocity;
  final Color color;
  final double radius;
  final double lifetime;

  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _age += dt;
    position += velocity * dt;
    velocity.y += 720 * dt;

    if (_age >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_age / lifetime).clamp(0, 1).toDouble();
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius * (1 - progress * 0.4), paint);
  }
}

class FloatingTextComponent extends PositionComponent {
  FloatingTextComponent({
    required this.text,
    required this.color,
    required super.position,
  }) : super(anchor: Anchor.center, priority: 30);

  final String text;
  final Color color;

  double _age = 0;
  static const _lifetime = 0.65;

  @override
  void render(Canvas canvas) {
    final progress = (_age / _lifetime).clamp(0, 1).toDouble();
    TextPaint(
      style: TextStyle(
        color: color.withValues(alpha: 1 - progress),
        fontSize: 26 + progress * 6,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    ).render(canvas, text, Vector2.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);

    _age += dt;
    position += Vector2(0, -90 * dt);

    if (_age >= _lifetime) {
      removeFromParent();
    }
  }
}

class BombPulseComponent extends PositionComponent {
  BombPulseComponent({required super.position})
    : super(anchor: Anchor.center, priority: 24);

  double _age = 0;
  static const _lifetime = 0.35;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_age / _lifetime).clamp(0, 1).toDouble();
    final radius = 20 + progress * 110;
    final paint = Paint()
      ..color = const Color(0xFFFFF1C4).withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 - progress * 5;
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}

class _SlashTrailPoint {
  _SlashTrailPoint({required this.position, required this.strokeId});

  final Vector2 position;
  final int strokeId;
  double age = 0;
}
