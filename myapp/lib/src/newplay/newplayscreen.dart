import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class IsometricTileMapExample extends FlameGame
    with
        MouseMovementDetector,
        MultiTouchDragDetector,
        TapDetector,
        ScaleDetector {
  static const String description = '''
    Shows an example of how to use the `IsometricTileMapComponent`.\n\n
    Move the mouse over the board to see a selector appearing on the tiles.
  ''';

  static Vector2 lastCords = Vector2(0, 0);
  static Vector2 cameraCords = Vector2(0, 0);
  static Vector2 lastdelta = Vector2(0, 0);

  late double startZoom = 1.0;
  double centerX = 0;
  double centerY = 0;
  late double hexSize = size.x / (2 * (layers + layers - 1));
  double offset = 5;
  int layers = 4;

  late double maxSize = (hexSize + offset) * layers;

  late var gridInfo = generateGrid(hexSize, offset, centerX, centerY, layers);
  late gridData gameGridData = gridData(layers);
  late List<Polygon> shapes = gridInfo[0];
  late Map mapping = this.generateMapping(gridInfo[1]);
  late List<Color> colors = generateColors(shapes);

  late ShapesComponent HexGrid = ShapesComponent(shapes, colors);

  IsometricTileMapExample();

  @override
  Future<void> onLoad() async {
    Flame.device.fullScreen();
    camera.followVector2(cameraCords);
    gameGridData.updateColors(mapping, colors, HexGrid);
    debugPrint(camera.position.toString());
    overlays.add('PauseMenuBtn');
    overlays.add('ActionMenu');

    add(HexGrid);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onScaleStart(_) {
    startZoom = camera.zoom;
    debugPrint("hi");
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      if (startZoom * currentScale.y < 3 && startZoom * currentScale.y > 0.5) {
        camera.zoom = startZoom * currentScale.y;
      }
    }
  }

  @override
  void onDragUpdate(int pid, DragUpdateInfo event) {
    var delta = -event.delta.global;
    var newpos = cameraCords + delta;
    if (-maxSize > newpos.x) {
      newpos.x = -maxSize + 1;
    }
    if (-maxSize > newpos.y) {
      newpos.y = -maxSize + 1;
    }
    if (maxSize < newpos.x) {
      newpos.x = maxSize - 1;
    }
    if (maxSize < newpos.y) {
      newpos.y = maxSize - 1;
    }
    cameraCords = newpos;
    camera.followVector2(newpos);
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
    // parse to grid
    //debugPrint(q.toString() + " | " + r.toString());
    gameGridData.onClick(q, r);
    gameGridData.updateColors(mapping, colors, HexGrid);
    debugPrint(gameGridData.hexMatrix.toString());
  }

  @override
  void onDragStart(int pid, DragStartInfo startPosition) {
    super.onDragStart(pid, startPosition);
    lastCords = startPosition.eventPosition.game;
    debugPrint("START2...");
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
      Paint testPaint = Paint();
      testPaint.style = PaintingStyle.fill;
      testPaint.color = Color.fromARGB(255, 207, 117, 0);
      Shape tempShapes = shapes[i];
      Transform2D tempTrans = Transform2D();
      tempTrans.x = 3.00;
      tempTrans.y = 2.00;
      tempShapes = tempShapes.project(tempTrans);
      canvas.drawPath(tempShapes.asPath(), testPaint);
    }
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

class gridData {
  int gridLayers = 0;
  var hexMatrix = [];
  gridData(int layers) {
    gridLayers = layers;
    var temp = 0;
    for (var i = 0; i < layers - 1; i++) {
      hexMatrix.add([]);
      temp = 0;
      for (var j = 0; j < (layers - 1 - i); j++) {
        hexMatrix[i].add(null);
        temp++;
      }
      for (var j = 0; j < 2 * layers - 1 - temp; j++) {
        hexMatrix[i].add(0);
      }
    }

    hexMatrix.add([]);
    for (var i = 0; i < 2 * layers - 1; i++) {
      hexMatrix[layers - 1].add(0);
    }

    for (var i = 0; i < layers - 1; i++) {
      hexMatrix.add([]);
      temp = 0;
      for (var j = 0; j < (2 * layers - 2 - i); j++) {
        hexMatrix[i + layers].add(0);
        temp++;
      }
      for (var j = 0; j < 2 * layers - 1 - temp; j++) {
        hexMatrix[i + layers].add(null);
      }
    }
    //debugPrint(hexMatrix.toString());
  }
  void onClick(int x, int y) {
    if (0 <= x && x < hexMatrix.length && 0 <= y && y < hexMatrix.length) {
      if (hexMatrix[x][y] != null) {
        hexMatrix[x][y] = (hexMatrix[x][y] + 1) % 3;
      }
    }
    debugPrint(this.sameInRings(1, 2).toString());
  }

  bool sameInRings(int ring1, int ring2) {
    return amountInRing(ring1) == amountInRing(ring2);
  }

  int amountInRing(int ring) {
    int X = gridLayers;
    int Y = 0;
    int count = 0;
    int j = ring;
    count = 0;
    X = gridLayers - 1;
    Y = j - 1;
    if (hexMatrix[X][Y] != 0) {
      count++;
    }
    for (var i = 0; i < gridLayers - j; i++) {
      X++;
      debugPrint(X.toString() + "|" + Y.toString());
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      X--;
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      X--;
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      X++;
      if (hexMatrix[X][Y] != 0) {
        count++;
      }
    }
    return count;
  }

  void updateColors(Map mapping, List<Color> colors, ShapesComponent HexGrid) {
    for (var q = 0; q < hexMatrix.length; q++) {
      for (var r = 0; r < hexMatrix[q].length; r++) {
        if (hexMatrix[q][r] != null) {
          var toindex = mapping[q.toString() + "|" + r.toString()];
          var val = hexMatrix[q][r];
          int newval = 255 - (val.hashCode * 50);
          colors[toindex] = Color.fromARGB(255, newval, newval, newval);
          HexGrid.updateColor(colors);
        }
      }
    }
  }
}
