import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class IsometricTileMapExample extends FlameGame
    with MouseMovementDetector, MultiTouchDragDetector {
  static const String description = '''
    Shows an example of how to use the `IsometricTileMapComponent`.\n\n
    Move the mouse over the board to see a selector appearing on the tiles.
  ''';

  final topLeft = Vector2.all(500);

  static const scale = 2.0;
  static const srcTileSize = 32.0;
  static const destTileSize = scale * srcTileSize;
  static Vector2 lastCords = Vector2(0, 0);
  static Vector2 cameraCords = Vector2(500, 500);
  static Vector2 lastdelta = Vector2(0, 0);

  static const halfSize = false;
  static const tileHeight = scale * (halfSize ? 32.0 : 32.0);
  static const suffix = halfSize ? '-short' : '';

  final originColor = Paint()..color = const Color(0xFFFF00FF);
  final originColor2 = Paint()..color = const Color(0xFFAA55FF);

  late IsometricTileMapComponent base;
  late Selector selector;

  IsometricTileMapExample();

  @override
  Future<void> onLoad() async {
    double maxSide = min(size.x, size.y);
    camera.viewport = FixedResolutionViewport(Vector2.all(maxSide));
    final someVector = Vector2(500, 500);
    debugPrint("HERE");

    camera.followVector2(someVector);

    debugPrint(camera.position.toString());
    debugPrint("HERE");
    final tilesetImage = await images.load('tiles$suffix.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2.all(srcTileSize),
    );
    final matrix = [
      [3, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 2, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    add(
      base = IsometricTileMapComponent(
        tileset,
        matrix,
        destTileSize: Vector2.all(destTileSize),
        tileHeight: tileHeight,
        position: topLeft,
      ),
    );

    final selectorImage = await images.load('selector$suffix.png');
    add(selector = Selector(destTileSize, selectorImage));

    //NEW
    final shapes = [Polygon(generateHex(50.0, 500.0, 500.0))];
    const colors = [Color.fromARGB(255, 56, 56, 32)];
    add(ShapesComponent(shapes, colors));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.renderPoint(topLeft, size: 5, paint: originColor);
    canvas.renderPoint(
      topLeft.clone()..y -= tileHeight,
      size: 50,
      paint: originColor2,
    );
  }

  @override
  void onDragUpdate(int pid, DragUpdateInfo event) {
    debugPrint("TEST");
    //super.onDragUpdate(event);
    var delta = -event.delta.global;
    var newpos = cameraCords + delta;
    camera.followVector2(newpos);
    cameraCords = newpos;
  }

  void onScaleUpdate(scaleinfo) {
    debugPrint("scaling");
  }

  @override
  void onDragStart(int pid, DragStartInfo startPosition) {
    super.onDragStart(pid, startPosition);
    lastCords = startPosition.eventPosition.game;
    debugPrint("START2...");
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.game;
    //camera.followVector2(screenPosition);
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.position.setFrom(topLeft + base.getBlockRenderPosition(block));
  }
}

class Selector extends SpriteComponent {
  bool show = true;

  Selector(double s, Image image)
      : super(
          sprite: Sprite(image, srcSize: Vector2.all(32.0)),
          size: Vector2.all(s),
        );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}

class ShapesComponent extends Component {
  ShapesComponent(this.shapes, List<Color> colors)
      : assert(
          shapes.length == colors.length,
          'The shapes and colors lists have to be of the same length',
        ),
        paints = colors
            .map(
              (color) => Paint()
                ..style = PaintingStyle.fill
                ..color = color,
            )
            .toList();

  final List<Shape> shapes;
  final List<Paint> paints;

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < shapes.length; i++) {
      canvas.drawPath(shapes[i].asPath(), paints[i]);
    }
  }
}

List<Vector2> generateHex(double r, double dx, double dy) {
  List<Vector2> coords = [];
  for (var i = 0; i < 6; i++) {
    var x = r * sin(i * pi / 3) + dx;
    var y = r * cos(i * pi / 3) + dy;
    coords.add(Vector2(x, y));
    debugPrint(Vector2(x, y).toString());
  }
  return coords;
}
