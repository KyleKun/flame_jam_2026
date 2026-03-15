import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_jam_2026/game/audio/game_bgm.dart';
import 'package:flame_jam_2026/game/audio/minigame_sfx.dart';
import 'package:flame_jam_2026/game/components/bathroom_hair_minigame.dart';
import 'package:flame_jam_2026/game/components/character.dart';
import 'package:flame_jam_2026/game/components/code_sequence_minigame.dart';
import 'package:flame_jam_2026/game/components/dog_training_minigame.dart';
import 'package:flame_jam_2026/game/components/kitchen_minigame.dart';
import 'package:flame_jam_2026/game/components/music_rhythm_minigame.dart';
import 'package:flame_jam_2026/game/components/scene_background.dart';
import 'package:flame_jam_2026/game/components/soccer_minigame.dart';
import 'package:flame_jam_2026/game/dialogue/say.dart';
import 'package:flame_jam_2026/game/dialogue/talk_dialog.dart';
import 'package:flame_jam_2026/game/story/game_story.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final _dialogueBox = BoxDecoration(
  color: Colors.white.withValues(alpha: 0.93),
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: Colors.black, width: 3.5),
  boxShadow: const [
    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
  ],
);

class _WoofBubble extends PositionComponent {
  _WoofBubble({required super.position})
    : super(size: Vector2(140, 60), anchor: Anchor.bottomCenter, priority: 20);

  final TextPaint _text = TextPaint(
    style: GoogleFonts.sniglet(
      color: const Color(0xFF6C4316),
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(999),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xF0FFFFFF));
    _text.render(canvas, 'WOOF!', Vector2(28, 14));
  }
}

class _PortraitSpec {
  const _PortraitSpec({
    required this.width,
    required this.height,
    required this.zoom,
    this.softening = 0.45,
    this.offsetX = 0,
    this.offsetY = 0,
    this.outsideOffset = 14,
    this.topOffset = -52,
    this.flipHorizontally = false,
  });

  final double width;
  final double height;
  final double zoom;
  final double softening;
  final double offsetX;
  final double offsetY;
  final double outsideOffset;
  final double topOffset;
  final bool flipHorizontally;
}

class MyGame extends FlameGame {
  MyGame({
    this.bootToSoccerDebug = false,
    this.bootToBathroomDebug = false,
    this.bootToMusicDebug = false,
    this.bootToCodeDebug = false,
    this.bootToFrontHouseDebug = false,
    this.bootToQuintalDebug = false,
    this.bootToFinaleDebug = false,
  });

  final bool bootToSoccerDebug;
  final bool bootToBathroomDebug;
  final bool bootToMusicDebug;
  final bool bootToCodeDebug;
  final bool bootToFrontHouseDebug;
  final bool bootToQuintalDebug;
  final bool bootToFinaleDebug;

  List<StoryLine> currentDialogue = const [];
  BuildContext? _dialogueContext;

  Character? _bro1;
  Character? _chubby;
  Character? _blonde;
  Character? _big;
  Character? _suit;
  Character? _blue;
  Character? _strong;
  SpriteComponent? _dogSceneProp;
  SpriteComponent? _wifiProp;
  _WifiLightComponent? _wifiLight;

  KitchenMinigameComponent? _kitchenMinigame;
  SoccerMinigameComponent? _soccerMinigame;
  BathroomHairMinigameComponent? _bathroomMinigame;
  MusicRhythmMinigameComponent? _musicMinigame;
  CodeSequenceMinigameComponent? _codeMinigame;
  DogTrainingMinigameComponent? _dogTrainingMinigame;

  int lastKitchenMinigameScore = 0;

  int get kitchenMinigameTargetScore => KitchenMinigameComponent.minimumScore;

  void setDialogueContext(BuildContext context) {
    _dialogueContext = context;
  }

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(width: 1280, height: 720);

    await images.loadAll([
      'bg/sala.png',
      'bg/kitchen.png',
      'bg/quintal.png',
      'bg/bathroom.png',
      'bg/musicroom.png',
      'bg/room.png',
      'bg/front_house.png',
      'chars/bro1.png',
      'chars/bro1_smileface.png',
      'chars/bro1_wowface.png',
      'chars/bro1_noface.png',
      'chars/bro1chorando.png',
      'chars/chubby.png',
      'chars/chubby2.png',
      'chars/chubbyangry.png',
      'chars/blonde.png',
      'chars/blonde2.png',
      'chars/blondechallenge.png',
      'chars/big.png',
      'chars/big2.png',
      'chars/suit.png',
      'chars/suit2.png',
      'chars/blue.png',
      'chars/blue2.png',
      'chars/bluesurprise.png',
      'chars/bluethink.png',
      'chars/strong.png',
      'chars/strong2.png',
      'chars/strongangry.png',
      'props/apple.png',
      'props/abacaxi.png',
      'props/banana.png',
      'props/dogdie.png',
      'props/dogsit.png',
      'props/dogtalk.png',
      'props/gel.png',
      'props/laranja.png',
      'props/melancia.png',
      'props/morango.png',
      'props/partitura.png',
      'props/pente.png',
      'props/secador.png',
      'props/terminal.png',
      'props/bomb.png',
      'props/ball.png',
      'props/goal.png',
      'props/dog.png',
      'props/tv.png',
      'props/celular.png',
      'props/wifi.png',
      'ui/credits.png',
    ]);

    await MinigameSfx.preload();
    await GameBgm.preload();

    if (bootToFinaleDebug) {
      _loadSalaFinaleScene();
    } else if (bootToQuintalDebug) {
      _loadQuintalScene();
    } else if (bootToFrontHouseDebug) {
      _loadFrontHouseScene();
    } else if (bootToCodeDebug) {
      _loadCodeRoomScene();
    } else if (bootToMusicDebug) {
      _loadMusicRoomScene();
    } else if (bootToBathroomDebug) {
      _loadBathroomScene();
    } else if (bootToSoccerDebug) {
      _loadSoccerDebugScene();
    } else {
      overlays.add('menu');
    }
  }

  void startGame() {
    overlays.remove('menu');
    overlays.add('selectPlayer');
    GameBgm.play(GameBgm.selectplayer, volume: 0.3);
  }

  void startGameFromSelect() {
    GameBgm.stop();

    // Add a black overlay that fades out, matching _fadeToScene style.
    final fade = RectangleComponent(
      size: Vector2(1280, 720),
      anchor: Anchor.center,
      paint: ui.Paint()..color = const Color(0xFF000000),
      priority: 100,
    );
    fade.opacity = 1;
    world.add(fade);

    _loadSalaScene();

    final fadeOut = OpacityEffect.fadeOut(EffectController(duration: 0.8));
    fadeOut.onComplete = () => fade.removeFromParent();
    fade.add(fadeOut);
  }

  void showCredits() {
    overlays.remove('menu');
    _loadCreditsScene();
  }

  void returnToMainMenu() {
    GameBgm.stop();
    overlays.remove('credits');
    _clearWorld();
    overlays.add('menu');
  }

  void _loadSoccerDebugScene() {
    world.add(SceneBackground(imagePath: 'bg/quintal.png'));
    startSoccerMinigame();
  }

  // --- Sala Scene ---

  void _loadSalaScene() {
    final bg = SceneBackground(imagePath: 'bg/sala.png');

    _bro1 = Character(
      imagePath: 'chars/bro1.png',
      position: Vector2(-100, 280),
      characterHeight: 420,
    );

    world.addAll([bg, _bro1!]);

    GameBgm.play(GameBgm.sala);

    Future.delayed(const Duration(milliseconds: 600), _startSalaDialogue);
  }

  void _startSalaDialogue() {
    _showSceneDialogue(StorySceneId.salaIntro, onFinish: _playSalaTvEffect);
  }

  void _playSalaTvEffect() {
    // TODO: play TV turn-on SFX here (placeholder)

    final tv = SpriteComponent(
      sprite: Sprite(images.fromCache('props/tv.png')),
      position: Vector2.zero(),
      size: Vector2(700, 620),
      anchor: Anchor.center,
      priority: 10,
    );
    tv.opacity = 0;
    world.add(tv);

    // Fade in over 1s, hold for 0.5s, fade out over 0.5s
    final fadeIn = OpacityEffect.to(
      1.0,
      EffectController(duration: 1.0, curve: Curves.easeIn),
    );
    fadeIn.onComplete = () {
      Future.delayed(const Duration(milliseconds: 2000), () {
        final fadeOut = OpacityEffect.to(
          0.0,
          EffectController(duration: 0.5, curve: Curves.easeOut),
        );
        fadeOut.onComplete = () {
          tv.removeFromParent();
          _startSalaPostTvDialogue();
        };
        tv.add(fadeOut);
      });
    };
    tv.add(fadeIn);
  }

  void _startSalaPostTvDialogue() {
    GameBgm.play(GameBgm.suspense);
    _showSceneDialogue(StorySceneId.salaPostTv, onFinish: _walkBro1ToKitchen);
  }

  // --- Shared Transitions ---

  void _walkBro1ToKitchen() {
    if (_bro1 == null) return;

    _bro1!.flipHorizontally();
    _bro1!.startWalking();

    final moveEffect = MoveByEffect(
      Vector2(1200, 0),
      EffectController(duration: 2.0, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _bro1!.stopWalking();
      _fadeToScene(_loadKitchenScene);
    };
    _bro1!.add(moveEffect);
  }

  void _fadeToScene(VoidCallback loadScene) {
    final fade = RectangleComponent(
      size: Vector2(1280, 720),
      anchor: Anchor.center,
      paint: ui.Paint()..color = const Color(0xFF000000),
      priority: 100,
    );
    fade.opacity = 0;
    world.add(fade);

    final fadeIn = OpacityEffect.fadeIn(EffectController(duration: 0.8));
    fadeIn.onComplete = () {
      _clearWorld(keep: fade);
      loadScene();
      final fadeOut = OpacityEffect.fadeOut(EffectController(duration: 0.8));
      fadeOut.onComplete = () => fade.removeFromParent();
      fade.add(fadeOut);
    };
    fade.add(fadeIn);
  }

  void _clearWorld({Component? keep}) {
    final toRemove = world.children
        .where((component) => component != keep)
        .toList();
    world.removeAll(toRemove);

    _bro1 = null;
    _chubby = null;
    _blonde = null;
    _big = null;
    _suit = null;
    _blue = null;
    _strong = null;
    _dogSceneProp = null;

    _kitchenMinigame = null;
    _soccerMinigame = null;
    _bathroomMinigame = null;
    _musicMinigame = null;
    _codeMinigame = null;
    _dogTrainingMinigame = null;
  }

  // --- Kitchen Scene ---

  void _loadKitchenScene() {
    final bg = SceneBackground(imagePath: 'bg/kitchen.png');

    _bro1 = Character(
      imagePath: 'chars/bro1.png',
      position: Vector2(-250, 280),
      characterHeight: 400,
    );

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: Vector2(50, 280),
      characterHeight: 340,
    );

    _bro1!.flipHorizontally();

    world.addAll([bg, _bro1!, _chubby!]);

    GameBgm.play(GameBgm.kitchen, volume: 0.35);

    Future.delayed(const Duration(milliseconds: 600), _startKitchenDialogue);
  }

  void _startKitchenDialogue() {
    _showSceneDialogue(
      StorySceneId.kitchenIntro,
      onFinish: _kitchenDialogueDone,
    );
  }

  void _kitchenDialogueDone() {
    if (_bro1 == null || _chubby == null) return;

    _bro1!.flipHorizontally();
    _bro1!.startWalking();
    final bro1Leave = MoveByEffect(
      Vector2(-900, 0),
      EffectController(duration: 1.8, curve: Curves.easeIn),
    );
    bro1Leave.onComplete = () {
      _bro1!.removeFromParent();
      _bro1 = null;
      _moveChubbyToCenter();
    };
    _bro1!.add(bro1Leave);
  }

  void _moveChubbyToCenter() {
    if (_chubby == null) return;

    _chubby!.startWalking();
    final chubbyMove = MoveByEffect(
      Vector2(-50, 0),
      EffectController(duration: 1.2, curve: Curves.easeInOut),
    );
    chubbyMove.onComplete = () {
      _chubby!.stopWalking();
      _chubby!.setImagePath('chars/chubby2.png');
      Future.delayed(const Duration(milliseconds: 1000), () {
        overlays.add('minigame');
      });
    };
    _chubby!.add(chubbyMove);
  }

  void startKitchenMinigame() {
    if (_kitchenMinigame != null) {
      return;
    }

    overlays.remove('minigameGameOver');
    _kitchenMinigame = KitchenMinigameComponent(
      onWin: _handleKitchenMinigameWin,
      onLose: _handleKitchenMinigameLoss,
    );
    world.add(_kitchenMinigame!);
    overlays.add('debugSkip');
  }

  void _handleKitchenMinigameWin() {
    overlays.remove('debugSkip');
    _kitchenMinigame = null;
    lastKitchenMinigameScore = kitchenMinigameTargetScore;
    _showSceneDialogue(
      StorySceneId.kitchenPostMinigame,
      onFinish: _walkChubbyToSala,
    );
  }

  void _handleKitchenMinigameLoss(int score) {
    _kitchenMinigame = null;
    lastKitchenMinigameScore = score;
    overlays.add('minigameGameOver');
  }

  void retryKitchenMinigame() {
    GameBgm.resume();
    overlays.remove('minigameGameOver');
    startKitchenMinigame();
  }

  void _walkChubbyToSala() {
    if (_chubby == null) return;

    _chubby!.startWalking();
    final moveEffect = MoveByEffect(
      Vector2(-900, 0),
      EffectController(duration: 1.8, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _chubby!.stopWalking();
      _fadeToScene(_loadSalaChubbyCheckScene);
    };
    _chubby!.add(moveEffect);
  }

  // --- Sala Chubby Check Scene ---

  void _loadSalaChubbyCheckScene() {
    final bg = SceneBackground(imagePath: 'bg/sala.png');

    _bro1 = Character(
      imagePath: 'chars/bro1.png',
      position: Vector2(-100, 280),
      characterHeight: 420,
    );
    _bro1!.flipHorizontally();

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: Vector2(300, 280),
      characterHeight: 340,
    );

    world.addAll([bg, _bro1!, _chubby!]);

    GameBgm.play(GameBgm.sala);

    Future.delayed(
      const Duration(milliseconds: 600),
      _startSalaChubbyCheckDialogue,
    );
  }

  void _startSalaChubbyCheckDialogue() {
    _showSceneDialogue(
      StorySceneId.salaChubbyCheck,
      onFinish: _playSalaChubbyTvEffect,
    );
  }

  void _playSalaChubbyTvEffect() {
    // TODO: play click SFX here (placeholder)

    final tv = SpriteComponent(
      sprite: Sprite(images.fromCache('props/tv.png')),
      position: Vector2.zero(),
      size: Vector2(700, 620),
      anchor: Anchor.center,
      priority: 10,
    );
    tv.opacity = 0;
    world.add(tv);

    final fadeIn = OpacityEffect.to(
      1.0,
      EffectController(duration: 1.0, curve: Curves.easeIn),
    );
    fadeIn.onComplete = () {
      Future.delayed(const Duration(milliseconds: 2000), () {
        final fadeOut = OpacityEffect.to(
          0.0,
          EffectController(duration: 0.5, curve: Curves.easeOut),
        );
        fadeOut.onComplete = () {
          tv.removeFromParent();
          _startSalaChubbyPostTvDialogue();
        };
        tv.add(fadeOut);
      });
    };
    tv.add(fadeIn);
  }

  void _startSalaChubbyPostTvDialogue() {
    _showSceneDialogue(
      StorySceneId.salaChubbyPostTv,
      onFinish: _walkChubbyToQuintal,
    );
  }

  void _walkChubbyToQuintal() {
    if (_chubby == null) return;

    _chubby!.startWalking();
    final moveEffect = MoveByEffect(
      Vector2(-900, 0),
      EffectController(duration: 1.8, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _chubby!.stopWalking();
      _fadeToScene(_loadQuintalScene);
    };
    _chubby!.add(moveEffect);
  }

  // --- Quintal Scene ---

  void _loadQuintalScene() {
    final bg = SceneBackground(imagePath: 'bg/quintal.png');

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: Vector2(-260, 300),
      characterHeight: 330,
    );

    _blonde = Character(
      imagePath: 'chars/blonde.png',
      position: Vector2(290, 320),
      characterHeight: 370,
    );

    _chubby!.flipHorizontally();
    _blonde!.flipHorizontally();

    world.addAll([bg, _chubby!, _blonde!]);

    GameBgm.play(GameBgm.soccer, volume: 0.25);

    Future.delayed(const Duration(milliseconds: 600), _startQuintalDialogue);
  }

  void _startQuintalDialogue() {
    _showSceneDialogue(StorySceneId.quintalIntro, onFinish: _showSoccerOverlay);
  }

  void _showSoccerOverlay() {
    _chubby?.setImagePath('chars/chubby.png');
    overlays.add('soccer');
  }

  void startSoccerMinigame() {
    if (_soccerMinigame != null) {
      return;
    }

    overlays.remove('soccer');
    _chubby?.removeFromParent();
    _blonde?.removeFromParent();
    _chubby = null;
    _blonde = null;

    _soccerMinigame = SoccerMinigameComponent();
    world.add(_soccerMinigame!);
    overlays.add('debugSkip');
  }

  void finishSoccerMinigameWin() {
    overlays.remove('debugSkip');
    _soccerMinigame?.removeFromParent();
    _soccerMinigame = null;

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: Vector2(-260, 300),
      characterHeight: 330,
    );
    _blonde = Character(
      imagePath: 'chars/blondechallenge.png',
      position: Vector2(290, 320),
      characterHeight: 370,
    );

    _chubby!.flipHorizontally();
    _blonde!.flipHorizontally();

    world.addAll([_chubby!, _blonde!]);

    Future.delayed(const Duration(milliseconds: 220), () {
      _showSceneDialogue(
        StorySceneId.soccerPostWin,
        onFinish: _playPhoneCallEffect,
      );
    });
  }

  void _playPhoneCallEffect() {
    // TODO: play phone dialing/calling SFX here (placeholder)

    final phone = _PhoneCallComponent(
      phoneSprite: Sprite(images.fromCache('props/celular.png')),
    );
    phone.opacity = 0;
    world.add(phone);

    final fadeIn = OpacityEffect.to(
      1.0,
      EffectController(duration: 0.8, curve: Curves.easeIn),
    );
    fadeIn.onComplete = () {
      Future.delayed(const Duration(milliseconds: 2500), () {
        final fadeOut = OpacityEffect.to(
          0.0,
          EffectController(duration: 0.5, curve: Curves.easeOut),
        );
        fadeOut.onComplete = () {
          phone.removeFromParent();
          _startSoccerPostPhoneDialogue();
        };
        phone.add(fadeOut);
      });
    };
    phone.add(fadeIn);
  }

  void _startSoccerPostPhoneDialogue() {
    _showSceneDialogue(
      StorySceneId.soccerPostPhone,
      onFinish: () => _fadeToScene(_loadBathroomScene),
    );
  }

  // --- Bathroom Scene ---

  void _loadBathroomScene() {
    final bg = SceneBackground(imagePath: 'bg/bathroom.png');

    _blonde = Character(
      imagePath: 'chars/blonde.png',
      position: Vector2(-260, 320),
      characterHeight: 370,
    );

    _big = Character(
      imagePath: 'chars/big2.png',
      position: Vector2(160, 315),
      characterHeight: 473,
    );
    _big!.flipHorizontally();

    _wifiProp = SpriteComponent(
      sprite: Sprite(images.fromCache('props/wifi.png')),
      position: Vector2(350, -160),
      size: Vector2(75, 75),
      anchor: Anchor.center,
      priority: 2,
    );

    _wifiLight = _WifiLightComponent(
      position: Vector2(352, -141),
      radius: 3.45,
    );

    world.addAll([bg, _wifiProp!, _wifiLight!, _blonde!, _big!]);

    GameBgm.play(GameBgm.bathroom, volume: 0.65);

    Future.delayed(const Duration(milliseconds: 600), _startBathroomDialogue);
  }

  void _startBathroomDialogue() {
    _showSceneDialogue(
      StorySceneId.bathroomIntro,
      onFinish: _showBathroomOverlay,
      padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
    );
  }

  void _showBathroomOverlay() {
    overlays.add('bathroom');
  }

  void startBathroomMinigame() {
    if (_bathroomMinigame != null) {
      return;
    }

    overlays.remove('bathroom');
    _bathroomMinigame = BathroomHairMinigameComponent(
      onWin: _handleBathroomMinigameWin,
    );
    world.add(_bathroomMinigame!);
    overlays.add('debugSkip');
  }

  void _handleBathroomMinigameWin() {
    overlays.remove('debugSkip');
    _bathroomMinigame?.removeFromParent();
    _bathroomMinigame = null;

    // Change big sprite back to default
    _big?.setImagePath('chars/big.png');

    _showSceneDialogue(
      StorySceneId.bathroomPostMinigame,
      onFinish: _playWifiResetEffect,
      padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
    );
  }

  void _playWifiResetEffect() {
    if (_big == null) return;

    final viewfinder = camera.viewfinder;

    // Big flips to face the wifi extender
    _big!.flipHorizontally();

    Future.delayed(const Duration(milliseconds: 500), () {
      // Zoom in toward the wifi extender
      viewfinder.add(
        ScaleEffect.to(
          Vector2.all(1.5),
          EffectController(duration: 0.8, curve: Curves.easeInOut),
        ),
      );
      viewfinder.add(
        MoveEffect.to(
          Vector2(350, -140),
          EffectController(duration: 0.8, curve: Curves.easeInOut),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1800), () {
        // TODO: play click SFX here (placeholder)

        // Light goes red
        _wifiLight?.setColor(const Color(0xFFDD3333));

        Future.delayed(const Duration(milliseconds: 1000), () {
          // Light goes back to green
          _wifiLight?.setColor(const Color(0xFF33DD33));

          Future.delayed(const Duration(milliseconds: 800), () {
            // Zoom back out
            viewfinder.add(
              ScaleEffect.to(
                Vector2.all(1.0),
                EffectController(duration: 0.7, curve: Curves.easeInOut),
              ),
            );
            viewfinder.add(
              MoveEffect.to(
                Vector2.zero(),
                EffectController(duration: 0.7, curve: Curves.easeInOut),
              ),
            );

            Future.delayed(const Duration(milliseconds: 800), () {
              // Big flips back
              _big!.flipHorizontally();

              Future.delayed(const Duration(milliseconds: 400), () {
                _showSceneDialogue(
                  StorySceneId.bathroomPostReset,
                  onFinish: _playBathroomTextMessages,
                  padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
                );
              });
            });
          });
        });
      });
    });
  }

  void _playBathroomTextMessages() {
    final phone = _PhoneTextComponent(
      phoneSprite: Sprite(images.fromCache('props/celular.png')),
      messages: const [
        _TextMessage(
          text: 'Hey Lil Bro, is Brodaflix working now?',
          isFromMe: true,
        ),
        _TextMessage(text: 'Big Bro just reset the wifi.', isFromMe: true),
        _TextMessage(
          text: 'No... nothing changed, Big Bro :(',
          isFromMe: false,
        ),
      ],
    );
    // Start off-screen at the bottom
    phone.position = Vector2(0, 500);
    world.add(phone);

    // Slide up into view
    final slideIn = MoveEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.7, curve: Curves.easeOutCubic),
    );
    slideIn.onComplete = () {
      phone.startMessageAnimation(() {
        Future.delayed(const Duration(milliseconds: 1200), () {
          // Slide back down
          final slideOut = MoveEffect.to(
            Vector2(0, 500),
            EffectController(duration: 0.6, curve: Curves.easeInCubic),
          );
          slideOut.onComplete = () {
            phone.removeFromParent();
            _startBathroomPostPhoneDialogue();
          };
          phone.add(slideOut);
        });
      });
    };
    phone.add(slideIn);
  }

  void _startBathroomPostPhoneDialogue() {
    _showSceneDialogue(
      StorySceneId.bathroomPostPhone,
      onFinish: _walkBigToMusicRoom,
      padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
    );
  }

  void _walkBigToMusicRoom() {
    if (_big == null) return;

    _big!.startWalking();
    final moveEffect = MoveByEffect(
      Vector2(-940, 0),
      EffectController(duration: 1.7, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _big?.stopWalking();
      _fadeToScene(_loadMusicRoomScene);
    };
    _big!.add(moveEffect);
  }

  // --- Music Room Scene ---

  void _loadMusicRoomScene() {
    final bg = SceneBackground(imagePath: 'bg/musicroom.png');

    _big = Character(
      imagePath: 'chars/big.png',
      position: Vector2(-330, 306),
      characterHeight: 462,
    );

    _suit = Character(
      imagePath: 'chars/suit.png',
      position: Vector2(300, 308),
      characterHeight: 410,
    );

    world.addAll([bg, _big!, _suit!]);

    GameBgm.play(GameBgm.musicroom);

    Future.delayed(const Duration(milliseconds: 600), _startMusicRoomDialogue);
  }

  void _startMusicRoomDialogue() {
    _showSceneDialogue(
      StorySceneId.musicRoomIntro,
      onFinish: _showMusicRoomOverlay,
    );
  }

  void _showMusicRoomOverlay() {
    overlays.add('musicroom');
  }

  void startMusicMinigame() {
    if (_musicMinigame != null) {
      return;
    }

    overlays.remove('musicroom');
    GameBgm.pause();
    _musicMinigame = MusicRhythmMinigameComponent(
      onWin: _handleMusicMinigameWin,
    );
    world.add(_musicMinigame!);
    overlays.add('debugSkip');
  }

  void _handleMusicMinigameWin() {
    overlays.remove('debugSkip');
    _musicMinigame?.removeFromParent();
    _musicMinigame = null;

    GameBgm.resume();

    // Normalize suit sprite back to default
    _suit?.setImagePath('chars/suit.png');

    _showSceneDialogue(
      StorySceneId.musicRoomPostMinigame,
      onFinish: _playMusicRoomZoomEffect,
    );
  }

  void _playMusicRoomZoomEffect() {
    _showSceneDialogue(
      StorySceneId.musicRoomPostPhone,
      onFinish: _playMusicRoomSubscriptionCheck,
    );
  }

  void _playMusicRoomSubscriptionCheck() {
    final phone = _PhoneSubscriptionComponent(
      phoneSprite: Sprite(images.fromCache('props/celular.png')),
    );
    phone.position = Vector2(0, 500);
    world.add(phone);

    final slideIn = MoveEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.7, curve: Curves.easeOutCubic),
    );
    slideIn.onComplete = () {
      Future.delayed(const Duration(milliseconds: 2500), () {
        final slideOut = MoveEffect.to(
          Vector2(0, 500),
          EffectController(duration: 0.6, curve: Curves.easeInCubic),
        );
        slideOut.onComplete = () {
          phone.removeFromParent();

          // Change suit back to default
          _suit?.setImagePath('chars/suit.png');

          _showSceneDialogue(
            StorySceneId.musicRoomPostSubscription,
            onFinish: _walkSuitToCodeRoom,
          );
        };
        phone.add(slideOut);
      });
    };
    phone.add(slideIn);
  }

  void _walkSuitToCodeRoom() {
    if (_suit == null) return;

    _suit!.startWalking();
    final moveEffect = MoveByEffect(
      Vector2(920, 0),
      EffectController(duration: 1.5, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _suit?.stopWalking();
      _fadeToScene(_loadCodeRoomScene);
    };
    _suit!.add(moveEffect);
  }

  // --- Code Room Scene ---

  void _loadCodeRoomScene() {
    final bg = SceneBackground(imagePath: 'bg/room.png');

    _suit = Character(
      imagePath: 'chars/suit.png',
      position: Vector2(-260, 312),
      characterHeight: 400,
    );

    _blue = Character(
      imagePath: 'chars/blue.png',
      position: Vector2(320, 318),
      characterHeight: 390,
    );
    _blue!.flipHorizontally();

    world.addAll([bg, _suit!, _blue!]);

    GameBgm.play(GameBgm.room, volume: 0.25);

    Future.delayed(const Duration(milliseconds: 600), _startCodeRoomDialogue);
  }

  void _startCodeRoomDialogue() {
    _showSceneDialogue(StorySceneId.codeRoomIntro, onFinish: _swapSuitAndBlue);
  }

  void _swapSuitAndBlue() {
    if (_suit == null || _blue == null) return;

    // Suit walks right, blue walks left — they swap positions
    _suit!.startWalking();
    _blue!.startWalking();

    final suitMove = MoveEffect.to(
      Vector2(320, 312),
      EffectController(duration: 1.2, curve: Curves.easeInOut),
    );
    final blueMove = MoveEffect.to(
      Vector2(-260, 318),
      EffectController(duration: 1.2, curve: Curves.easeInOut),
    );

    suitMove.onComplete = () {
      _suit!.stopWalking();
    };
    blueMove.onComplete = () {
      _blue!.stopWalking();

      // Blue changes to his other sprite
      _blue!.setImagePath('chars/blue2.png');

      Future.delayed(const Duration(milliseconds: 500), () {
        _showCodeOverlay();
      });
    };

    _suit!.add(suitMove);
    _blue!.add(blueMove);
  }

  void _showCodeOverlay() {
    overlays.add('coding');
  }

  void startCodeMinigame() {
    if (_codeMinigame != null) {
      return;
    }

    overlays.remove('coding');
    _codeMinigame = CodeSequenceMinigameComponent(
      onWin: _handleCodeMinigameWin,
    );
    world.add(_codeMinigame!);
    overlays.add('debugSkip');
  }

  void _handleCodeMinigameWin() {
    overlays.remove('debugSkip');
    _codeMinigame?.removeFromParent();
    _codeMinigame = null;

    // Normalize blue: default sprite, not flipped (now on the left side)
    _blue!.setImagePath('chars/blue.png');
    _blue!.flipHorizontally();

    Future.delayed(const Duration(milliseconds: 800), () {
      _showSceneDialogue(
        StorySceneId.codeRoomPostMinigame,
        onFinish: _playCodeRoomNothingZoom,
      );
    });
  }

  void _playCodeRoomNothingZoom() {
    // Switch to alt sprite for the "Nothing!" moment
    _blue!.setImagePath('chars/blue2.png');

    // Zoom in on blue's face for "Nothing!"
    final viewfinder = camera.viewfinder;
    viewfinder.add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );
    viewfinder.add(
      MoveEffect.to(
        Vector2(-260, -30),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      _showSceneDialogue(
        StorySceneId.codeRoomPostNothing,
        onFinish: _zoomOutAfterNothing,
      );
    });
  }

  void _zoomOutAfterNothing() {
    final viewfinder = camera.viewfinder;
    // Force position/scale in case previous effects didn't land
    viewfinder.position = Vector2(-260, -30);
    viewfinder.scale = Vector2.all(1.5);

    viewfinder.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );
    viewfinder.add(
      MoveEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      // Switch back to default sprite after unzoom
      _blue!.setImagePath('chars/blue.png');

      _showSceneDialogue(
        StorySceneId.codeRoomPostNothingCont,
        onFinish: _walkBlueToFrontHouse,
      );
    });
  }

  void _walkBlueToFrontHouse() {
    if (_blue == null) return;

    _blue!.flipHorizontally();
    _blue!.startWalking();
    final moveEffect = MoveByEffect(
      Vector2(-960, 0),
      EffectController(duration: 1.5, curve: Curves.easeIn),
    );
    moveEffect.onComplete = () {
      _blue?.stopWalking();
      _fadeToScene(_loadFrontHouseScene);
    };
    _blue!.add(moveEffect);
  }

  // --- Front House Scene ---

  void _loadFrontHouseScene() {
    final bg = SceneBackground(imagePath: 'bg/front_house.png');

    _blue = Character(
      imagePath: 'chars/blue.png',
      position: Vector2(-280, 338),
      characterHeight: 390,
    );
    _strong = Character(
      imagePath: 'chars/strong.png',
      position: Vector2(330, 338),
      characterHeight: 420,
    );
    _dogSceneProp = _buildDogSceneProp();
    _dogFacingLeft = false;

    world.addAll([bg, _blue!, _strong!, _dogSceneProp!]);

    GameBgm.play(GameBgm.fronthouse, volume: 0.65);

    Future.delayed(const Duration(milliseconds: 600), _startFrontHouseDialogue);
  }

  SpriteComponent _buildDogSceneProp() {
    return SpriteComponent(
      sprite: Sprite(images.fromCache('props/dog.png')),
      position: Vector2(18, 380),
      size: Vector2(215, 210),
      anchor: Anchor.bottomCenter,
      priority: 8,
    );
  }

  void _startFrontHouseDialogue() {
    _showSceneDialogue(
      StorySceneId.frontHouseIntro,
      onFinish: _playDogBarkZoom,
    );
  }

  void _playDogBarkZoom() {
    final dog = _dogSceneProp;
    if (dog == null) {
      _startFrontHouseIntroCont();
      return;
    }

    // Zoom camera into the dog.
    final viewfinder = camera.viewfinder;
    // Offset camera target above the dog so he appears in the lower portion of the frame.
    final dogCenter = Vector2(
      dog.position.x,
      dog.position.y - dog.size.y * 1.0,
    );
    viewfinder.add(
      ScaleEffect.to(
        Vector2.all(1.8),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );
    viewfinder.add(
      MoveEffect.to(
        dogCenter,
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );

    // After zoom completes, bark then zoom out.
    Future.delayed(const Duration(milliseconds: 800), () {
      _playDogBark(dog);

      Future.delayed(const Duration(milliseconds: 900), () {
        _zoomOutFromDog();
      });
    });
  }

  void _zoomOutFromDog() {
    final viewfinder = camera.viewfinder;
    viewfinder.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );
    viewfinder.add(
      MoveEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.6, curve: Curves.easeInOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      _startFrontHouseIntroCont();
    });
  }

  void _startFrontHouseIntroCont() {
    _showSceneDialogue(
      StorySceneId.frontHouseIntroCont,
      onFinish: _showDogTrainingOverlay,
    );
  }

  void _showDogTrainingOverlay() {
    overlays.add('dogTraining');
  }

  void startDogTrainingMinigame() {
    if (_dogTrainingMinigame != null) {
      return;
    }

    overlays.remove('dogTraining');
    _dogTrainingMinigame = DogTrainingMinigameComponent(
      onWin: _handleDogTrainingMinigameWin,
    );
    world.add(_dogTrainingMinigame!);
    overlays.add('debugSkip');
  }

  void _handleDogTrainingMinigameWin() {
    overlays.remove('debugSkip');
    _dogTrainingMinigame?.removeFromParent();
    _dogTrainingMinigame = null;
    _showSceneDialogue(
      StorySceneId.frontHousePostMinigame,
      onFinish: _playFrontHousePhoneMessages,
    );
  }

  void _playFrontHousePhoneMessages() {
    // Strong back to normal sprite before phone.
    _strong?.setImagePath('chars/strong.png');

    final phone = _PhoneTextComponent(
      phoneSprite: Sprite(images.fromCache('props/celular.png')),
      messages: const [
        _TextMessage(
          text: 'Hey Bob, sorry to bother you on a Sunday.',
          isFromMe: true,
        ),
        _TextMessage(text: 'Can you do me a quick favor?', isFromMe: true),
        _TextMessage(
          text:
              "My lil bro is trying to watch Brodaflix but it isn't working...",
          isFromMe: true,
        ),
        _TextMessage(
          text:
              'Is there any issue going on or something wrong with my family account?',
          isFromMe: true,
        ),
        _TextMessage(
          text: 'Hey, just a minute, gonna check it for you.',
          isFromMe: false,
        ),
        _TextMessage(
          text: 'Well, there seems to be no issues at all...',
          isFromMe: false,
        ),
        _TextMessage(
          text: 'Both your account and our services are normal.',
          isFromMe: false,
        ),
        _TextMessage(
          text: 'Is there anything else I can do for you?',
          isFromMe: false,
        ),
        _TextMessage(text: 'Got it, appreciate it man.', isFromMe: true),
        _TextMessage(
          text: 'I will talk to my brothers and figure out what happened.',
          isFromMe: true,
        ),
        _TextMessage(
          text: 'Thank you so much and sorry for the trouble.',
          isFromMe: true,
        ),
        _TextMessage(
          text: "Don't mention it, enjoy your Sunday!",
          isFromMe: false,
        ),
      ],
      maxVisibleMessages: 6,
    );
    phone.position = Vector2(0, 500);
    world.add(phone);

    final slideIn = MoveEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.7, curve: Curves.easeOutCubic),
    );
    slideIn.onComplete = () {
      phone.startMessageAnimation(() {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!phone.isMounted) {
            _startFrontHousePostPhoneDialogue();
            return;
          }
          final slideOut = MoveEffect.to(
            Vector2(0, 500),
            EffectController(duration: 0.6, curve: Curves.easeInCubic),
          );
          slideOut.onComplete = () {
            phone.removeFromParent();
            _startFrontHousePostPhoneDialogue();
          };
          phone.add(slideOut);
        });
      });
    };
    phone.add(slideIn);
  }

  void _startFrontHousePostPhoneDialogue() {
    _showSceneDialogue(
      StorySceneId.frontHousePostPhone,
      onFinish: _playFrontHouseChase,
    );
  }

  void _playFrontHouseChase() {
    if (_blue == null || _strong == null) return;

    // Blue changes to scared sprite and flips to run left.
    _blue!.setImagePath('chars/blue2.png');
    _blue!.flipHorizontally();
    _blue!.startWalking();

    _blue!.add(
      MoveByEffect(
          Vector2(-1400, 0),
          EffectController(duration: 2.0, curve: Curves.easeIn),
        )
        ..onComplete = () {
          _blue!.stopWalking();
        },
    );

    // Strong and dog chase after a short delay.
    Future.delayed(const Duration(milliseconds: 400), () {
      _strong?.flipHorizontally();
      _strong?.startWalking();
      _strong?.add(
        MoveByEffect(
            Vector2(-1600, 0),
            EffectController(duration: 2.0, curve: Curves.easeIn),
          )
          ..onComplete = () {
            _strong?.stopWalking();
          },
      );

      _dogSceneProp?.flipHorizontallyAroundCenter();
      _dogSceneProp?.add(
        MoveByEffect(
            Vector2(-1600, 0),
            EffectController(duration: 2.0, curve: Curves.easeIn),
          )
          ..onComplete = () {
            _fadeToScene(_loadSalaFinaleScene);
          },
      );
    });
  }

  void _loadSalaFinaleScene() {
    GameBgm.stop();

    final bg = SceneBackground(imagePath: 'bg/sala.png');
    world.add(bg);

    // Characters enter one by one, alternating left/right.
    // They fill from center outward:
    //   blonde  bro1  chubby  big
    //     suit              blue  strong  [dog]

    _bro1 = Character(
      imagePath: 'chars/bro1_smileface.png',
      position: Vector2(-30, 280),
      characterHeight: 420,
    );

    _chubby = Character(
      imagePath: 'chars/chubby.png',
      position: Vector2(800, 290),
      characterHeight: 400,
    );

    _blonde = Character(
      imagePath: 'chars/blonde.png',
      position: Vector2(-800, 300),
      characterHeight: 410,
    );

    _big = Character(
      imagePath: 'chars/big.png',
      position: Vector2(800, 280),
      characterHeight: 430,
    );

    _suit = Character(
      imagePath: 'chars/suit.png',
      position: Vector2(-800, 290),
      characterHeight: 420,
    );

    _blue = Character(
      imagePath: 'chars/blue.png',
      position: Vector2(800, 290),
      characterHeight: 410,
    );

    _strong = Character(
      imagePath: 'chars/strong.png',
      position: Vector2(-800, 280),
      characterHeight: 420,
    );

    _dogSceneProp = _buildDogSceneProp();
    _dogSceneProp!.position = Vector2(-800, 420);
    _dogFacingLeft = false;

    _blonde!.flipHorizontally();
    _big!.flipHorizontally();
    _blue!.flipHorizontally();

    final allChars = [
      _bro1!,
      _chubby!,
      _blonde!,
      _big!,
      _suit!,
      _blue!,
      _strong!,
    ];
    world.addAll([...allChars, _dogSceneProp!]);

    // Entry order, side, and target X positions (center outward).
    //  bro1    → from left,  lands at -60  (center-left)
    //  chubby  → from right, lands at  60  (center-right)
    //  blonde  → from left,  lands at -220 (left of bro1)
    //  big     → from right, lands at  220 (right of chubby)
    //  suit    → from left,  lands at -380 (far left)
    //  blue    → from right, lands at  380 (far right)
    //  strong  → from left,  lands at -500 (furthest left)
    //  dog     → with strong, lands at -560

    final entries = <({Character char, bool fromLeft, double targetX})>[
      (char: _chubby!, fromLeft: false, targetX: 100),
      (char: _blonde!, fromLeft: true, targetX: -195),
      (char: _big!, fromLeft: false, targetX: 320),
      (char: _suit!, fromLeft: true, targetX: -280),
      (char: _blue!, fromLeft: false, targetX: 510),
      (char: _strong!, fromLeft: true, targetX: -470),
    ];

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      e.char.startWalking();

      final delay = 400 + (i * 450);
      Future.delayed(Duration(milliseconds: delay), () {
        e.char.add(
          MoveEffect.to(
              Vector2(e.targetX, e.char.position.y),
              EffectController(duration: 1.4, curve: Curves.easeOutCubic),
            )
            ..onComplete = () {
              e.char.stopWalking();
            },
        );

        // Dog enters together with Strong (last character).
        if (i == entries.length - 1) {
          _dogSceneProp!.add(
            MoveEffect.to(
              Vector2(e.targetX + 30, 420),
              EffectController(duration: 1.4, curve: Curves.easeOutCubic),
            ),
          );
        }
      });
    }

    // After everyone is in place, play bro1 look-around then start dialogue.
    final totalDelay = 400 + (entries.length * 450) + 1600;
    Future.delayed(Duration(milliseconds: totalDelay), _playBro1LookAround);
  }

  void _playBro1LookAround() {
    final bro1 = _bro1;
    if (bro1 == null) {
      _startFinaleDialogue();
      return;
    }

    // Flip right, left, right, left with brief pauses, then surprised face.
    const flipDelay = 300;
    bro1.flipHorizontally(); // face right
    Future.delayed(const Duration(milliseconds: flipDelay), () {
      bro1.flipHorizontally(); // face left
      Future.delayed(const Duration(milliseconds: flipDelay), () {
        bro1.flipHorizontally(); // face right
        Future.delayed(const Duration(milliseconds: flipDelay), () {
          bro1.flipHorizontally(); // face left (original)
          Future.delayed(const Duration(milliseconds: 200), () {
            bro1.setImagePath('chars/bro1_wowface.png');
            Future.delayed(const Duration(milliseconds: 600), () {
              bro1.setImagePath('chars/bro1_smileface.png');
              _startFinaleDialogue();
            });
          });
        });
      });
    });
  }

  void _startFinaleDialogue() {
    GameBgm.play(GameBgm.bathroom, volume: 0.65);
    _dogFlipEnabled = false;
    _showSceneDialogue(
      StorySceneId.salaFinale,
      padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
      onFinish: _playFinaleLaugh,
    );
  }

  void _playFinaleLaugh() {
    // Everyone bounces up and down asynchronously, like chuckling.
    final characters = <PositionComponent?>[
      _bro1,
      _chubby,
      _blonde,
      _big,
      _suit,
      _blue,
      _strong,
      _dogSceneProp,
    ];

    for (var i = 0; i < characters.length; i++) {
      final char = characters[i];
      if (char == null) continue;

      // Stagger start times so they bounce async.
      final staggerDelay = i * 120;
      Future.delayed(Duration(milliseconds: staggerDelay), () {
        char.add(
          MoveByEffect(
            Vector2(0, -20),
            EffectController(
              duration: 0.25,
              alternate: true,
              repeatCount: 6,
              curve: Curves.easeInOut,
              startDelay: 0,
            ),
          ),
        );
      });
    }

    // Show the HAHAHA text after a brief moment (no portrait, just text box).
    Future.delayed(const Duration(milliseconds: 300), () {
      final ctx = _dialogueContext;
      if (ctx == null) return;

      TalkDialog.show(
        ctx,
        [
          Say(
            text: [const TextSpan(text: 'HAHAHAHAHAHAHA')],
            person: const SizedBox.shrink(),
            personSize: Size.zero,
            personSayDirection: PersonSayDirection.LEFT,
            boxDecoration: _dialogueBox,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14.7),
          ),
        ],
        onFinish: () => _fadeToScene(_loadCreditsScene),
        backgroundColor: Colors.transparent,
        boxTextHeight: 147,
        padding: const EdgeInsets.fromLTRB(64, 75, 64, 24),
        talkAlignment: Alignment.topCenter,
        style: GoogleFonts.sniglet(
          color: Colors.black87,
          fontSize: 38,
          height: 1.4,
        ),
        speed: 30,
      );
    });
  }

  void _loadCreditsScene() {
    GameBgm.playOnce(GameBgm.credits, volume: 0.8, onComplete: returnToMainMenu);

    final bg = SceneBackground(imagePath: 'ui/credits.png');
    world.add(bg);

    // Show credits overlay after fade-in completes.
    Future.delayed(const Duration(milliseconds: 1000), () {
      overlays.add('credits');
    });
  }

  // --- Debug Skip ---

  void skipCurrentMinigame() {
    if (_kitchenMinigame != null) {
      _kitchenMinigame!.removeFromParent();
      _handleKitchenMinigameWin();
      return;
    }
    if (_soccerMinigame != null) {
      _soccerMinigame!.removeFromParent();
      _soccerMinigame = null;
      finishSoccerMinigameWin();
      return;
    }
    if (_bathroomMinigame != null) {
      _bathroomMinigame!.removeFromParent();
      _handleBathroomMinigameWin();
      return;
    }
    if (_musicMinigame != null) {
      _musicMinigame!.removeFromParent();
      _handleMusicMinigameWin();
      return;
    }
    if (_codeMinigame != null) {
      _codeMinigame!.removeFromParent();
      _handleCodeMinigameWin();
      return;
    }
    if (_dogTrainingMinigame != null) {
      _dogTrainingMinigame!.removeFromParent();
      _handleDogTrainingMinigameWin();
      return;
    }
  }

  // --- Dialogue ---

  void _showSceneDialogue(
    StorySceneId sceneId, {
    VoidCallback? onFinish,
    EdgeInsets? padding,
    void Function(int index)? onLineChanged,
  }) {
    _showDialogue(
      GameStory.scene(sceneId).lines,
      onFinish: onFinish,
      padding: padding,
      onLineChanged: onLineChanged,
    );
  }

  Future<void> _showDialogue(
    List<StoryLine> lines, {
    VoidCallback? onFinish,
    EdgeInsets? padding,
    void Function(int index)? onLineChanged,
  }) async {
    final ctx = _dialogueContext;
    if (ctx == null) return;

    currentDialogue = lines;
    await _precacheDialoguePortraits(ctx, lines);
    final says = _buildSays(lines);

    if (currentDialogue.isNotEmpty) {
      _applyDialogueLineState(currentDialogue.first);
    }
    onLineChanged?.call(0);

    TalkDialog.show(
      ctx,
      says,
      onFinish: onFinish,
      onChangeTalk: (index) {
        if (index < currentDialogue.length) {
          _applyDialogueLineState(currentDialogue[index]);
        }
        onLineChanged?.call(index);
      },
      backgroundColor: Colors.transparent,
      boxTextHeight: 147,
      padding: padding ?? const EdgeInsets.fromLTRB(64, 119.1, 64, 24),
      talkAlignment: Alignment.topCenter,
      style: GoogleFonts.sniglet(
        color: Colors.black87,
        fontSize: 38,
        height: 1.4,
      ),
      speed: 30,
    );
  }

  Future<void> _precacheDialoguePortraits(
    BuildContext context,
    List<StoryLine> lines,
  ) {
    final portraitPaths = {for (final line in lines) _portraitAssetFor(line)};

    return Future.wait([
      for (final path in portraitPaths)
        precacheImage(AssetImage(path), context),
    ]);
  }

  List<Say> _buildSays(List<StoryLine> lines) {
    return lines.map((line) {
      final portraitSpec = _portraitSpecFor(line);

      return Say(
        text: [TextSpan(text: line.text)],
        person: _buildPortrait(line, portraitSpec),
        personSize: Size(portraitSpec.width, portraitSpec.height),
        personOutsideOffset: portraitSpec.outsideOffset,
        personTopOffset: portraitSpec.topOffset,
        personSayDirection: _directionFor(line.side),
        boxDecoration: _dialogueBox,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14.7),
      );
    }).toList();
  }

  Widget _buildPortrait(StoryLine line, _PortraitSpec spec) {
    final accentColor = _portraitAccentColor(line.speaker);
    final accentHighlight = Color.lerp(accentColor, Colors.white, 0.58)!;
    final accentShadow = Color.lerp(accentColor, Colors.black, 0.24)!;

    return Container(
      width: spec.width,
      height: spec.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentHighlight.withValues(alpha: 0.98),
            const Color(0xFFFFF6EA),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: accentShadow.withValues(alpha: 0.32),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.82),
                    accentColor.withValues(alpha: 0.24),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -18,
              right: -8,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.48),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: 18,
              child: Transform.rotate(
                angle: -0.22,
                child: Container(
                  width: 56,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      accentColor.withValues(alpha: 0.34),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: spec.softening,
                sigmaY: spec.softening,
              ),
              child: Transform.translate(
                offset: Offset(spec.offsetX, spec.offsetY),
                child: Transform.scale(
                  scale: spec.zoom,
                  alignment: Alignment.topCenter,
                  child: Transform.flip(
                    flipX: spec.flipHorizontally,
                    child: Image.asset(
                      _portraitAssetFor(line),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PortraitSpec _portraitSpecFor(StoryLine line) {
    final base = _basePortraitSpecFor(line.speaker);
    if (line.flipHorizontally != null ||
        line.portraitOffsetX != null ||
        line.portraitOffsetY != null) {
      return _PortraitSpec(
        width: base.width,
        height: base.height,
        zoom: base.zoom,
        softening: base.softening,
        offsetX: line.portraitOffsetX ?? base.offsetX,
        offsetY: line.portraitOffsetY ?? base.offsetY,
        outsideOffset: base.outsideOffset,
        topOffset: base.topOffset,
        flipHorizontally: line.flipHorizontally ?? base.flipHorizontally,
      );
    }
    return base;
  }

  _PortraitSpec _basePortraitSpecFor(StoryActorId speaker) {
    switch (speaker) {
      case StoryActorId.bro1:
        return const _PortraitSpec(
          width: 150,
          height: 150,
          zoom: 3.55,
          softening: 0.45,
          offsetX: 0,
          offsetY: -68,
          outsideOffset: 6,
          topOffset: -22,
        );
      case StoryActorId.chubby:
        return const _PortraitSpec(
          width: 140,
          height: 140,
          zoom: 1.96,
          offsetY: -14,
          outsideOffset: 6,
          topOffset: -18,
          flipHorizontally: true,
        );
      case StoryActorId.blonde:
        return const _PortraitSpec(
          width: 142,
          height: 148,
          zoom: 2.72,
          offsetX: -16,
          offsetY: 6,
          outsideOffset: 6,
          topOffset: -20,
          flipHorizontally: true,
        );
      case StoryActorId.big:
        return const _PortraitSpec(
          width: 146,
          height: 146,
          zoom: 2.34,
          offsetY: -30,
          outsideOffset: 6,
          topOffset: -18,
        );
      case StoryActorId.suit:
        return const _PortraitSpec(
          width: 140,
          height: 146,
          zoom: 2.5,
          offsetY: -24,
          outsideOffset: 6,
          topOffset: -20,
        );
      case StoryActorId.blue:
        return const _PortraitSpec(
          width: 142,
          height: 146,
          zoom: 2.48,
          offsetY: -22,
          outsideOffset: 6,
          topOffset: -20,
        );
      case StoryActorId.strong:
        return const _PortraitSpec(
          width: 146,
          height: 146,
          zoom: 2.36,
          offsetY: 8,
          outsideOffset: 6,
          topOffset: -18,
        );
    }
  }

  Color _portraitAccentColor(StoryActorId actor) {
    switch (actor) {
      case StoryActorId.bro1:
        return const Color(0xFFE86A7A);
      case StoryActorId.chubby:
        return const Color(0xFFF2AE49);
      case StoryActorId.blonde:
        return const Color(0xFFE7C24A);
      case StoryActorId.big:
        return const Color(0xFFE77F67);
      case StoryActorId.suit:
        return const Color(0xFF8A6AD9);
      case StoryActorId.blue:
        return const Color(0xFF58A9E8);
      case StoryActorId.strong:
        return const Color(0xFF62B96F);
    }
  }

  String _portraitAssetFor(StoryLine line) {
    if (line.portraitAssetPath != null) {
      return line.portraitAssetPath!;
    }

    if (line.actorImagePath != null) {
      return 'assets/images/${line.actorImagePath!}';
    }

    return _defaultPortraitAssetFor(line.speaker);
  }

  String _defaultPortraitAssetFor(StoryActorId actor) {
    switch (actor) {
      case StoryActorId.bro1:
        return 'assets/images/chars/bro1.png';
      case StoryActorId.chubby:
        return 'assets/images/chars/chubby.png';
      case StoryActorId.blonde:
        return 'assets/images/chars/blonde.png';
      case StoryActorId.big:
        return 'assets/images/chars/big.png';
      case StoryActorId.suit:
        return 'assets/images/chars/suit.png';
      case StoryActorId.blue:
        return 'assets/images/chars/blue.png';
      case StoryActorId.strong:
        return 'assets/images/chars/strong.png';
    }
  }

  String _defaultCharacterImagePathFor(StoryActorId actor) {
    switch (actor) {
      case StoryActorId.bro1:
        return 'chars/bro1.png';
      case StoryActorId.chubby:
        return 'chars/chubby.png';
      case StoryActorId.blonde:
        return 'chars/blonde.png';
      case StoryActorId.big:
        return 'chars/big.png';
      case StoryActorId.suit:
        return 'chars/suit.png';
      case StoryActorId.blue:
        return 'chars/blue.png';
      case StoryActorId.strong:
        return 'chars/strong.png';
    }
  }

  PersonSayDirection _directionFor(StoryDialogueSide side) {
    switch (side) {
      case StoryDialogueSide.left:
        return PersonSayDirection.LEFT;
      case StoryDialogueSide.right:
        return PersonSayDirection.RIGHT;
    }
  }

  void _applyDialogueLineState(StoryLine line) {
    _updateActorSpriteForLine(line);
    _playDialogueBounce(line.speaker);
    _flipDogTowardSpeaker(line);
  }

  /// Flips the dog scene prop to face the current speaker.
  /// Blue is on the left, so the dog flips horizontally to face left.
  /// Strong is on the right (original orientation), so no flip.
  bool _dogFacingLeft = false;
  bool _dogFlipEnabled = true;

  void _flipDogTowardSpeaker(StoryLine line) {
    if (!_dogFlipEnabled) return;
    final dog = _dogSceneProp;
    if (dog == null) return;

    final shouldFaceLeft = line.speaker == StoryActorId.blue;
    if (shouldFaceLeft == _dogFacingLeft) return;

    _dogFacingLeft = shouldFaceLeft;
    dog.flipHorizontallyAroundCenter();
  }

  void _playDogBark(SpriteComponent dog) {
    final defaultSprite = Sprite(images.fromCache('props/dog.png'));
    final barkSprite = Sprite(images.fromCache('props/dogtalk.png'));

    // Swap to bark sprite.
    dog.sprite = barkSprite;
    MinigameSfx.playWoof();

    // Jump up and back down.
    dog.add(
      MoveByEffect(
          Vector2(0, -30),
          EffectController(
            duration: 0.15,
            alternate: true,
            curve: Curves.easeOut,
          ),
        )
        ..onComplete = () {
          dog.sprite = defaultSprite;
        },
    );

    // WOOF bubble above the dog.
    final bubble = _WoofBubble(
      position: Vector2(dog.position.x, dog.position.y - dog.size.y - 16),
    );
    world.add(bubble);
    Future.delayed(const Duration(milliseconds: 600), () {
      bubble.removeFromParent();
    });
  }

  void _setActorImage(StoryActorId actor, String imagePath) {
    switch (actor) {
      case StoryActorId.bro1:
        _bro1?.setImagePath(imagePath);
        break;
      case StoryActorId.chubby:
        _chubby?.setImagePath(imagePath);
        break;
      case StoryActorId.blonde:
        _blonde?.setImagePath(imagePath);
        break;
      case StoryActorId.big:
        _big?.setImagePath(imagePath);
        break;
      case StoryActorId.suit:
        _suit?.setImagePath(imagePath);
        break;
      case StoryActorId.blue:
        _blue?.setImagePath(imagePath);
        break;
      case StoryActorId.strong:
        _strong?.setImagePath(imagePath);
        break;
    }
  }

  void _updateActorSpriteForLine(StoryLine line) {
    final imagePath =
        line.actorImagePath ?? _defaultCharacterImagePathFor(line.speaker);

    if (line.alsoChangeActor != null && line.alsoChangeActorImagePath != null) {
      _setActorImage(line.alsoChangeActor!, line.alsoChangeActorImagePath!);
    }

    switch (line.speaker) {
      case StoryActorId.bro1:
        _bro1?.setImagePath(imagePath);
        break;
      case StoryActorId.chubby:
        _chubby?.setImagePath(imagePath);
        break;
      case StoryActorId.blonde:
        _blonde?.setImagePath(imagePath);
        break;
      case StoryActorId.big:
        _big?.setImagePath(imagePath);
        break;
      case StoryActorId.suit:
        _suit?.setImagePath(imagePath);
        break;
      case StoryActorId.blue:
        _blue?.setImagePath(imagePath);
        break;
      case StoryActorId.strong:
        _strong?.setImagePath(imagePath);
        break;
    }
  }

  void _playDialogueBounce(StoryActorId actor) {
    switch (actor) {
      case StoryActorId.bro1:
        _bro1?.playTalkBounce();
        break;
      case StoryActorId.chubby:
        _chubby?.playTalkBounce();
        break;
      case StoryActorId.blonde:
        _blonde?.playTalkBounce();
        break;
      case StoryActorId.big:
        _big?.playTalkBounce();
        break;
      case StoryActorId.suit:
        _suit?.playTalkBounce();
        break;
      case StoryActorId.blue:
        _blue?.playTalkBounce();
        break;
      case StoryActorId.strong:
        _strong?.playTalkBounce();
        break;
    }
  }
}

class _PhoneCallComponent extends PositionComponent with HasPaint {
  _PhoneCallComponent({required this.phoneSprite})
    : super(
        position: Vector2.zero(),
        size: Vector2(400, 500),
        anchor: Anchor.center,
        priority: 10,
      );

  final Sprite phoneSprite;

  static final _titlePainter = TextPainter(
    text: const TextSpan(
      text: 'Brodaflix Support',
      style: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  static final _statusPainter = TextPainter(
    text: const TextSpan(
      text: 'No Answer',
      style: TextStyle(
        color: Color(0xFFDD3333),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  @override
  void render(Canvas canvas) {
    phoneSprite.render(canvas, size: size);

    final centerX = size.x / 2;
    final centerY = size.y / 2 - 30;

    // Call icon circle
    const iconRadius = 30.0;
    canvas.drawCircle(
      Offset(centerX, centerY),
      iconRadius,
      Paint()..color = const Color(0xFFDD3333),
    );

    // Phone icon using Flutter's Icons.phone material icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.phone.codePoint),
        style: TextStyle(
          fontSize: 32,
          fontFamily: Icons.phone.fontFamily,
          package: Icons.phone.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(centerX - iconPainter.width / 2, centerY - iconPainter.height / 2),
    );

    // Title text
    _titlePainter.layout(maxWidth: size.x - 40);
    _titlePainter.paint(
      canvas,
      Offset(centerX - _titlePainter.width / 2, centerY + iconRadius + 16),
    );

    // Status text
    _statusPainter.layout(maxWidth: size.x - 40);
    _statusPainter.paint(
      canvas,
      Offset(centerX - _statusPainter.width / 2, centerY + iconRadius + 42),
    );
  }
}

class _WifiLightComponent extends PositionComponent {
  _WifiLightComponent({required super.position, required this.radius})
    : super(
        size: Vector2(radius * 2, radius * 2),
        anchor: Anchor.center,
        priority: 3,
      );

  final double radius;
  Color _color = const Color(0xFF33DD33);

  void setColor(Color color) {
    _color = color;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = _color);
  }
}

class _TextMessage {
  const _TextMessage({required this.text, required this.isFromMe});

  final String text;
  final bool isFromMe;
}

class _PhoneTextComponent extends PositionComponent with HasPaint {
  _PhoneTextComponent({
    required this.phoneSprite,
    required this.messages,
    this.maxVisibleMessages = 0,
  }) : super(
         position: Vector2.zero(),
         size: Vector2(640, 620),
         anchor: Anchor.center,
         priority: 10,
       );

  final Sprite phoneSprite;
  final List<_TextMessage> messages;

  /// When > 0, only the last N messages are rendered (older ones disappear).
  final int maxVisibleMessages;
  int _visibleMessages = 0;
  bool _showingTyping = false;
  double _typingDotTimer = 0;
  VoidCallback? _onAllShown;

  void startMessageAnimation(VoidCallback onAllShown) {
    _onAllShown = onAllShown;
    _startTypingThenShow();
  }

  void _startTypingThenShow() {
    if (_visibleMessages >= messages.length) {
      _showingTyping = false;
      Future.delayed(const Duration(milliseconds: 800), () {
        _onAllShown?.call();
      });
      return;
    }

    // Show typing indicator
    _showingTyping = true;
    _typingDotTimer = 0;

    // Typing duration varies: longer pause before reply from other side.
    // Shorten durations when there are many messages.
    final isReply = !messages[_visibleMessages].isFromMe;
    final fast = messages.length > 6;
    final typingDuration = fast
        ? (isReply ? 2000 : 1400)
        : (isReply ? 2200 : 1400);

    Future.delayed(Duration(milliseconds: typingDuration), () {
      if (!isMounted) return;
      _showingTyping = false;
      _visibleMessages++;

      // Pause between messages
      final pauseDuration = fast
          ? (isReply ? 800 : 900)
          : (isReply ? 600 : 800);
      Future.delayed(
        Duration(milliseconds: pauseDuration),
        _startTypingThenShow,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_showingTyping) {
      _typingDotTimer += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    phoneSprite.render(canvas, size: size);

    final screenLeft = 175.0;
    final screenRight = size.x - 175.0;
    var yOffset = size.y / 2 - 200.0;

    final startIndex = maxVisibleMessages > 0
        ? (_visibleMessages - maxVisibleMessages).clamp(0, messages.length)
        : 0;

    for (var i = startIndex; i < _visibleMessages && i < messages.length; i++) {
      final msg = messages[i];
      yOffset = _renderBubble(
        canvas,
        msg.text,
        msg.isFromMe,
        yOffset,
        screenLeft,
        screenRight,
      );
    }

    // Typing indicator
    if (_showingTyping && _visibleMessages < messages.length) {
      final isFromMe = messages[_visibleMessages].isFromMe;
      final bubbleColor = isFromMe
          ? const Color(0xFF3478F6)
          : const Color(0xFFE5E5EA);
      final dotColor = isFromMe ? Colors.white70 : const Color(0xFF999999);

      const bubbleWidth = 70.0;
      const bubbleHeight = 36.0;
      final bubbleX = isFromMe ? screenRight - bubbleWidth : screenLeft;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX, yOffset, bubbleWidth, bubbleHeight),
        const Radius.circular(14),
      );
      canvas.drawRRect(rrect, Paint()..color = bubbleColor);

      // Animated dots
      for (var d = 0; d < 3; d++) {
        final phase = (_typingDotTimer * 3.0 + d * 0.8) % 2.0;
        final scale = phase < 1.0
            ? 0.6 + 0.4 * phase
            : 1.0 - 0.4 * (phase - 1.0);
        final dotRadius = 3.5 * scale;
        canvas.drawCircle(
          Offset(bubbleX + 20 + d * 14, yOffset + bubbleHeight / 2),
          dotRadius,
          Paint()..color = dotColor,
        );
      }
    }
  }

  double _renderBubble(
    Canvas canvas,
    String text,
    bool isFromMe,
    double yOffset,
    double screenLeft,
    double screenRight,
  ) {
    final bubbleColor = isFromMe
        ? const Color(0xFF3478F6)
        : const Color(0xFFE5E5EA);
    final textColor = isFromMe ? Colors.white : Colors.black;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: screenRight - screenLeft - 24);

    final bubbleWidth = textPainter.width + 24;
    final bubbleHeight = textPainter.height + 16;
    final bubbleX = isFromMe ? screenRight - bubbleWidth : screenLeft;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, yOffset, bubbleWidth, bubbleHeight),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, Paint()..color = bubbleColor);

    textPainter.paint(canvas, Offset(bubbleX + 12, yOffset + 8));

    return yOffset + bubbleHeight + 10;
  }
}

class _PhoneSubscriptionComponent extends PositionComponent with HasPaint {
  _PhoneSubscriptionComponent({required this.phoneSprite})
    : super(
        position: Vector2.zero(),
        size: Vector2(640, 620),
        anchor: Anchor.center,
        priority: 10,
      );

  final Sprite phoneSprite;

  @override
  void render(Canvas canvas) {
    phoneSprite.render(canvas, size: size);

    final centerX = size.x / 2;
    final centerY = size.y / 2 - 40;

    // Title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'Brodaflix Subscription',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(centerX - titlePainter.width / 2, centerY),
    );

    // Status
    final statusPainter = TextPainter(
      text: const TextSpan(
        text: 'Active',
        style: TextStyle(
          color: Color(0xFF33AA33),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    statusPainter.layout();
    statusPainter.paint(
      canvas,
      Offset(centerX - statusPainter.width / 2, centerY + 32),
    );
  }
}
