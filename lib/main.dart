import 'package:flame/game.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flame_jam_2026/game/overlays/bathroom_overlay.dart';
import 'package:flame_jam_2026/game/overlays/code_overlay.dart';
import 'package:flame_jam_2026/game/overlays/debug_skip_overlay.dart';
import 'package:flame_jam_2026/game/overlays/dog_training_overlay.dart';
import 'package:flame_jam_2026/game/overlays/main_menu.dart';
import 'package:flame_jam_2026/game/overlays/minigame_game_over_overlay.dart';
import 'package:flame_jam_2026/game/overlays/minigame_overlay.dart';
import 'package:flame_jam_2026/game/overlays/musicroom_overlay.dart';
import 'package:flame_jam_2026/game/overlays/credits_overlay.dart';
import 'package:flame_jam_2026/game/overlays/select_player_overlay.dart';
import 'package:flame_jam_2026/game/overlays/soccer_overlay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([GoogleFonts.sniglet()]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    ),
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  //final game = MyGame();
  // final game = MyGame(bootToCodeDebug: true);
  final game = MyGame();
  // final game = MyGame(bootToBathroomDebug: true);
  // final game = MyGame(bootToSoccerDebug: true);
  // final game = MyGame(bootToQuintalDebug: true);
  // final game = MyGame(bootToCodeDebug: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game.setDialogueContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<MyGame>(
        game: game,
        overlayBuilderMap: {
          'menu': (context, game) => MainMenuOverlay(game: game),
          'minigame': (context, game) => MinigameOverlay(game: game),
          'minigameGameOver': (context, game) =>
              MinigameGameOverOverlay(game: game),
          'soccer': (context, game) => SoccerOverlay(game: game),
          'bathroom': (context, game) => BathroomOverlay(game: game),
          'musicroom': (context, game) => MusicRoomOverlay(game: game),
          'coding': (context, game) => CodeOverlay(game: game),
          'dogTraining': (context, game) => DogTrainingOverlay(game: game),
          'debugSkip': (context, game) => DebugSkipOverlay(game: game),
          'credits': (context, game) => CreditsOverlay(game: game),
          'selectPlayer': (context, game) =>
              SelectPlayerOverlay(game: game),
        },
        initialActiveOverlays: const [],
      ),
    );
  }
}
