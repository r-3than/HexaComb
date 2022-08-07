import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'newplayscreen.dart';

class temp extends StatelessWidget {
  const temp({super.key});
  @override
  Widget build(BuildContext context) {
    final iso = IsometricTileMapExample();
    return (FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 1,
      child: Container(
          height: 900,
          child: GameWidget(game: iso),
          decoration: BoxDecoration(color: Colors.green)),
    ));
  }
}
