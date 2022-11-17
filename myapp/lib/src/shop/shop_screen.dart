// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:HexaComb/src/shop/shop_items.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class ShopSelectionScreen extends StatefulWidget {
  const ShopSelectionScreen({super.key});

  @override
  State<ShopSelectionScreen> createState() => _ShopSelectionScreenState();
}

class _ShopSelectionScreenState extends State<ShopSelectionScreen> {
  int selected = 0;
  bool first = true;

  void setSelected(int newSel, PlayerProgress plyProg) {
    setState(() {
      selected = newSel;
      print(newSel.toString());
    });
    if (shopItems[selected].owned && !first) {
      print("SET TO SEL" + selected.toString());
      plyProg.setCurrentItem(selected);
    }
  }

  void buySelected(PlayerProgress plyProg) {
    if (plyProg.coins >= shopItems[selected].cost &&
        shopItems[selected].owned == false) {
      shopItems[selected].owned = true;
      plyProg.changeCoins(-shopItems[selected].cost);
      var temp = "";
      for (var i = 0; i < shopItems.length; i++) {
        if (shopItems[i].owned) {
          temp = temp + "1";
        } else {
          temp = temp + "0";
        }
      }
      plyProg.setShopItems(temp);
      if (shopItems[selected].owned && !first) {
        print("SET TO SEL" + selected.toString());
        plyProg.setCurrentItem(selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    var shopUdater = playerProgress.allShopItems;
    print("built");
    for (var i = 0; i < shopUdater.length; i++) {
      if (shopUdater[i] == "1") {
        shopItems[i].owned = true;
      }
    }
    if (first) {
      print("TEST2");
      setSelected(playerProgress.currentItem, playerProgress);
      first = false;
    }
    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
          squarishMainArea: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(children: [
                  TextButton(
                      onPressed: () => (GoRouter.of(context).pop()),
                      child: Icon(
                        Icons.arrow_back, // track changes
                        size: 30,
                        color: Colors.green,
                      )),
                  Spacer(),
                  Text(
                    'Shop',
                    style:
                        TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            style: TextStyle(
                              fontFamily: "Silkscreen",
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 25,
                            ),
                            playerProgress.coins.toString()),
                      ),
                      Icon(
                        Icons.hexagon_outlined,
                        size: 30,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView(children: [
                  for (var item in shopItems)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: GestureDetector(
                        onTap: () {
                          setSelected(item.number, playerProgress);
                        },
                        child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                border: Border.all(
                                  color: selected == item.number
                                      ? Colors.white
                                      : Colors.black,
                                  width: 2.2,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: LinearGradient(colors: [
                                  item.mainColor,
                                  item.altColor,
                                  item.shadowColor
                                ])),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                                Spacer(),
                                !item.owned
                                    ? Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(item.cost.toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 16, 16, 16),
                                            child: Icon(Icons.hexagon_outlined),
                                          ),
                                        ],
                                      )
                                    : Spacer(),
                              ],
                            )),
                      )),
                    )
                ]),
              )
            ],
          ),
          rectangularMenuArea: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  buySelected(playerProgress);
                },
                child: Text('buy'),
              ),
            ],
          )),
    );
  }
}
