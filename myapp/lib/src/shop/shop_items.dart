import 'package:flame/palette.dart';

List<shopItem> shopItems = [
  shopItem(
    0,
    0,
    "Orangery",
    Color.fromARGB(255, 124, 104, 104),
    Color.fromARGB(255, 229, 172, 63),
    Color.fromARGB(255, 207, 117, 0),
  ),
  shopItem(
    1,
    35,
    "Bluey",
    Color.fromARGB(255, 160, 199, 251),
    Color.fromARGB(255, 51, 0, 255),
    Color.fromARGB(255, 14, 0, 75),
  ),
  shopItem(
    2,
    100,
    "Pinky",
    Color.fromARGB(255, 241, 170, 214),
    Color.fromARGB(255, 254, 0, 0),
    Color.fromARGB(255, 170, 10, 74),
  ),
  shopItem(
    3,
    75,
    "Greeny",
    Color.fromARGB(255, 112, 124, 104),
    Color.fromARGB(255, 10, 179, 32),
    Color.fromARGB(255, 6, 65, 4),
  ),
  shopItem(
    4,
    250,
    "Invertedy",
    Color.fromARGB(255, 255, 255, 254),
    Color.fromARGB(255, 82, 48, 25),
    Color.fromARGB(255, 38, 222, 31),
  ),
];

class shopItem {
  late int number;

  late int cost;
  late String name;
  bool owned = false;
  late Color mainColor;
  late Color altColor;
  late Color shadowColor;

  shopItem(int num, int cost, String name, Color mc, Color ac, Color sc) {
    this.number = num;
    this.cost = cost;
    this.name = name;
    this.mainColor = mc;
    this.altColor = ac;
    this.shadowColor = sc;
    this.owned = (cost == 0);
  }
}
