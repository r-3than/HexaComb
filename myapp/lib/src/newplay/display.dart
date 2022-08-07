import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'newplayscreen.dart';

class temp extends StatelessWidget {
  const temp({super.key});
  @override
  Widget build(BuildContext context) {
    final iso = IsometricTileMapExample();
    return (FittedBox(
      child: Container(
          child: SizedBox(
            child: GameWidget(game: iso),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(color: Colors.green)),
    ));
  }
}
