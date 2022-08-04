// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';

class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    var size = 50;
    var angle = (math.pi * 2) / 6;
    path.moveTo(
        size * math.cos(angle * 1) + 100, size * math.sin(angle * 1) + 100);
    //path.lineTo(70, 20);
    for (int i = 1; i <= 6; i++) {
      double x = size * math.cos(angle * i);
      double y = size * math.sin(angle * i);
      path.lineTo(x + 100, y + 100);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(MyCustomClipper oldClipper) => false;
}

class HexPainter extends CustomPainter {
  HexPainter({
    required this.sides,
    required this.progress,
    required this.showPath,
    required this.showDots,
  });

  final double sides;
  final double progress;
  bool showDots, showPath;

  final Paint _paint = Paint()
    ..color = Colors.purple
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    var path = createPath(6, 10);
    PathMetric pathMetric = path.computeMetrics().first;
    Path extractPath =
        pathMetric.extractPath(0.0, pathMetric.length * progress);
    if (showPath) {
      canvas.drawPath(extractPath, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  Path createPath(int sides, double radius) {
    var offset = 1000;
    var path = Path();
    var angle = (math.pi * 2) / sides;
    path.moveTo(
        radius * math.cos(0.0) + offset, radius * math.sin(0.0) + offset);
    for (int i = 1; i <= sides; i++) {
      double x = radius * math.cos(angle * i);
      double y = radius * math.sin(angle * i);
      path.lineTo(x + offset, y + offset);
    }
    path.close();
    return path;
  }
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              Center(
                // This is the entirety of the "game".
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkResponse(
                        onTap: () => GoRouter.of(context).push('/settings'),
                        child: Image.asset(
                          'assets/images/settings.png',
                          semanticLabel: 'Settings',
                        ),
                      ),
                    ),
                    Center(
                        child: ClipPath(
                            clipper: MyCustomClipper(),
                            child: GestureDetector(
                                onTap: () {
                                  print("On Tap");
                                },
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration:
                                      BoxDecoration(color: Colors.green),
                                )))),
                    ClipPath(
                        clipper: MyCustomClipper(),
                        child: GestureDetector(
                            onTap: () {
                              print("On Tap");
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(color: Colors.green),
                            ))),
                    const Spacer(),
                    Text(
                        'Drag the slider to Hellow World ${widget.level.difficulty}%'
                        ' or above!'),
                    Consumer<LevelState>(
                      builder: (context, levelState, child) => Slider(
                        label: 'Level Progress',
                        autofocus: true,
                        value: levelState.progress / 100,
                        onChanged: (value) =>
                            levelState.setProgress((value * 100).round()),
                        onChangeEnd: (value) => levelState.evaluate(),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => GoRouter.of(context).pop(),
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      widget.level.difficulty,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
