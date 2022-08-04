import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

class DraggableComponent extends PositionComponent with Draggable {
  // update and render omitted

  Vector2 dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo event) {
    final localCoords = event.eventPosition.game;
    position = localCoords - dragDeltaPosition;
    return false;
  }
}

class IsometricTileMapExample extends FlameGame
    with MouseMovementDetector, VerticalDragDetector, HasDraggables {
  static const String description = '''
    Shows an example of how to use the `IsometricTileMapComponent`.\n\n
    Move the mouse over the board to see a selector appearing on the tiles.
  ''';

  final topLeft = Vector2.all(500);

  static const scale = 2.0;
  static const srcTileSize = 32.0;
  static const destTileSize = scale * srcTileSize;

  static const halfSize = true;
  static const tileHeight = scale * (halfSize ? 8.0 : 16.0);
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

    camera.followVector2(someVector);
    final tilesetImage = await images.load('tiles$suffix.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2.all(srcTileSize),
    );
    final matrix = [
      [3, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
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
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.renderPoint(topLeft, size: 5, paint: originColor);
    canvas.renderPoint(
      topLeft.clone()..y -= tileHeight,
      size: 5,
      paint: originColor2,
    );
  }

  void onDragUpdate(int pointerId, DragUpdateInfo event) {
    final localCoords = event.eventPosition.game;
    camera.followVector2(localCoords);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.game;
    camera.followVector2(screenPosition);
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
