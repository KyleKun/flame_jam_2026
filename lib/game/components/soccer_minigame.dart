import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/components/character.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/material.dart';

enum _SoccerPhase { setup, ready, runUp, flight, reset, outro, finished }

enum _ShotOutcome { goal, save }

enum _CalloutTone { info, goal, save }

class SoccerMinigameComponent extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  SoccerMinigameComponent()
    : super(
        position: Vector2(-640, -360),
        size: Vector2(1280, 720),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  static const int shotsPerMatch = 10;
  static const int goalsToWin = 6;

  static const double _goalSpriteHeight = 342;
  static const double _goalCenterX = 804;
  static const double _goalMouthWidth = 284;
  static const double _goalMouthHeight = 164;
  static const double _goalMouthTop = 218;
  static Rect get _goalMouth => Rect.fromLTWH(
    _goalCenterX - (_goalMouthWidth / 2),
    _goalMouthTop,
    _goalMouthWidth,
    _goalMouthHeight,
  );
  static double get _goalieLaneMinX => _goalCenterX - 104;
  static double get _goalieLaneMaxX => _goalCenterX + 104;
  static const double _goalieReadyScale = 0.64;
  static const double _goalieReadyY = 492;

  static Vector2 get _chubbySceneStart => Vector2(380, 660);
  static Vector2 get _chubbyReadyPos => Vector2(236, 660);
  static Vector2 get _goalieSceneStart => Vector2(_goalCenterX - 28, 664);
  static Vector2 get _goalieReadyPos => Vector2(_goalCenterX, _goalieReadyY);
  static Vector2 get _goalSpritePos => Vector2(_goalCenterX, 534);
  static Vector2 get _ballHome => Vector2(452, 612);

  final math.Random _random = math.Random();

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
  late final Character _chubby;
  late final Character _goalie;
  late final SpriteComponent _goal;
  late final SpriteComponent _ball;
  late final _SoccerEffectsLayer _effectsLayer;
  late final _SoccerHudLayer _hudLayer;
  final List<_SoccerVfxParticle> _vfxParticles = <_SoccerVfxParticle>[];

  _SoccerPhase _phase = _SoccerPhase.setup;
  final List<bool> _shotResults = <bool>[];

  double _time = 0;
  double _phaseTimer = 0;
  double _calloutTimer = 0;
  double _uiOpacity = 1;
  double _goalBurstTimer = 0;
  double _aimValue = 0.16;
  double _aimDirection = 1;
  double _lockedAimX = _goalCenterX;
  double _lockedAimY = _goalMouth.center.dy;
  double _goaliePatrolDirection = 1;
  double _goalieDiveTargetX = _goalCenterX;
  double _goalieDiveSpeed = 0;
  double _goalieReactionDelay = 0;
  double _goalieShotStartX = _goalCenterX;
  double _ballFlightDuration = 0.58;
  double _ballFlightElapsed = 0;
  bool _goalieDiving = false;
  bool _goalieUsingAltSprite = false;
  bool _matchWon = false;
  bool _ballShown = false;
  bool _ballAttachedToGoalie = false;
  bool _pendingWin = false;
  bool _pendingLoss = false;
  bool _goalFeedbackBurstShown = false;
  int _goals = 0;
  int _shotsTaken = 0;
  String _callout = 'Line up the shot and tap once.';
  _CalloutTone _calloutTone = _CalloutTone.info;
  _ShotOutcome? _resetOutcome;
  double _goalieCatchOffsetX = 0;
  double _goalieCatchOffsetY = -126;
  bool _shotOutcomePreviewShown = false;

  Vector2 _ballStart = _ballHome;
  Vector2 _ballControl = _ballHome;
  Vector2 _ballTarget = _ballHome;
  Vector2 _goalBurstCenter = Vector2.zero();

  Rect get _playAgainButton => const Rect.fromLTWH(493, 456, 294, 64);

  @override
  Future<void> onLoad() async {
    _goal = _buildGoalSprite();
    _goal.opacity = 0;
    _goal.scale = Vector2.all(0.94);

    _goalie = Character(
      imagePath: 'chars/blonde.png',
      position: _goalieSceneStart,
      characterHeight: 370,
    );
    _goalie.priority = 6;

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: _chubbySceneStart,
      characterHeight: 330,
    );
    _chubby.priority = 7;

    _ball = _buildBallSprite();
    _ball.opacity = 0;
    _ball.scale = Vector2.all(0.58);

    _effectsLayer = _SoccerEffectsLayer(this);
    _hudLayer = _SoccerHudLayer(this);

    await addAll([_goal, _goalie, _chubby, _ball, _effectsLayer, _hudLayer]);
    _startNewMatch();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
    if (_calloutTimer > 0) {
      _calloutTimer = math.max(0, _calloutTimer - dt);
    }
    if (_goalBurstTimer > 0) {
      _goalBurstTimer = math.max(0, _goalBurstTimer - dt);
    }
    _updateVfxParticles(dt);

    switch (_phase) {
      case _SoccerPhase.setup:
        _updateSetup(dt);
        break;
      case _SoccerPhase.ready:
        _updateReady(dt);
        break;
      case _SoccerPhase.runUp:
        _updateRunUp(dt);
        break;
      case _SoccerPhase.flight:
        _updateFlight(dt);
        break;
      case _SoccerPhase.reset:
        _updateReset(dt);
        break;
      case _SoccerPhase.outro:
        _updateOutro(dt);
        break;
      case _SoccerPhase.finished:
        break;
    }

    _syncCaughtBallToGoalie();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final tap = Offset(event.localPosition.x, event.localPosition.y);
    if (_phase == _SoccerPhase.finished) {
      if (_playAgainButton.contains(tap)) {
        _startNewMatch();
      }
      return;
    }

    if (_phase == _SoccerPhase.ready) {
      _startShot();
    }
  }

  void _startNewMatch() {
    _clearEffects(_goal);
    _clearEffects(_goalie);
    _clearEffects(_chubby);
    _clearEffects(_ball);

    _phase = _SoccerPhase.setup;
    _phaseTimer = 0.84;
    _goals = 0;
    _shotsTaken = 0;
    _matchWon = false;
    _ballShown = false;
    _uiOpacity = 1;
    _shotResults.clear();
    _goalieUsingAltSprite = false;
    _goalieDiving = false;
    _ballAttachedToGoalie = false;
    _pendingWin = false;
    _pendingLoss = false;
    _goalFeedbackBurstShown = false;
    _shotOutcomePreviewShown = false;
    _resetOutcome = null;
    _goalBurstTimer = 0;
    _aimValue = 0.14 + (_random.nextDouble() * 0.16);
    _aimDirection = 1;
    _goaliePatrolDirection = _random.nextBool() ? 1 : -1;
    _calloutTimer = 0;
    _vfxParticles.clear();

    _goal.opacity = 0;
    _goal.position.setFrom(_goalSpritePos);
    _goal.scale = Vector2.all(0.94);

    _goalie.stopWalking();
    _goalie.setImagePath('chars/blonde.png');
    _goalie.position.setFrom(_goalieSceneStart);
    _goalie.scale = Vector2.all(1);
    _goalie.angle = 0;

    _chubby.stopWalking();
    _chubby.setImagePath('chars/chubby.png');
    _chubby.position.setFrom(_chubbySceneStart);
    _chubby.scale = Vector2(-1, 1);
    _chubby.angle = 0;

    _ball.position.setFrom(_ballHome);
    _ball.opacity = 0;
    _ball.scale = Vector2.all(0.58);
    _ball.angle = 0;

    _ballStart = _ballHome.clone();
    _ballControl = _ballHome.clone();
    _ballTarget = _ballHome.clone();

    _goal.add(
      CombinedEffect([
        OpacityEffect.to(
          1,
          EffectController(
            duration: 0.28,
            curve: Curves.easeOut,
            startDelay: 0.12,
          ),
        ),
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(
            duration: 0.42,
            curve: Curves.easeOutBack,
            startDelay: 0.12,
          ),
        ),
      ]),
    );
    _goalie.add(
      MoveToEffect(
        _goalieReadyPos,
        EffectController(duration: 0.64, curve: Curves.easeInOut),
      ),
    );
    _goalie.add(
      ScaleEffect.to(
        Vector2.all(_goalieReadyScale),
        EffectController(duration: 0.64, curve: Curves.easeInOut),
      ),
    );
    _chubby.add(
      MoveToEffect(
        _chubbyReadyPos,
        EffectController(duration: 0.54, curve: Curves.easeInOut),
      ),
    );
  }

  void _updateSetup(double dt) {
    _phaseTimer = math.max(0, _phaseTimer - dt);

    if (!_ballShown && _phaseTimer <= 0.42) {
      _ballShown = true;
      _ball.opacity = 1;
      _ball.scale = Vector2.all(0.58);
      _ball.add(
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(duration: 0.26, curve: Curves.elasticOut),
        ),
      );
    }

    if (!_goalieUsingAltSprite && _phaseTimer <= 0.28) {
      _goalie.setImagePath('chars/blonde2.png');
      _goalieUsingAltSprite = true;
    }

    if (_phaseTimer <= 0) {
      _beginReadyPhase();
    }
  }

  void _beginReadyPhase() {
    _phase = _SoccerPhase.ready;
    _goalie.position.y = _goalieReadyY;
    _goalie.angle = 0;
    _goalie.startWalking();
    _calloutTimer = 0;
  }

  void _updateReady(double dt) {
    _ball.position.setFrom(_ballHome);
    _ball.angle = math.sin(_time * 4.6) * 0.04;

    final aimSpeed = 0.34 + (_shotsTaken * 0.045);
    _aimValue += _aimDirection * dt * aimSpeed;

    if (_aimValue >= 1) {
      _aimValue = 1;
      _aimDirection = -1;
    } else if (_aimValue <= 0) {
      _aimValue = 0;
      _aimDirection = 1;
    }

    _updateGoaliePatrol(dt);
  }

  void _startShot() {
    final aimTarget = _currentAimTarget;
    final firstStepX = _ballHome.x - 138;
    final secondStepX = _ballHome.x - 92;

    _phase = _SoccerPhase.runUp;
    _phaseTimer = 0.44;
    _lockedAimX = aimTarget.x;
    _lockedAimY = aimTarget.y;
    _goalieShotStartX = _goalie.position.x;

    _clearEffects(_chubby);
    _chubby.stopWalking();
    _chubby.startWalking();
    _chubby.add(
      SequenceEffect([
        MoveToEffect(
          Vector2(firstStepX, _chubbyReadyPos.y),
          EffectController(duration: 0.18, curve: Curves.easeIn),
        ),
        MoveToEffect(
          Vector2(secondStepX, _chubbyReadyPos.y),
          EffectController(duration: 0.16, curve: Curves.easeOut),
        ),
        CombinedEffect([
          MoveByEffect(
            Vector2(14, -10),
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
          RotateEffect.by(
            -0.06,
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
        ]),
      ]),
    );
  }

  void _updateRunUp(double dt) {
    _phaseTimer = math.max(0, _phaseTimer - dt);
    _updateGoaliePatrol(dt);

    if (_phaseTimer <= 0) {
      _launchShot();
    }
  }

  void _launchShot() {
    _phase = _SoccerPhase.flight;
    _ballFlightElapsed = 0;
    _goalieDiving = false;
    _goalieShotStartX = _goalie.position.x;
    _ballAttachedToGoalie = false;
    _goalFeedbackBurstShown = false;
    _shotOutcomePreviewShown = false;

    _clearEffects(_chubby);
    _chubby.stopWalking();
    _chubby.add(
      SequenceEffect([
        MoveByEffect(
          Vector2(18, -18),
          EffectController(duration: 0.08, curve: Curves.easeOut),
        ),
        MoveByEffect(
          Vector2(-24, 18),
          EffectController(duration: 0.12, curve: Curves.easeIn),
        ),
      ]),
    );

    final cornerFactor =
        ((_lockedAimX - _goalCenterX).abs() / (_goalMouth.width / 2)).clamp(
          0.0,
          1.0,
        );
    final shotProgress = (_shotsTaken / (shotsPerMatch - 1)).clamp(0.0, 1.0);

    _ballFlightDuration = ui.lerpDouble(0.62, 0.46, cornerFactor)!;
    _goalieReactionDelay =
        ui.lerpDouble(0.23, 0.15, shotProgress)! +
        (_random.nextDouble() * 0.04);
    _goalieDiveSpeed =
        ui.lerpDouble(280, 360, shotProgress)! + (_random.nextDouble() * 18);

    _ballStart = _ballHome.clone();
    _ballTarget = Vector2(_lockedAimX, _lockedAimY);
    _ballControl = Vector2(
      (_ballStart.x + _ballTarget.x) / 2,
      ui.lerpDouble(_ballTarget.y - 210, _ballTarget.y - 140, cornerFactor)!,
    );

    _goalieDiveTargetX = _computeGoalieDiveTarget(
      shotTargetX: _lockedAimX,
      cornerFactor: cornerFactor,
    );
  }

  void _updateFlight(double dt) {
    _ballFlightElapsed += dt;

    if (!_goalieDiving && _ballFlightElapsed >= _goalieReactionDelay) {
      _goalie.stopWalking();
      _goalieDiving = true;
    }

    if (_goalieDiving) {
      final dx = _goalieDiveTargetX - _goalie.position.x;
      final step = _goalieDiveSpeed * dt;
      if (dx.abs() <= step) {
        _goalie.position.x = _goalieDiveTargetX;
      } else {
        _goalie.position.x += dx.sign * step;
      }
      _goalie.angle = ui.lerpDouble(_goalie.angle, dx.sign * 0.08, 0.18)!;
    }

    final t = (_ballFlightElapsed / _ballFlightDuration).clamp(0.0, 1.0);
    final inverse = 1 - t;
    _ball.position.setValues(
      (inverse * inverse * _ballStart.x) +
          (2 * inverse * t * _ballControl.x) +
          (t * t * _ballTarget.x),
      (inverse * inverse * _ballStart.y) +
          (2 * inverse * t * _ballControl.y) +
          (t * t * _ballTarget.y),
    );
    _ball.scale = Vector2.all(ui.lerpDouble(1.0, 0.7, t)!);
    _ball.angle += dt * 8.8;

    if (!_shotOutcomePreviewShown && t >= 0.72) {
      final previewSaved = _predictShotWillBeSaved();
      _setCallout(
        previewSaved ? 'SAVE!' : 'GOAL!',
        0.9,
        tone: previewSaved ? _CalloutTone.save : _CalloutTone.goal,
      );
      _shotOutcomePreviewShown = true;
    }

    if (!_goalFeedbackBurstShown && t >= 0.82 && !_predictShotWillBeSaved()) {
      _triggerGoalFeedbackBurst();
    }

    if (t >= 1) {
      _resolveShot();
    }
  }

  void _resolveShot() {
    _shotsTaken++;

    final cornerFactor =
        ((_ballTarget.x - _goalCenterX).abs() / (_goalMouth.width / 2)).clamp(
          0.0,
          1.0,
        );
    final heightFactor =
        ((_goalMouth.bottom - _ballTarget.y) / _goalMouth.height).clamp(
          0.0,
          1.0,
        );
    final laneStretch =
        ((_ballTarget.x - _goalieShotStartX).abs() / (_goalMouth.width * 0.62))
            .clamp(0.0, 1.0);

    var saveRadius = ui.lerpDouble(72, 30, cornerFactor)!;
    saveRadius *= ui.lerpDouble(1.0, 0.63, heightFactor)!;
    saveRadius *= ui.lerpDouble(1.0, 0.78, laneStretch)!;

    if (cornerFactor > 0.72) {
      saveRadius *= 0.65;
    }
    if (heightFactor > 0.68) {
      saveRadius *= 0.82;
    }

    final wasSaved = (_goalie.position.x - _ballTarget.x).abs() <= saveRadius;

    _shotResults.add(!wasSaved);
    _pendingWin = false;
    _pendingLoss = false;
    _shotOutcomePreviewShown = false;
    _resetOutcome = wasSaved ? _ShotOutcome.save : _ShotOutcome.goal;
    if (wasSaved) {
      final saveSide = (_ballTarget.x - _goalie.position.x).sign == 0
          ? (_goaliePatrolDirection == 0 ? 1.0 : _goaliePatrolDirection)
          : (_ballTarget.x - _goalie.position.x).sign;
      _playSaveAnimation(saveSide: saveSide);
      _setCallout('SAVE!', 1.0, tone: _CalloutTone.save);
      MinigameSfx.playError();
    } else {
      _goals++;
      _triggerGoalFeedbackBurst();
      MinigameSfx.playGoal();
      _playGoalAnimation(
        cornerFactor: cornerFactor,
        heightFactor: heightFactor,
      );
      _setCallout(
        _goals >= goalsToWin ? 'GOOOAL!' : 'GOAL!',
        1.0,
        tone: _CalloutTone.goal,
      );
    }

    final remainingShots = shotsPerMatch - _shotsTaken;
    final canStillWin = _goals + remainingShots >= goalsToWin;

    if (_goals >= goalsToWin) {
      _pendingWin = true;
      _phase = _SoccerPhase.reset;
      _phaseTimer = 1.0;
      return;
    }

    if (_shotsTaken >= shotsPerMatch || !canStillWin) {
      _pendingLoss = true;
      _phase = _SoccerPhase.reset;
      _phaseTimer = wasSaved ? 1.08 : 0.96;
      return;
    }

    _phase = _SoccerPhase.reset;
    _phaseTimer = wasSaved ? 0.98 : 0.88;
  }

  void _updateReset(double dt) {
    _phaseTimer = math.max(0, _phaseTimer - dt);
    if (_resetOutcome == _ShotOutcome.goal) {
      _goalie.angle = ui.lerpDouble(_goalie.angle, 0, 0.18)!;
      _goalie.position.x = ui.lerpDouble(
        _goalie.position.x,
        _goalCenterX + ((_random.nextDouble() - 0.5) * 24),
        0.05,
      )!;
    }

    if (_phaseTimer <= 0) {
      if (_pendingWin) {
        _pendingWin = false;
        _startWinOutro();
        return;
      }
      if (_pendingLoss) {
        _pendingLoss = false;
        _finishMatch(won: false);
        return;
      }
      _resetForNextShot();
    }
  }

  void _updateOutro(double dt) {
    _phaseTimer = math.max(0, _phaseTimer - dt);
    _uiOpacity = (_phaseTimer / 0.46).clamp(0.0, 1.0);

    if (_phaseTimer <= 0) {
      _phase = _SoccerPhase.finished;
      game.finishSoccerMinigameWin();
    }
  }

  void _resetForNextShot() {
    _clearEffects(_goal);
    _clearEffects(_goalie);
    _clearEffects(_chubby);
    _clearEffects(_ball);

    _goal.position.setFrom(_goalSpritePos);
    _goalie.stopWalking();
    _goalie.position.setValues(
      ui.lerpDouble(_goalieLaneMinX, _goalieLaneMaxX, _random.nextDouble())!,
      _goalieReadyY,
    );
    _goalie.angle = 0;
    _goalie.startWalking();

    _chubby.stopWalking();
    _chubby.position.setFrom(_chubbyReadyPos);
    _chubby.angle = 0;

    _ball.position.setFrom(_ballHome);
    _ball.opacity = 1;
    _ball.scale = Vector2.all(1);
    _ball.angle = 0;

    _ballAttachedToGoalie = false;
    _pendingWin = false;
    _pendingLoss = false;
    _goalFeedbackBurstShown = false;
    _shotOutcomePreviewShown = false;
    _resetOutcome = null;
    _aimValue = _random.nextDouble();
    _aimDirection = _random.nextBool() ? 1 : -1;
    _goaliePatrolDirection = _random.nextBool() ? 1 : -1;
    _goalieDiving = false;
    _phase = _SoccerPhase.ready;
  }

  void _finishMatch({required bool won}) {
    _phase = _SoccerPhase.finished;
    _matchWon = won;
    _goalie.stopWalking();
    _chubby.stopWalking();
    _goalie.angle = 0;
    _chubby.angle = 0;

    if (won) {
      MinigameSfx.playWin();
      _setCallout(
        'You won the backyard penalties! Tap PLAY AGAIN to run it back.',
        999,
      );
    } else {
      _setCallout(
        'Big Bro saved too many shots. Tap PLAY AGAIN to try again.',
        999,
      );
    }
  }

  void _startWinOutro() {
    if (_phase == _SoccerPhase.outro) {
      return;
    }

    _phase = _SoccerPhase.outro;
    _phaseTimer = 0.46;
    _matchWon = true;
    _goalie.stopWalking();
    _chubby.stopWalking();

    _goal.add(OpacityEffect.to(0, EffectController(duration: 0.42)));
    _ball.add(OpacityEffect.to(0, EffectController(duration: 0.36)));
    _goalie.add(OpacityEffect.to(0, EffectController(duration: 0.36)));
    _chubby.add(OpacityEffect.to(0, EffectController(duration: 0.36)));
  }

  Vector2 get _currentAimTarget {
    final eased = Curves.easeInOut.transform(_aimValue.clamp(0.0, 1.0));
    final x = ui.lerpDouble(
      _goalMouth.left + 18,
      _goalMouth.right - 18,
      eased,
    )!;
    return Vector2(x, _goalTargetYForX(x));
  }

  double _goalTargetYForX(double targetX) {
    final cornerFactor =
        ((targetX - _goalCenterX).abs() / (_goalMouth.width / 2)).clamp(
          0.0,
          1.0,
        );
    final topY = ui.lerpDouble(
      _goalMouth.top + 78,
      _goalMouth.top + 48,
      cornerFactor,
    )!;
    final bottomY = ui.lerpDouble(
      _goalMouth.bottom - 16,
      _goalMouth.bottom - 42,
      cornerFactor,
    )!;
    final verticalWave = (0.34 + (math.sin((_time * 1.05) + 0.4) * 0.24)).clamp(
      0.0,
      1.0,
    );
    return ui.lerpDouble(bottomY, topY, verticalWave)!;
  }

  double _computeGoalieDiveTarget({
    required double shotTargetX,
    required double cornerFactor,
  }) {
    final shotProgress = (_shotsTaken / (shotsPerMatch - 1)).clamp(0.0, 1.0);
    final readStrength =
        (ui.lerpDouble(0.2, 0.42, shotProgress)! +
                (_random.nextDouble() * 0.08))
            .clamp(0.0, 0.54);
    final movingAway =
        ((shotTargetX - _goalie.position.x).sign * _goaliePatrolDirection) < 0;
    final errorRange = ui.lerpDouble(190, 96, readStrength)!;
    final cornerPenalty = ui.lerpDouble(1.0, 0.58, cornerFactor)!;
    final motionPenalty = movingAway ? 1.16 : 1.0;
    final error =
        (_random.nextDouble() - 0.5) *
        errorRange *
        cornerPenalty *
        motionPenalty;

    return (shotTargetX + error).clamp(_goalieLaneMinX, _goalieLaneMaxX);
  }

  void _updateGoaliePatrol(double dt) {
    final patrolSpeed = 92 + (_shotsTaken * 12);
    _goalie.position.x += _goaliePatrolDirection * patrolSpeed * dt;

    if (_goalie.position.x <= _goalieLaneMinX) {
      _goalie.position.x = _goalieLaneMinX;
      _goaliePatrolDirection = 1;
    } else if (_goalie.position.x >= _goalieLaneMaxX) {
      _goalie.position.x = _goalieLaneMaxX;
      _goaliePatrolDirection = -1;
    }

    _goalie.position.y = _goalieReadyY;
  }

  void _setCallout(
    String value,
    double duration, {
    _CalloutTone tone = _CalloutTone.info,
  }) {
    _callout = value;
    _calloutTone = tone;
    _calloutTimer = duration;
  }

  bool _predictShotWillBeSaved() {
    final cornerFactor =
        ((_ballTarget.x - _goalCenterX).abs() / (_goalMouth.width / 2)).clamp(
          0.0,
          1.0,
        );
    final heightFactor =
        ((_goalMouth.bottom - _ballTarget.y) / _goalMouth.height).clamp(
          0.0,
          1.0,
        );
    final laneStretch =
        ((_ballTarget.x - _goalieShotStartX).abs() / (_goalMouth.width * 0.62))
            .clamp(0.0, 1.0);

    var saveRadius = ui.lerpDouble(72, 30, cornerFactor)!;
    saveRadius *= ui.lerpDouble(1.0, 0.63, heightFactor)!;
    saveRadius *= ui.lerpDouble(1.0, 0.78, laneStretch)!;

    if (cornerFactor > 0.72) {
      saveRadius *= 0.65;
    }
    if (heightFactor > 0.68) {
      saveRadius *= 0.82;
    }

    final postReactionTime = math.max(
      0,
      _ballFlightDuration - _goalieReactionDelay,
    );
    final maxTravel = _goalieDiveSpeed * postReactionTime;
    final neededTravel = (_goalieDiveTargetX - _goalieShotStartX).abs();
    final completedTravel = math.min(maxTravel, neededTravel);
    final predictedGoalieX =
        _goalieShotStartX +
        ((_goalieDiveTargetX - _goalieShotStartX).sign * completedTravel);

    return (predictedGoalieX - _ballTarget.x).abs() <= saveRadius;
  }

  Vector2 get _goalieCatchPosition => Vector2(
    _goalie.position.x + _goalieCatchOffsetX,
    _goalie.position.y + _goalieCatchOffsetY,
  );

  void _syncCaughtBallToGoalie() {
    if (!_ballAttachedToGoalie) {
      return;
    }

    final catchPosition = _goalieCatchPosition;
    _ball.position.setFrom(catchPosition);
    _ball.scale = Vector2.all(0.74);
    _ball.angle = _goalie.angle * 0.35;
  }

  void _playGoalAnimation({
    required double cornerFactor,
    required double heightFactor,
  }) {
    final sideSign = (_ballTarget.x - _goalCenterX).sign == 0
        ? (_random.nextBool() ? 1.0 : -1.0)
        : (_ballTarget.x - _goalCenterX).sign;
    final pullToCenter = (_goalCenterX - _ballTarget.x) * 0.18;
    final netDrop = ui.lerpDouble(18, 44, heightFactor)!;

    _ballAttachedToGoalie = false;
    _clearEffects(_ball);
    _ball.position.setFrom(_ballTarget);
    _ball.scale = Vector2.all(0.72);
    _ball.add(
      SequenceEffect([
        CombinedEffect([
          MoveByEffect(
            Vector2(pullToCenter * 0.55, 12 + ((1 - cornerFactor) * 10)),
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
          ScaleEffect.to(
            Vector2.all(0.66),
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
        ]),
        CombinedEffect([
          MoveByEffect(
            Vector2((pullToCenter * 0.45) - (sideSign * 6), netDrop),
            EffectController(duration: 0.18, curve: Curves.easeIn),
          ),
          RotateEffect.by(
            sideSign * 0.22,
            EffectController(duration: 0.18, curve: Curves.easeIn),
          ),
        ]),
      ]),
    );

    _clearEffects(_goal);
    _goal.add(
      SequenceEffect([
        MoveByEffect(
          Vector2(5 * sideSign, -2),
          EffectController(duration: 0.06, curve: Curves.easeOut),
        ),
        MoveByEffect(
          Vector2(-10 * sideSign, 4),
          EffectController(duration: 0.08, curve: Curves.easeInOut),
        ),
        MoveByEffect(
          Vector2(5 * sideSign, -2),
          EffectController(duration: 0.06, curve: Curves.easeIn),
        ),
      ]),
    );
  }

  void _playSaveAnimation({required double saveSide}) {
    _clearEffects(_goalie);
    _goalie.stopWalking();

    _ballAttachedToGoalie = true;
    _goalieCatchOffsetX = 60 * saveSide;
    _goalieCatchOffsetY = -170;

    _clearEffects(_ball);
    _ball.position.setFrom(_goalieCatchPosition);
    _ball.scale = Vector2.all(0.74);
    _ball.angle = saveSide * 0.06;

    _goalie.add(
      SequenceEffect([
        CombinedEffect([
          MoveByEffect(
            Vector2(saveSide * 10, -18),
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
          RotateEffect.by(
            saveSide * 0.1,
            EffectController(duration: 0.1, curve: Curves.easeOut),
          ),
        ]),
        CombinedEffect([
          MoveByEffect(
            Vector2(-saveSide * 6, 12),
            EffectController(duration: 0.1, curve: Curves.easeInOut),
          ),
          RotateEffect.by(
            -saveSide * 0.16,
            EffectController(duration: 0.1, curve: Curves.easeInOut),
          ),
        ]),
        CombinedEffect([
          MoveByEffect(
            Vector2(0, -8),
            EffectController(duration: 0.08, curve: Curves.easeOut),
          ),
          RotateEffect.by(
            saveSide * 0.08,
            EffectController(duration: 0.08, curve: Curves.easeOut),
          ),
        ]),
        CombinedEffect([
          MoveByEffect(
            Vector2(0, 14),
            EffectController(duration: 0.1, curve: Curves.easeIn),
          ),
          RotateEffect.by(
            -saveSide * 0.02,
            EffectController(duration: 0.1, curve: Curves.easeIn),
          ),
        ]),
      ]),
    );

    _spawnSaveBurst(_goalieCatchPosition, sideSign: saveSide);
  }

  void _spawnGoalSparkles(
    Vector2 origin, {
    required double sideSign,
    required double heightFactor,
  }) {
    const particleScale = 0.8;
    const palette = <Color>[
      Color(0xFFFFFFFF),
      Color(0xFFFFD700),
      Color(0xFFFF6B35),
      Color(0xFF00E676),
      Color(0xFF40C4FF),
      Color(0xFFFF4081),
    ];
    final burstCount = 18;

    for (var i = 0; i < burstCount; i++) {
      final angle = (_random.nextDouble() * math.pi * 2) - (math.pi / 2);
      final speed = 40 + (_random.nextDouble() * 80);
      final particle = _SoccerVfxParticle(
        position: origin + Vector2((_random.nextDouble() - 0.5) * 18, -6),
        velocity: Vector2(
          math.cos(angle) * speed,
          math.sin(angle) * speed - (heightFactor * 18),
        ),
        radius: (8 + (_random.nextDouble() * 10)) * particleScale,
        lifetime: 1.0 + (_random.nextDouble() * 0.6),
        color: palette[_random.nextInt(palette.length)],
        gravity: 100,
        sparkle: i.isEven,
      );
      _vfxParticles.add(particle);
    }

    for (var i = 0; i < 10; i++) {
      final position = Vector2(
        _goalCenterX + ((_random.nextDouble() - 0.5) * (_goalMouth.width * 0.9)),
        _goalMouth.top + 14 + (_random.nextDouble() * (_goalMouth.height * 0.55)),
      );
      _vfxParticles.add(
        _SoccerVfxParticle(
          position: position,
          velocity: Vector2(
            sideSign * (12 + (_random.nextDouble() * 18)),
            -16 - (_random.nextDouble() * 18),
          ),
          radius: (9 + (_random.nextDouble() * 6)) * particleScale,
          lifetime: 0.8 + (_random.nextDouble() * 0.5),
          color: palette[_random.nextInt(palette.length)],
          gravity: 50,
          sparkle: true,
        ),
      );
    }

    for (var i = 0; i < 10; i++) {
      final angle = (_random.nextDouble() * math.pi * 2);
      final speed = 38 + (_random.nextDouble() * 62);
      _vfxParticles.add(
        _SoccerVfxParticle(
          position: origin +
              Vector2(
                (_random.nextDouble() - 0.5) * 8,
                (_random.nextDouble() - 0.5) * 8,
              ),
          velocity: Vector2(
            math.cos(angle) * speed,
            math.sin(angle) * speed,
          ),
          radius: (11 + (_random.nextDouble() * 6)) * particleScale,
          lifetime: 0.9 + (_random.nextDouble() * 0.5),
          color: palette[_random.nextInt(palette.length)],
          gravity: 25,
          sparkle: true,
        ),
      );
    }
  }

  void _spawnSaveBurst(Vector2 origin, {required double sideSign}) {
    const particleScale = 0.8;
    const palette = <Color>[
      Color(0xFFFFFFFF),
      Color(0xFFD7E8FF),
      Color(0xFFAED6FF),
    ];

    for (var i = 0; i < 12; i++) {
      final angle = (math.pi + (sideSign * math.pi * 0.18)) +
          ((_random.nextDouble() - 0.5) * 1.1);
      final speed = 28 + (_random.nextDouble() * 78);
      _vfxParticles.add(
        _SoccerVfxParticle(
          position: origin + Vector2(sideSign * 6, -4),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          radius: (2 + (_random.nextDouble() * 3)) * particleScale,
          lifetime: 0.22 + (_random.nextDouble() * 0.18),
          color: palette[_random.nextInt(palette.length)],
          gravity: 110,
          sparkle: i % 3 == 0,
        ),
      );
    }
  }

  void _triggerGoalFeedbackBurst() {
    if (_goalFeedbackBurstShown) {
      return;
    }

    final heightFactor =
        ((_goalMouth.bottom - _ballTarget.y) / _goalMouth.height).clamp(
          0.0,
          1.0,
        );
    final sideSign = (_ballTarget.x - _goalCenterX).sign == 0
        ? (_random.nextBool() ? 1.0 : -1.0)
        : (_ballTarget.x - _goalCenterX).sign;

    _goalFeedbackBurstShown = true;
    _goalBurstCenter = _ballTarget.clone();
    _goalBurstTimer = 0.34;
    _spawnGoalSparkles(_ballTarget, sideSign: sideSign, heightFactor: heightFactor);
  }

  void _updateVfxParticles(double dt) {
    if (_vfxParticles.isEmpty) {
      return;
    }

    for (final particle in _vfxParticles) {
      particle.age += dt;
      particle.position.add(particle.velocity * dt);
      particle.velocity.y += particle.gravity * dt;
    }
    _vfxParticles.removeWhere((particle) => particle.age >= particle.lifetime);
  }

  void _renderVfxParticles(Canvas canvas) {
    if (_vfxParticles.isEmpty) {
      return;
    }

    final alphaScale = _phase == _SoccerPhase.outro ? _uiOpacity : 1.0;
    for (final particle in _vfxParticles) {
      final progress = (particle.age / particle.lifetime).clamp(0.0, 1.0);
      final alpha = (1 - progress) * alphaScale;
      if (alpha <= 0) {
        continue;
      }

      final color = particle.color.withValues(alpha: alpha);
      if (particle.sparkle) {
        final arm = particle.radius * (1.65 + ((1 - progress) * 0.9));
        final sparklePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2;
        canvas.drawLine(
          Offset(particle.position.x - arm, particle.position.y),
          Offset(particle.position.x + arm, particle.position.y),
          sparklePaint,
        );
        canvas.drawLine(
          Offset(particle.position.x, particle.position.y - arm),
          Offset(particle.position.x, particle.position.y + arm),
          sparklePaint,
        );
        canvas.drawCircle(
          Offset(particle.position.x, particle.position.y),
          particle.radius * 0.35,
          Paint()..color = color,
        );
      } else {
        canvas.drawCircle(
          Offset(particle.position.x, particle.position.y),
          particle.radius,
          Paint()..color = color,
        );
      }
    }
  }

  void _renderGoalBurst(Canvas canvas) {
    if (_goalBurstTimer <= 0) {
      return;
    }

    const totalDuration = 0.34;
    final progress = 1 - (_goalBurstTimer / totalDuration).clamp(0.0, 1.0);
    final center = Offset(_goalBurstCenter.x, _goalBurstCenter.y);
    final glowRadius = ui.lerpDouble(22, 86, progress)!;
    final ringRadius = ui.lerpDouble(16, 62, progress)!;
    final alpha = 1 - progress;

    canvas.drawCircle(
      center,
      glowRadius,
      Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.16 * alpha),
    );

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = const Color(0xFFFFF7C7).withValues(alpha: 0.9 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ui.lerpDouble(8, 2.2, progress)!,
    );

    canvas.drawCircle(
      center,
      ui.lerpDouble(8, 24, progress)!,
      Paint()..color = Colors.white.withValues(alpha: 0.12 * alpha),
    );

    final rayPaint = Paint()
      ..color = const Color(0xFFFFF4A6).withValues(alpha: 0.65 * alpha)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = (-math.pi / 2) + ((math.pi * 2) * (i / 6));
      final inner = ringRadius * 0.64;
      final outer = ringRadius + 10 + (progress * 12);
      canvas.drawLine(
        Offset(
          center.dx + (math.cos(angle) * inner),
          center.dy + (math.sin(angle) * inner),
        ),
        Offset(
          center.dx + (math.cos(angle) * outer),
          center.dy + (math.sin(angle) * outer),
        ),
        rayPaint,
      );
    }
  }

  void _renderAimGuide(Canvas canvas) {
    final target = _phase == _SoccerPhase.runUp
        ? Offset(_lockedAimX, _lockedAimY)
        : Offset(_currentAimTarget.x, _currentAimTarget.y);
    final aimColor = Colors.white.withValues(alpha: 0.84 * _uiOpacity);
    final shadowColor = Colors.black.withValues(alpha: 0.28 * _uiOpacity);
    final guideShadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final guidePaint = Paint()
      ..color = aimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final trackY = _goalMouth.top - 24;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _goalMouth.left + 8,
        trackY - 5,
        _goalMouth.width - 16,
        10,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      trackRect,
      Paint()..color = Colors.black.withValues(alpha: 0.18 * _uiOpacity),
    );
    canvas.drawRRect(
      trackRect,
      Paint()..color = Colors.white.withValues(alpha: 0.28 * _uiOpacity),
    );

    final arrowBob = math.sin(_time * 7.2) * 2.5;
    final arrowTip = Offset(target.dx, trackY + 16 + arrowBob);
    final arrowBaseY = trackY - 6 + arrowBob;

    canvas.drawLine(arrowTip, target, guideShadowPaint);
    canvas.drawLine(arrowTip, target, guidePaint);
    canvas.drawCircle(
      target,
      13 + (math.sin(_time * 7.2).abs() * 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14 * _uiOpacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      target,
      9,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32 * _uiOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawCircle(
      target,
      9,
      Paint()
        ..color = aimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final arrowPath = ui.Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx - 14, arrowBaseY)
      ..lineTo(arrowTip.dx + 14, arrowBaseY)
      ..close();
    canvas.drawPath(
      arrowPath,
      Paint()..color = shadowColor,
    );
    canvas.drawPath(arrowPath, Paint()..color = aimColor);
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = shadowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _renderHud(Canvas canvas) {
    // --- Top-left info card ---
    final infoCard = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 24, 440, 120),
      const Radius.circular(20),
    );
    canvas.drawRRect(infoCard, Paint()..color = Colors.white);
    canvas.drawRRect(
      infoCard,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _titleText.render(canvas, 'BACKYARD PENALTIES', Vector2(48, 38));
    _bodyText.render(
      canvas,
      'Click to kick. Score $goalsToWin goals to win.',
      Vector2(48, 76),
    );

    // --- Top-right score card ---
    const scoreCardWidth = 312.0;
    const scoreCardHeight = 132.0;
    final scoreCardRect = Rect.fromLTWH(
      1280 - scoreCardWidth - 28,
      24,
      scoreCardWidth,
      scoreCardHeight,
    );
    final scoreCard = RRect.fromRectAndRadius(
      scoreCardRect,
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
    final scoreX = scoreCardRect.left + 20;
    _scoreText.render(canvas, 'GOALS $_goals/$goalsToWin', Vector2(scoreX, 36));
    _scoreText.render(
      canvas,
      'SHOTS $_shotsTaken/$shotsPerMatch',
      Vector2(scoreX, 68),
    );

    const circleRadius = 8.0;
    final circleRowWidth = scoreCardRect.width - 40;
    final circleStartX = scoreCardRect.left + 20 + circleRadius;
    final circleSpacing =
        (circleRowWidth - (circleRadius * 2)) / (shotsPerMatch - 1);
    final circleY = scoreCardRect.bottom - 22;
    for (var i = 0; i < shotsPerMatch; i++) {
      final resultKnown = i < _shotResults.length;
      final color = resultKnown
          ? (_shotResults[i]
                ? const Color(0xFF5BE37D)
                : const Color(0xFFFF6B6B))
          : Colors.black.withValues(alpha: 0.12);
      canvas.drawCircle(
        Offset(circleStartX + (i * circleSpacing), circleY),
        circleRadius,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(circleStartX + (i * circleSpacing), circleY),
        circleRadius,
        Paint()
          ..color = Colors.black.withValues(alpha: resultKnown ? 0.08 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _renderCallout(Canvas canvas) {
    final isEmphasized =
        _calloutTone == _CalloutTone.goal || _calloutTone == _CalloutTone.save;
    final width = isEmphasized ? 380.0 : 560.0;
    final height = isEmphasized ? 72.0 : 62.0;
    final textRectHeight = isEmphasized ? 48.0 : 44.0;
    final pulse = isEmphasized ? (1 + (math.sin(_time * 12).abs() * 0.035)) : 1.0;
    final bgColor = switch (_calloutTone) {
      _CalloutTone.goal => const Color(0xFF144A2A),
      _CalloutTone.save => const Color(0xFF631212),
      _ => const Color(0xFF18131F),
    };
    final borderColor = switch (_calloutTone) {
      _CalloutTone.goal => const Color(0xFFA8FF7B),
      _CalloutTone.save => const Color(0xFFFF8F8F),
      _ => Colors.white.withValues(alpha: 0.16),
    };
    final glowColor = switch (_calloutTone) {
      _CalloutTone.goal => const Color(0xFF6BFF99),
      _CalloutTone.save => const Color(0xFF67CFFF),
      _ => Colors.black,
    };
    final textColor = switch (_calloutTone) {
      _CalloutTone.goal => const Color(0xFFF7FFE5),
      _CalloutTone.save => const Color(0xFFF2FBFF),
      _ => Colors.white,
    };
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(640, 186),
        width: width * pulse,
        height: height * pulse,
      ),
      const Radius.circular(26),
    );
    final calloutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(640, 182),
        width: width * pulse,
        height: height * pulse,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(
      shadowRect,
      Paint()..color = glowColor.withValues(alpha: isEmphasized ? 0.28 : 0.22),
    );
    canvas.drawRRect(
      calloutRect,
      Paint()..color = bgColor.withValues(alpha: isEmphasized ? 0.94 : 0.82),
    );
    canvas.drawRRect(
      calloutRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isEmphasized ? 3 : 2,
    );
    _drawTextBlock(
      canvas,
      text: _callout.toUpperCase(),
      rect: Rect.fromCenter(
        center: const Offset(640, 182),
        width: (width * pulse) - 40,
        height: textRectHeight * pulse,
      ),
      style: TextStyle(
        color: textColor,
        fontSize: isEmphasized ? 30 : 22,
        fontWeight: FontWeight.w900,
        letterSpacing: isEmphasized ? 2.2 : 1.2,
        shadows: <Shadow>[
          Shadow(
            color: Colors.black.withValues(alpha: 0.34),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      align: TextAlign.center,
      maxLines: 1,
    );
  }

  void _renderEndCard(Canvas canvas) {
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(360, 248, 560, 292),
      const Radius.circular(34),
    );
    canvas.drawRRect(
      card,
      Paint()..color = const Color(0xFFF3F4E8).withValues(alpha: 0.97),
    );
    canvas.drawRRect(
      card,
      Paint()
        ..color = const Color(0xFF173A2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawTextBlock(
      canvas,
      text: 'TRY AGAIN',
      rect: Rect.fromCenter(center: const Offset(640, 316), width: 480, height: 64),
      style: const TextStyle(
        color: Color(0xFF163828),
        fontSize: 44,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
      align: TextAlign.center,
    );
    _drawTextBlock(
      canvas,
      text: 'Big Bro saved too many shots.\nTry again or he won\'t help you.',
      rect: Rect.fromCenter(center: const Offset(640, 395), width: 440, height: 90),
      style: const TextStyle(
        color: Color(0xFF214B39),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      align: TextAlign.center,
      maxLines: 3,
    );

    final buttonRect = Rect.fromLTWH(
      _playAgainButton.left,
      _playAgainButton.top,
      _playAgainButton.width,
      _playAgainButton.height,
    );
    final button = RRect.fromRectAndRadius(
      buttonRect,
      const Radius.circular(20),
    );
    canvas.drawRRect(
      button,
      Paint()
        ..color = _matchWon ? const Color(0xFF2A7A4B) : const Color(0xFF1E5FA4),
    );
    canvas.drawRRect(
      button,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawTextBlock(
      canvas,
      text: 'PLAY AGAIN',
      rect: buttonRect,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
      align: TextAlign.center,
      maxLines: 1,
    );
  }

  SpriteComponent _buildBallSprite() {
    final sprite = Sprite(game.images.fromCache('props/ball.png'));
    final aspectRatio = sprite.srcSize.x / sprite.srcSize.y;

    return SpriteComponent(
      sprite: sprite,
      position: _ballHome,
      size: Vector2(58 * aspectRatio, 58),
      anchor: Anchor.center,
      priority: 8,
    );
  }

  SpriteComponent _buildGoalSprite() {
    final sprite = Sprite(game.images.fromCache('props/goal.png'));
    final aspectRatio = sprite.srcSize.x / sprite.srcSize.y;

    return SpriteComponent(
      sprite: sprite,
      position: _goalSpritePos,
      size: Vector2(_goalSpriteHeight * aspectRatio, _goalSpriteHeight),
      anchor: Anchor.bottomCenter,
      priority: 1,
    );
  }

  void _drawTextBlock(
    Canvas canvas, {
    required String text,
    required Rect rect,
    required TextStyle style,
    TextAlign align = TextAlign.left,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: maxLines == 1 ? '...' : null,
    )..layout(maxWidth: rect.width);

    final dx = switch (align) {
      TextAlign.center => rect.left + ((rect.width - painter.width) / 2),
      TextAlign.right || TextAlign.end => rect.right - painter.width,
      _ => rect.left,
    };
    final dy = rect.top + ((rect.height - painter.height) / 2);

    painter.paint(canvas, Offset(dx, dy));
  }

  void _clearEffects(Component component) {
    for (final effect in component.children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
  }
}

class _SoccerVfxParticle {
  _SoccerVfxParticle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.lifetime,
    required this.color,
    required this.gravity,
    required this.sparkle,
  });

  final Vector2 position;
  final Vector2 velocity;
  final double radius;
  final double lifetime;
  final Color color;
  final double gravity;
  final bool sparkle;
  double age = 0;
}

class _SoccerEffectsLayer extends PositionComponent {
  _SoccerEffectsLayer(this.owner)
    : super(
        position: Vector2.zero(),
        anchor: Anchor.topLeft,
        priority: 18,
      );

  final SoccerMinigameComponent owner;

  @override
  Future<void> onLoad() async {
    size = owner.size;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    owner._renderGoalBurst(canvas);
    owner._renderVfxParticles(canvas);

    if (owner._phase == _SoccerPhase.ready ||
        owner._phase == _SoccerPhase.runUp) {
      owner._renderAimGuide(canvas);
    }
    canvas.restore();
  }
}

class _SoccerHudLayer extends PositionComponent {
  _SoccerHudLayer(this.owner)
    : super(
        position: Vector2.zero(),
        anchor: Anchor.topLeft,
        priority: 20,
      );

  final SoccerMinigameComponent owner;

  @override
  Future<void> onLoad() async {
    size = owner.size;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    owner._renderHud(canvas);

    if (owner._calloutTimer > 0 && owner._phase != _SoccerPhase.finished) {
      owner._renderCallout(canvas);
    }

    if (owner._phase == _SoccerPhase.finished) {
      canvas.drawRect(
        owner.size.toRect(),
        Paint()..color = Colors.black.withValues(alpha: 0.24),
      );
      owner._renderEndCard(canvas);
    }
    canvas.restore();
  }
}
