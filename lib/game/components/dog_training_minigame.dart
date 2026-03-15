import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _DogCommand { dead, stay, speak, fetch }

enum _DogPhase { demoPause, showing, playerInput, roundClear }

class DogTrainingMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  static const String _defaultDogAsset = 'props/dog.png';
  static const String _sitDogAsset = 'props/dogsit.png';
  static const String _talkDogAsset = 'props/dogtalk.png';
  static const String _mistakeDogAsset = 'props/dogdie.png';

  DogTrainingMinigameComponent({required this.onWin})
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  final VoidCallback onWin;

  late final SpriteComponent _dog;
  late final SpriteComponent _ball;

  final List<List<_DogCommand>> _rounds = const <List<_DogCommand>>[
    <_DogCommand>[_DogCommand.speak, _DogCommand.stay, _DogCommand.dead],
    <_DogCommand>[
      _DogCommand.fetch,
      _DogCommand.speak,
      _DogCommand.stay,
      _DogCommand.dead,
    ],
    <_DogCommand>[
      _DogCommand.dead,
      _DogCommand.fetch,
      _DogCommand.speak,
      _DogCommand.stay,
      _DogCommand.fetch,
    ],
    <_DogCommand>[
      _DogCommand.stay,
      _DogCommand.speak,
      _DogCommand.fetch,
      _DogCommand.dead,
      _DogCommand.stay,
      _DogCommand.speak,
    ],
    <_DogCommand>[
      _DogCommand.fetch,
      _DogCommand.dead,
      _DogCommand.speak,
      _DogCommand.stay,
      _DogCommand.fetch,
      _DogCommand.speak,
      _DogCommand.dead,
    ],
  ];

  final TextPaint _titleText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF5B360D),
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.4,
    ),
  );
  final TextPaint _scoreText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF5B360D),
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
  final TextPaint _commandTitleText = TextPaint(
    style: GoogleFonts.sniglet(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.1,
    ),
  );
  final TextPaint _feedbackText = TextPaint(
    style: GoogleFonts.sniglet(
      color: Colors.white,
      fontSize: 28,
      letterSpacing: 1.2,
    ),
  );
  final TextPaint _bubbleText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF6C4316),
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );
  final TextPaint _resultText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF5B360D),
      fontSize: 46,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
    ),
  );
  final TextPaint _resultBodyText = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF7A4A13),
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.22,
    ),
  );

  _DogPhase _phase = _DogPhase.demoPause;
  _DogCommand? _highlightedCommand;
  _DogCommand? _currentAction;

  int _roundIndex = 0;
  int _inputIndex = 0;
  int _showIndex = 0;
  int _mistakes = 0;
  int _treats = 0;
  double _phaseTimer = 0.9;
  double _highlightTimer = 0;
  double _feedbackTimer = 0;
  double _dogActionTimer = 0;
  double _dogActionDuration = 0.45;
  double _ballFlightTimer = 0;
  double _ballFlightDuration = 0.48;
  double _woofBubbleTimer = 0;
  double _mistakePoseTimer = 0;
  double _time = 0;
  double _victoryDelay = 0;
  bool _won = false;
  bool _finishTriggered = false;
  String _feedback = 'Get ready...';
  Color _feedbackColor = const Color(0xFFC57B1B);
  String _activeDogSpritePath = _defaultDogAsset;

  List<_DogCommand> get _currentSequence => _rounds[_roundIndex];

  Rect get _stageRect => const Rect.fromLTWH(58, 60, 1164, 600);

  Rect get _feedbackRect => const Rect.fromLTWH(80, 596, 1120, 58);

  @override
  Future<void> onLoad() async {
    _dog = SpriteComponent(
      sprite: Sprite(game.images.fromCache(_defaultDogAsset)),
      position: Vector2(360, 516),
      size: Vector2(260, 254),
      anchor: Anchor.bottomCenter,
      priority: 2,
    );

    _ball = SpriteComponent(
      sprite: Sprite(game.images.fromCache('props/ball.png')),
      position: Vector2(460, 510),
      size: Vector2.all(52),
      anchor: Anchor.center,
      priority: 1,
    );
    _ball.opacity = 0;

    await addAll([_ball, _dog]);
    _startRound(0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
    if (_highlightTimer > 0) {
      _highlightTimer = math.max(0, _highlightTimer - dt);
      if (_highlightTimer == 0 && _phase != _DogPhase.showing) {
        _highlightedCommand = null;
      }
    }
    if (_feedbackTimer > 0) {
      _feedbackTimer = math.max(0, _feedbackTimer - dt);
    }
    if (_dogActionTimer > 0) {
      _dogActionTimer = math.max(0, _dogActionTimer - dt);
      if (_dogActionTimer == 0) {
        _currentAction = null;
      }
    }
    if (_ballFlightTimer > 0) {
      _ballFlightTimer = math.max(0, _ballFlightTimer - dt);
    }
    if (_woofBubbleTimer > 0) {
      _woofBubbleTimer = math.max(0, _woofBubbleTimer - dt);
    }
    if (_mistakePoseTimer > 0) {
      _mistakePoseTimer = math.max(0, _mistakePoseTimer - dt);
    }

    _updateDogSprite();
    _updateBallSprite();

    if (_won) {
      _victoryDelay = math.max(0, _victoryDelay - dt);
      if (_victoryDelay == 0 && !_finishTriggered) {
        _finishTriggered = true;
        onWin();
      }
      return;
    }

    _phaseTimer = math.max(0, _phaseTimer - dt);
    switch (_phase) {
      case _DogPhase.demoPause:
        if (_phaseTimer == 0) {
          _phase = _DogPhase.showing;
          _showIndex = 0;
          _playCommand(_currentSequence[_showIndex], demo: true);
          _phaseTimer = 0.72;
        }
        break;
      case _DogPhase.showing:
        if (_phaseTimer == 0) {
          if (_showIndex < _currentSequence.length - 1) {
            _showIndex += 1;
            _playCommand(_currentSequence[_showIndex], demo: true);
            _phaseTimer = 0.72;
          } else {
            _highlightedCommand = null;
            _phase = _DogPhase.playerInput;
            _inputIndex = 0;
            _setFeedback('Your turn!', const Color(0xFF2D88B8));
          }
        }
        break;
      case _DogPhase.playerInput:
        break;
      case _DogPhase.roundClear:
        if (_phaseTimer == 0) {
          if (_roundIndex == _rounds.length - 1) {
            _won = true;
            _victoryDelay = 1.2;
            MinigameSfx.playWin();
          } else {
            _startRound(_roundIndex + 1);
          }
        }
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF251405).withValues(alpha: 0.54),
    );

    _renderStage(canvas);
    super.render(canvas);
    _renderHud(canvas);
    _renderCommandPads(canvas);
    _renderFeedback(canvas);

    if (_woofBubbleTimer > 0) {
      _renderWoofBubble(canvas);
    }
    if (_won) {
      _renderVictoryCard(canvas);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (_phase != _DogPhase.playerInput || _won) {
      return;
    }

    final tap = Offset(event.localPosition.x, event.localPosition.y);
    for (final command in _DogCommand.values) {
      if (!_commandRect(command).contains(tap)) {
        continue;
      }

      final expected = _currentSequence[_inputIndex];
      if (command == expected) {
        _playCommand(command, demo: false);
        _inputIndex += 1;
        if (_inputIndex == _currentSequence.length) {
          _treats += 1;
          _phase = _DogPhase.roundClear;
          _phaseTimer = 1.8;
          _setFeedback('Round clear!', const Color(0xFF3DA15B));
        } else {
          _setFeedback('Good!', const Color(0xFF2D88B8));
        }
      } else {
        _mistakes += 1;
        _highlightedCommand = command;
        _highlightTimer = 0.35;
        _phase = _DogPhase.demoPause;
        _phaseTimer = 1.0;
        _inputIndex = 0;
        _currentAction = null;
        _dogActionTimer = 0;
        _mistakePoseTimer = 0.42;
        _setFeedback('Wrong! Repeating...', const Color(0xFFD35A45));
      }
      return;
    }
  }

  void _startRound(int index) {
    _roundIndex = index;
    _inputIndex = 0;
    _showIndex = 0;
    _phase = _DogPhase.demoPause;
    _phaseTimer = 0.9;
    _highlightedCommand = null;
    _setFeedback('Round ${index + 1}. Watch!', const Color(0xFFC57B1B));
  }

  void _playCommand(_DogCommand command, {required bool demo}) {
    _highlightedCommand = command;
    _highlightTimer = demo ? 0.58 : 0.34;
    _currentAction = command;
    _dogActionDuration = command == _DogCommand.fetch ? 0.5 : 0.42;
    _dogActionTimer = _dogActionDuration;

    if (command == _DogCommand.fetch) {
      _ballFlightDuration = 0.48;
      _ballFlightTimer = _ballFlightDuration;
    }
    if (command == _DogCommand.speak) {
      _woofBubbleTimer = 0.6;
    }
  }

  void _setFeedback(String text, Color color) {
    _feedback = text;
    _feedbackColor = color;
    _feedbackTimer = 1.6;
  }

  void _updateDogSprite() {
    _setDogSpritePath(_resolveDogSpritePath());

    final idleBob = math.sin(_time * 2.2) * 4;
    var offsetX = 0.0;
    var offsetY = idleBob;
    var angle = 0.0;
    var scaleVal = 1.0;
    var flipY = false;

    if (_currentAction != null && _dogActionDuration > 0) {
      final progress = 1 - (_dogActionTimer / _dogActionDuration);
      final pulse = math.sin(progress * math.pi);

      switch (_currentAction!) {
        case _DogCommand.dead:
          flipY = true;
          offsetY -= 16 * pulse;
          break;
        case _DogCommand.stay:
          offsetY -= 14 * pulse;
          scaleVal = 0.96 + (0.04 * (1 - pulse));
          break;
        case _DogCommand.speak:
          offsetY -= 18 * pulse;
          scaleVal = 1 + (0.08 * pulse);
          angle = -0.04 * pulse;
          break;
        case _DogCommand.fetch:
          offsetX = 64 * pulse;
          offsetY -= 26 * pulse;
          scaleVal = 1.05 + (0.05 * pulse);
          angle = 0.12 * pulse;
          break;
      }
    }

    _dog.angle = angle;
    if (flipY) {
      _dog.scale = Vector2(scaleVal, -scaleVal);
      _dog.position.setValues(
        360 + offsetX,
        516 + offsetY - _dog.size.y * scaleVal,
      );
    } else {
      _dog.scale = Vector2.all(scaleVal);
      _dog.position.setValues(360 + offsetX, 516 + offsetY);
    }
  }

  String _resolveDogSpritePath() {
    if (_mistakePoseTimer > 0) {
      return _mistakeDogAsset;
    }

    switch (_currentAction) {
      case _DogCommand.stay:
        return _sitDogAsset;
      case _DogCommand.speak:
        return _talkDogAsset;
      case _DogCommand.dead:
        return _mistakeDogAsset;
      case null:
      case _DogCommand.fetch:
        return _defaultDogAsset;
    }
  }

  void _setDogSpritePath(String assetPath) {
    if (_activeDogSpritePath == assetPath) {
      return;
    }

    _activeDogSpritePath = assetPath;
    _dog.sprite = Sprite(game.images.fromCache(assetPath));
  }

  void _updateBallSprite() {
    if (_ballFlightTimer <= 0) {
      _ball.opacity = 0;
      return;
    }

    final progress = 1 - (_ballFlightTimer / _ballFlightDuration);
    final x = 460 + (166 * progress);
    final y = 510 - (120 * math.sin(progress * math.pi));

    _ball.opacity = 1;
    _ball.position.setValues(x, y);
    _ball.angle = progress * math.pi * 2;
  }

  void _renderStage(Canvas canvas) {
    final stageRRect = RRect.fromRectAndRadius(
      _stageRect,
      const Radius.circular(32),
    );
    canvas.drawRRect(
      stageRRect,
      Paint()..color = const Color(0xFFFFF5E8).withValues(alpha: 0.97),
    );
    canvas.drawRRect(
      stageRRect,
      Paint()
        ..color = const Color(0xFF6C4316)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final matRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(120, 220, 480, 300),
      const Radius.circular(28),
    );
    canvas.drawRRect(matRect, Paint()..color = const Color(0xFFEAD0A3));
    canvas.drawRRect(
      matRect,
      Paint()
        ..color = const Color(0xFFAA7A3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (var i = 0; i < 5; i++) {
      final y = 262 + (i * 46);
      canvas.drawLine(
        Offset(146, y.toDouble()),
        Offset(576, y.toDouble()),
        Paint()..color = const Color(0xFFC89A4E).withValues(alpha: 0.28),
      );
    }
  }

  void _renderHud(Canvas canvas) {
    _titleText.render(canvas, 'DOG TRAINING', Vector2(92, 86));
    _scoreText.render(
      canvas,
      'ROUND ${_roundIndex + 1}/${_rounds.length}',
      Vector2(92, 130),
    );
  }

  void _renderCommandPads(Canvas canvas) {
    for (final command in _DogCommand.values) {
      final rect = _commandRect(command);
      final palette = _paletteFor(command);
      final isHighlighted =
          _highlightedCommand == command && _highlightTimer > 0;

      final fill = isHighlighted
          ? Color.lerp(palette.base, Colors.white, 0.48)!
          : palette.base;
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
      if (isHighlighted) {
        // Glow behind the highlighted pad.
        canvas.drawRRect(
          rRect.inflate(6),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
      canvas.drawRRect(rRect, Paint()..color = fill);
      canvas.drawRRect(
        rRect,
        Paint()
          ..color = isHighlighted ? Colors.white : palette.stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 5 : 3,
      );

      _commandTitleText.render(
        canvas,
        _labelFor(command),
        Vector2(rect.left + 28, rect.top + 34),
      );
    }
  }

  void _renderFeedback(Canvas canvas) {
    final rRect = RRect.fromRectAndRadius(
      _feedbackRect,
      const Radius.circular(20),
    );
    final alpha = _feedbackTimer > 0 ? 1.0 : 0.88;
    canvas.drawRRect(
      rRect,
      Paint()..color = _feedbackColor.withValues(alpha: alpha),
    );
    _feedbackText.render(
      canvas,
      _feedback,
      Vector2(_feedbackRect.center.dx, _feedbackRect.center.dy - 2),
      anchor: Anchor.center,
    );
  }

  void _renderWoofBubble(Canvas canvas) {
    final bubbleRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(218, 212, 140, 60),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      bubbleRect,
      Paint()..color = Colors.white.withValues(alpha: 0.94),
    );
    _bubbleText.render(canvas, 'WOOF!', Vector2(246, 226));
  }

  void _renderVictoryCard(Canvas canvas) {
    // Full-screen dim overlay so card sits above everything.
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF251405).withValues(alpha: 0.52),
    );

    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(328, 218, 624, 268),
      const Radius.circular(30),
    );
    canvas.drawRRect(
      cardRect,
      Paint()..color = const Color(0xFFFFFBF4).withValues(alpha: 0.98),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = const Color(0xFFD4861C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _resultText.render(canvas, 'TRAINING DONE!', Vector2(430, 274));
    _resultBodyText.render(
      canvas,
      'Mistakes: $_mistakes',
      Vector2(640, 360),
      anchor: Anchor.center,
    );
  }

  Rect _commandRect(_DogCommand command) {
    switch (command) {
      case _DogCommand.dead:
        return const Rect.fromLTWH(700, 236, 214, 114);
      case _DogCommand.stay:
        return const Rect.fromLTWH(948, 236, 214, 114);
      case _DogCommand.speak:
        return const Rect.fromLTWH(700, 384, 214, 114);
      case _DogCommand.fetch:
        return const Rect.fromLTWH(948, 384, 214, 114);
    }
  }

  _CommandPalette _paletteFor(_DogCommand command) {
    switch (command) {
      case _DogCommand.dead:
        return const _CommandPalette(
          base: Color(0xFF2D88B8),
          stroke: Color(0xFF15526F),
        );
      case _DogCommand.stay:
        return const _CommandPalette(
          base: Color(0xFF8A5CC5),
          stroke: Color(0xFF4F3085),
        );
      case _DogCommand.speak:
        return const _CommandPalette(
          base: Color(0xFFD56A43),
          stroke: Color(0xFF8A3318),
        );
      case _DogCommand.fetch:
        return const _CommandPalette(
          base: Color(0xFF38A55D),
          stroke: Color(0xFF176739),
        );
    }
  }

  String _labelFor(_DogCommand command) {
    switch (command) {
      case _DogCommand.dead:
        return 'DEAD';
      case _DogCommand.stay:
        return 'STAY';
      case _DogCommand.speak:
        return 'SPEAK';
      case _DogCommand.fetch:
        return 'FETCH';
    }
  }
}

class _CommandPalette {
  const _CommandPalette({required this.base, required this.stroke});

  final Color base;
  final Color stroke;
}
