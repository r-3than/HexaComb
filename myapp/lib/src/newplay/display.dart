import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
double textFontSize = 35;
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
    child: Container(
        width: MediaQuery.of(buildContext).size.width * 3 / 4,
        height: (btnSize + 16) * 5,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.all(18.0),
            child: ListView(
              //cont her TODO
              children: [
                OutlinedButton(
                    onPressed: () => pauseHandler(game),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Back",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => pauseHandler(game),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Level Select",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => back(buildContext),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Main Menu",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => pauseHandler(game),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Back",
                      style: TextStyle(fontSize: textFontSize),
                    )),
              ],
            ))),
  );
}

void back(BuildContext c) {
  GoRouter.of(c).pop();
}
