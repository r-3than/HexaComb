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
    with MouseMovementDetector, MultiTouchDragDetector, TapDetector {
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

  double centerX = 500;
  double centerY = 500;
  double hexSize = 50;
  double offset = 5;
  int layers = 5;

  late var gridInfo = generateGrid(hexSize, offset, centerX, centerY, layers);
  late List<Polygon> shapes = gridInfo[0];
  late Map mapping = this.generateMapping(gridInfo[1]);
  late List<Color> colors = generateColors(shapes);

  late ShapesComponent HexGrid = ShapesComponent(shapes, colors);

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
    //double maxSide = min(size.x, size.y);
    //camera.viewport = FixedResolutionViewport(Vector2.all(maxSide));
    final someVector = Vector2(500, 500);

    camera.followVector2(someVector);

    debugPrint(camera.position.toString());
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

    final selectorImage = await images.load('selector$suffix.png');
    //add(selector = Selector(destTileSize, selectorImage));

    //NEW
    //var shapes = generateGrid(30, 5, 500, 500, 5);

    add(HexGrid);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onDragUpdate(int pid, DragUpdateInfo event) {
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
  void onTapDown(TapDownInfo e) {
    debugPrint(e.eventPosition.game.toString());
    var x = e.eventPosition.game.x;
    var y = e.eventPosition.game.y;
    var q =
        ((sqrt(3) * (x - centerX) - (y - centerY)) / (3 * (hexSize + offset)))
                .round() +
            layers -
            1;
    var r = (((0 * x) + 2 * (y - centerY)) / (3 * (hexSize + offset))).round() +
        layers -
        1;
    debugPrint(q.toString() + " | " + r.toString());
    var toindex = mapping[q.toString() + "|" + r.toString()];
    debugPrint(mapping.keys.toString());
    debugPrint(mapping[q.toString() + "|" + r.toString()].toString());
    if (toindex != null) {
      if (colors[toindex] == Color.fromARGB(255, 229, 172, 63)) {
        colors[toindex] = Color.fromARGB(255, 255, 253, 122);
      } else {
        colors[toindex] = Color.fromARGB(255, 229, 172, 63);
      }

      HexGrid.updateColor(colors);
    }
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
    //final block = base.getBlock(screenPosition);
    //selector.show = base.containsBlock(block);
    //selector.position.setFrom(topLeft + base.getBlockRenderPosition(block));
  }

  Map generateMapping(List<double> centers) {
    var mapping = new Map();
    for (var i = 0; i < centers.length; i = i + 2) {
      var x = centers[i];
      var y = centers[i + 1];

      var q =
          ((sqrt(3) * (x - centerX) - (y - centerY)) / (3 * (hexSize + offset)))
                  .round() +
              layers -
              1;
      var r =
          (((0 * x) + 2 * (y - centerY)) / (3 * (hexSize + offset))).round() +
              layers -
              1;
      int intVal = (i / 2).round();
      mapping[q.toString() + "|" + r.toString()] = intVal;
    }
    debugPrint(mapping.toString());
    return mapping;
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
  late List<Paint> paints;
  void updateColor(colors) {
    var temp = colors
        .map(
          (color) => Paint()
            ..style = PaintingStyle.fill
            ..color = color,
        )
        .toList();
    paints = List<Paint>.from(temp);
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < shapes.length; i++) {
      canvas.drawPath(shapes[i].asPath(), paints[i]);
    }
  }
}

Polygon generateHex(double r, double dx, double dy) {
  List<Vector2> coords = [];
  for (var i = 0; i < 6; i++) {
    var x = r * sin((i * pi / 3)) + dx;
    var y = r * cos((i * pi / 3)) + dy;
    coords.add(Vector2(x, y));
  }
  return Polygon(coords);
}

List<dynamic> generateGrid(
    double r, double o, double ox, double oy, int layers) {
  List<Polygon> myHex = [];
  List<double> centers = [];
  var x = 0.0;
  var y = 0.0;
  var ty = 0.0;
  var tx = 0.0;
  int rotamt = 1;
  myHex.add(generateHex(r, ox, oy));
  centers.add(ox);
  centers.add(oy);
  for (var j = 0; j < layers; j++) {
    y = -j * 3 / 2 * (r + o);
    rotamt = 1;
    x = 0.0;
    x = sqrt(3) * 0.5 * j * (r + o);

    ty = 0.0;
    tx = 0.0;
    for (var i = 0; i < (j * 6); i++) {
      debugPrint("LOOP");
      y = y + ty;
      x = x + tx;
      debugPrint(i.toString());
      debugPrint((i / 6).floor().toString());
      myHex.add(generateHex(r, x + ox, y + oy));
      centers.add(x + ox);
      centers.add(y + oy);
      if (i % j == 0) {
        ty = sqrt(3) * (r + o) * sin((rotamt * pi) / 3);
        tx = sqrt(3) * (r + o) * cos((rotamt * pi) / 3);
        rotamt++;
      }
    }
  }

  return [myHex, centers];
}

List<Color> generateColors(List<Polygon> shapes) {
  List<Color> colors = [];
  for (var i = 0; i < shapes.length - 1; i++) {
    colors.add(Color.fromARGB(255, 255, 255, 255));
  }
  colors.add(Color.fromARGB(255, 255, 255, 255));
  return colors;
}
