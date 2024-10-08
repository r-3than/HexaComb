import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:HexaComb/src/audio/sounds.dart';
import 'package:HexaComb/src/player_progress/player_progress.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class HexGameFlame extends FlameGame
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
  static Vector2 cameraCords = Vector2(1000, 0);
  static Vector2 lastdelta = Vector2(0, 0);

  late Color mc;
  late Color ac;
  late Color sc;

  late double orgSizeX = size.x;
  late double orgSizeY = size.y;
  int score = 0;
  int par = 1;
  List<int> adjRule = [1, 2, 3, 4, 5, 6];
  List<int> ringRule = [1, 1];

  late double startZoom = 1.0;
  double centerX = 0;
  double centerY = 0;
  int layers = 4;
  late double hexSize = max(size.x / (2 * (layers + layers - 1)), 50);
  late double offset = max(2 * size.x / (3 * hexSize), 10);

  late double maxSize = (hexSize + offset) * layers;

  late var gridInfo = generateGrid(hexSize, offset, centerX, centerY, layers);
  late int level;
  //late gridData gameGridData = gridData(layers);
  late List<Polygon> shapes = gridInfo[0];
  late Map mapping = this.generateMapping(gridInfo[1]);
  late hexGrid HexGrid = hexGrid(shapes, mc, ac, sc, offset, layers, mapping);
  late List<Color> colors = generateColors(shapes);

  DateTime levelStart = DateTime.now();
  Duration durationLevel = DateTime.now().difference(DateTime.now());
  String timerString = "00:00";
  Timer? timer;
  //late ShapesComponent HexGrid = ShapesComponent(shapes, colors);

  HexGameFlame(levelLayers) {
    layers = levelLayers;
  }

  @override
  Future<void> onLoad() async {
    Flame.device.fullScreen();
    camera.moveTo(cameraCords); //=cameraCords;
    //HexGrid.setoffset(offset);
    //gameGridData.updateColors(mapping, colors, HexGrid);
    //debugPrint(camera.position.toString());
    overlays.add('PauseMenuBtn');
    overlays.add('ActionMenu');
    overlays.add("RulesMenu");
    overlays.add('Score');
    overlays.add("Clock");
    orgSizeX;
    orgSizeY;

    HexGrid.setAdjRules(adjRule);
    HexGrid.setRingRules(ringRule);
    HexGrid.par = par;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => timerTest());
    world.add(HexGrid);
  }

  void setTheme(Color nmc, Color nac, Color nsc) {
    mc = nmc;
    ac = nac;
    sc = nsc;
  }

  void timerTest() {
    durationLevel = DateTime.now().difference(levelStart);
    int durMin = durationLevel.inSeconds ~/ 60;
    int durSec = durationLevel.inSeconds % 60;
    timerString = (durMin < 10) ? "0" + durMin.toString() : durMin.toString();
    timerString = timerString + ":";
    timerString = timerString +
        ((durSec < 10) ? "0" + durSec.toString() : durSec.toString());
    overlays.remove("Clock");
    overlays.add("Clock");
  }

  String getAdjRulesData() {
    String baseString = "";
    if (adjRule.length - 2 >= 0) {
      for (var i = 0; i < adjRule.length - 2; i++) {
        baseString = baseString + adjRule[i].toString() + ",";
      }
    }
    if (adjRule.length != 1) {
      baseString = baseString + adjRule[adjRule.length - 2].toString() + " or ";
    }

    baseString = baseString +
        adjRule[adjRule.length - 1].toString() +
        " other on hexagon tiles.";
    return baseString;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onScaleStart(_) {
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity() && currentScale.y != 0) {
      if (startZoom * currentScale.y < 3 && startZoom * currentScale.y > 0.5) {
        camera.viewfinder.zoom = startZoom * currentScale.y;
      }
    }
  }

  @override
  void onDragUpdate(int pid, DragUpdateInfo event) {
    var delta = -event.delta.global * (1 / camera.viewfinder.zoom);
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
    camera.moveTo(newpos);
  }

  @override
  void onTapDown(TapDownInfo e) {
    debugPrint(e.eventPosition.global.toString());
    var x = e.eventPosition.global.x;
    var y = e.eventPosition.global.y;
    var q =
        ((sqrt(3) * (x - centerX) - (y - centerY)) / (3 * (hexSize + offset)))
                .round() +
            layers -
            1;
    var r = (((0 * x) + 2 * (y - centerY)) / (3 * (hexSize + offset))).round() +
        layers -
        1;

    HexGrid.onClick(q, r);

    score = HexGrid.score();
    overlays.remove("Score");
    overlays.add("Score");
  }

  @override
  void onDragStart(int pid, DragStartInfo startPosition) {
    //super.onDragStart(pid, startPosition);
    lastCords = startPosition.eventPosition.global;
    debugPrint("START2...");
    //camera.moveBy(Vector2(100, 100));
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

class hexGrid extends Component {
  late List<Polygon> shapes;
  late Color mainColor;
  late Color altColor;
  late Color shadowColor;
  late double offsetamt;
  late gridData hexGridData;
  List<int> adjRules = [];
  List<int> ringRules = [1, 1];
  int par = 1;
  hexGrid(List<Polygon> shapes, Color mainColor, Color altColor,
      Color shadowColor, double offsetamt, int layers, Map mapper) {
    shapes = shapes;
    mainColor = mainColor;
    altColor = altColor;
    shadowColor = shadowColor;
    offsetamt = offsetamt;
    hexGridData = gridData(layers);

    List<HexagonTile> hexTiles = [];
    for (var i = 0; i < shapes.length; i++) {
      hexTiles.add(
          HexagonTile(shapes[i], offsetamt, mainColor, altColor, shadowColor));
    }
    hexGridData.toHexTile(mapper, hexTiles);
  }
  void onClick(int x, int y) {
    hexGridData.onClick(x, y);
  }

  void setAdjRules(List<int> adjRule) {
    adjRules = adjRule;
  }

  void setRingRules(List<int> ringRule) {
    ringRules = ringRule;
  }

  void unflash() {
    for (var x = 0; x < hexGridData.hexMatrix.length; x++) {
      for (var y = 0; y < hexGridData.hexMatrix.length; y++) {
        if (hexGridData.hexMatrix[x][y] != null) {
          hexGridData.hexMatrix[x][y].flash = false;
        }
      }
    }
  }

  bool validSolution() {
    //get rule

    return (hexGridData.adjVals(adjRules) &&
        hexGridData.sameInRings(ringRules[0], ringRules[1]) &&
        scorepar());
  }

  bool scorepar() {
    if (par <= score()) {
      return true;
    } else {
      for (var x = 0; x < hexGridData.hexMatrix.length; x++) {
        for (var y = 0; y < hexGridData.hexMatrix.length; y++) {
          if (hexGridData.hexMatrix[x][y] != null) {
            hexGridData.hexMatrix[x][y].flashHex();
          }
        }
      }
      return false;
    }
  }

  int score() {
    int tilesScore = 0;
    for (var x = 0; x < hexGridData.hexMatrix.length; x++) {
      for (var y = 0; y < hexGridData.hexMatrix.length; y++) {
        if (hexGridData.hexMatrix[x][y] != null) {
          if (hexGridData.hexMatrix[x][y].val != 0) {
            tilesScore++;
          }
        }
      }
    }
    return tilesScore;
  }

  @override
  void render(Canvas canvas) {
    for (var x = 0; x < hexGridData.hexMatrix.length; x++) {
      for (var y = 0; y < hexGridData.hexMatrix.length; y++) {
        if (hexGridData.hexMatrix[x][y] != null) {
          hexGridData.hexMatrix[x][y].render(canvas);
        }
      }
    }
  }
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
  void toHexTile(Map mapper, List<HexagonTile> HexTiles) {
    for (var x = 0; x < hexMatrix.length; x++) {
      for (var y = 0; y < hexMatrix.length; y++) {
        if (hexMatrix[x][y] != null) {
          hexMatrix[x][y] = HexTiles[mapper[x.toString() + "|" + y.toString()]];
        }
      }
    }
  }

  void onClick(int x, int y) {
    if (0 <= x && x < hexMatrix.length && 0 <= y && y < hexMatrix.length) {
      if (hexMatrix[x][y] != null) {
        hexMatrix[x][y].onClick();
      }
    }
  }

  bool sameInRings(int ring1, int ring2) {
    if (amountInRing(ring1) == amountInRing(ring2)) {
      return true;
    } else {
      flashRing(ring1);
      flashRing(ring2);
      return false;
    }
  }

  bool adjVals(List<int> allowedAdj) {
    for (var x = 0; x < hexMatrix.length; x++) {
      for (var y = 0; y < hexMatrix.length; y++) {
        if (hexMatrix[x][y] != null) {
          if (hexMatrix[x][y].val > 0) {
            if (!allowedAdj.contains(amountAdj(x, y))) {
              flashAdj(x, y);
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  int amountAdj(int x, int y) {
    var adjVect = [
      [0, -1],
      [1, -1],
      [1, 0],
      [-1, 0],
      [0, 1],
      [-1, 1]
    ];
    int tx;
    int ty;
    int count = 0;
    for (var i = 0; i < adjVect.length; i++) {
      tx = adjVect[i][0];
      ty = adjVect[i][1];
      if (x + tx > -1 &&
          y + ty > -1 &&
          x + tx < hexMatrix.length &&
          y + ty < hexMatrix.length) {
        if (hexMatrix[x + tx][ty + y] != null) {
          if (hexMatrix[x + tx][ty + y].val > 0) {
            count++;
          }
        }
      }
    }
    return count;
  }

  void flashAdj(int x, int y) {
    var adjVect = [
      [0, -1],
      [1, -1],
      [1, 0],
      [-1, 0],
      [0, 1],
      [-1, 1]
    ];
    int tx;
    int ty;
    hexMatrix[x][y].flashHex();
    for (var i = 0; i < adjVect.length; i++) {
      tx = adjVect[i][0];
      ty = adjVect[i][1];
      if (x + tx > -1 &&
          y + ty > -1 &&
          x + tx < hexMatrix.length &&
          y + ty < hexMatrix.length) {
        if (hexMatrix[x + tx][ty + y] != null) {
          hexMatrix[x + tx][ty + y].flashHex();
        }
      }
    }
  }

  int amountInRing(int ring) {
    int X = gridLayers;
    int Y = 0;
    int count = 0;
    int j = ring;
    count = 0;
    X = gridLayers - 1;
    Y = j - 1;
    for (var i = 0; i < gridLayers - j; i++) {
      X++;
      debugPrint(X.toString() + "|" + Y.toString());
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      X--;
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      X--;
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      X++;
      if (hexMatrix[X][Y].val != 0) {
        count++;
      }
    }
    return count;
  }

  void flashRing(int ring) {
    int X = gridLayers;
    int Y = 0;
    int j = ring;
    X = gridLayers - 1;
    Y = j - 1;
    hexMatrix[X][Y].flashHex();
    for (var i = 0; i < gridLayers - j; i++) {
      X++;
      hexMatrix[X][Y].flashHex();
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      hexMatrix[X][Y].flashHex();
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y++;
      X--;
      hexMatrix[X][Y].flashHex();
    }
    for (var i = 0; i < gridLayers - j; i++) {
      X--;
      hexMatrix[X][Y].flashHex();
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      hexMatrix[X][Y].flashHex();
    }
    for (var i = 0; i < gridLayers - j; i++) {
      Y--;
      X++;
      hexMatrix[X][Y].flashHex();
    }
  }
}

class HexagonTile extends Component {
  late Shape hexShape;
  late Color mainColor;
  late Color altColor;
  late Color shadowColor;
  late double offsetamt;
  int maxVal = 2;
  int val = 0;

  bool flash = false;
  static DateTime now = DateTime.now();
  static int flashDur = 8000;
  static int aniDur = 500;
  static DateTime end = DateTime.now().add(Duration(milliseconds: flashDur));
  static int alphaAmt = 0;

  HexagonTile(
      Shape hex, double offamt, Color mColor, Color aColor, Color sColor) {
    hexShape = hex;
    mainColor = mColor;
    altColor = aColor;
    shadowColor = sColor;
    offsetamt = offamt / 2;
  }
  void setMainColor(Color mColor) {
    mainColor = mColor;
  }

  void onClick() {
    val = (val + 1) % maxVal;
    if (val == 0) {
      //audioController.playSfx(SfxType.buttonTap);
    }
  }

  void flashHex() {
    flash = true;
    now = DateTime.now();
    end = DateTime.now().add(Duration(milliseconds: flashDur));
  }

  void updateFlash() {
    if (DateTime.now().isAfter(end)) {
      flash = false;
    } else {
      var dif = end.difference(DateTime.now()).inMilliseconds;
      double percent = 1;
      if (dif > flashDur - aniDur) {
        //charge up
        percent = (dif - (flashDur - aniDur)) / aniDur;
      }
      if (dif < aniDur) {
        percent = dif / aniDur;
      }

      alphaAmt = (percent * 255).round();
      if (alphaAmt > 255) {
        alphaAmt = 255;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    //orange outline
    Paint p1 = Paint();
    p1.style = PaintingStyle.fill;
    p1.color = shadowColor; //Color.fromARGB(255, 207, 117, 0);
    Shape tempShapes = hexShape;
    Transform2D tempTrans = Transform2D();
    tempTrans.x = offsetamt * 1.5;
    tempTrans.y = offsetamt;
    tempShapes = tempShapes.project(tempTrans);
    canvas.drawPath(tempShapes.asPath(), p1);

    // main
    Paint p2 = Paint();
    p2.style = PaintingStyle.fill;
    p2.color = (val == 0) ? mainColor : altColor;
    canvas.drawPath(hexShape.asPath(), p2);

    //outline
    Paint p3 = Paint();
    p3.style = PaintingStyle.stroke;
    p3.strokeWidth = 2.00;
    p3.color = Color.fromARGB(255, 250, 250, 250);
    canvas.drawPath(hexShape.asPath(), p3);

    //flash
    if (flash) {
      Paint p4 = Paint();
      p4.style = PaintingStyle.stroke;
      p4.strokeWidth = 4.00;
      p4.color = Color.fromARGB(alphaAmt, 255, 0, 25);
      Shape tempShapes = hexShape;
      Transform2D tempTrans = Transform2D();
      tempTrans.scale = Vector2(1.15, 1.15);
      tempTrans.x = -hexShape.center.x * 0.15;
      tempTrans.y = -hexShape.center.y * 0.15;
      tempShapes = tempShapes.project(tempTrans);
      canvas.drawPath(tempShapes.asPath(), p4);

      updateFlash();
    }
  }
}
