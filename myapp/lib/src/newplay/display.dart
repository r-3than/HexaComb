import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'newplayscreen.dart';

class temp extends StatelessWidget {
  const temp({super.key});
  @override
  Widget build(BuildContext context) {
    final iso = IsometricTileMapExample();
    return (FractionallySizedBox(
        child: Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height,
            child: GameWidget(game: iso),
            decoration: BoxDecoration(color: Colors.green))
      ],
    )));
  }
}
