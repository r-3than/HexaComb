// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
          squarishMainArea: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(children: [
                  TextButton(
                      onPressed: () => (GoRouter.of(context).pop()),
                      child: Icon(
                        Icons.arrow_back, // track changes
                        size: 30,
                        color: Colors.green,
                      )),
                  Spacer(),
                  Text(
                    'Select level',
                    style:
                        TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                  ),
                  Spacer()
                ]),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    children: [
                      for (final level in gameLevels)
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  (playerProgress.highestLevelReached >=
                                          level.number - 1)
                                      ? Color.fromARGB(255, 26, 88, 196)
                                      : Color.fromARGB(255, 107, 125, 156),
                              shadowColor: Color.fromARGB(255, 15, 0, 150),
                            ),
                            onPressed: (playerProgress.highestLevelReached >=
                                    level.number - 1)
                                ? () => {
                                      GoRouter.of(context)
                                          .push("/play/session/${level.number}")
                                    }
                                : null,
                            child: Text(
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                "${level.number}")),
                    ]),
              ),
            ],
          ),
          rectangularMenuArea: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push(
                      '/play/session/${playerProgress.highestLevelReached + 1}');
                },
                child: const Text('Next Level'),
              ),
            ],
          )),
    );
  }
}
