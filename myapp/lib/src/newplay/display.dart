import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'newplayscreen.dart';

class temp extends StatelessWidget {
  const temp({super.key});
  @override
  Widget build(BuildContext context) {
    final iso = IsometricTileMapExample();
    return (Column(
      children: [
        (Expanded(
          child: Container(
              child: SizedBox(
                child: GameWidget(game: iso, overlayBuilderMap: const {
                  'ActionMenu': _actionMenuBuilder,
                  'PauseMenuBtn': _pauseMenuBtnBuilder,
                  'PauseMenu': _pauseMenuBuilder,
                }),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              decoration: BoxDecoration(color: Colors.green)),
        ))
      ],
    ));
  }
}

//Make Widgets for Menu here

double btnSize = 65;
Color btnColor = Color.fromARGB(255, 229, 243, 210);
Color transColor = Color.fromARGB(0, 0, 0, 0);

Widget _actionMenuBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
  return Align(
    alignment: FractionalOffset.bottomLeft,
    child: Container(
      height: 100,
      child: Center(
          child: Row(children: [
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.track_changes, // track changes
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => pre(game)),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.tips_and_updates_outlined,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => pre(game)),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.check,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => pre(game))
      ])),
    ),
  );
}

void pre(IsometricTileMapExample test) {
  debugPrint(test.centerX.toString());
}

void pauseHandler(IsometricTileMapExample game) {
  if (game.overlays.isActive('PauseMenu')) {
    game.overlays.remove('PauseMenu');
    game.resumeEngine();
  } else {
    game.overlays.add('PauseMenu');
    game.pauseEngine();
  }
}

Widget _pauseMenuBtnBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
  return (Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        child: TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.menu,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => pauseHandler(game)),
      )));
}

Widget _pauseMenuBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
  return Center(
    child: Container(child: Text("Hello World!")),
  );
}
