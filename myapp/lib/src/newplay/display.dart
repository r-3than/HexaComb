import 'package:HexaComb/src/ads/banner_ad_widget.dart';
import 'package:HexaComb/src/shop/shop_items.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '/src/games_services/score.dart';
import '/src/level_selection/levels.dart';
import '/src/player_progress/player_progress.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'newplayscreen.dart';

adHelp myadHelper = adHelp();
BannerAdWidget Banner = BannerAdWidget();

class GameDisplayScreen extends StatefulWidget {
  final GameLevel level;

  const GameDisplayScreen(this.level, {super.key});

  @override
  State<GameDisplayScreen> createState() => _GameDisplayScreenState();
}

class _GameDisplayScreenState extends State<GameDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final iso = HexGameFlame(widget.level.layers);
    final PlayerProgress playerProgress = context.watch<PlayerProgress>();

    var currentShopItem = shopItems[playerProgress.currentItem];
    iso.setTheme(currentShopItem.mainColor, currentShopItem.altColor,
        currentShopItem.shadowColor);

    iso.level = widget.level.number;
    iso.adjRule = widget.level.adjRule;
    iso.ringRule = widget.level.ringRule;
    iso.par = widget.level.par;
    myadHelper.loadAd();
    return (Column(
      children: [
        (Expanded(
          child: Container(
              child: SizedBox(
                child: GameWidget(game: iso, overlayBuilderMap: const {
                  'ActionMenu': _actionMenuBuilder,
                  'PauseMenuBtn': _pauseMenuBtnBuilder,
                  'PauseMenu': _pauseMenuBuilder,
                  'RulesMenu': _rulesMenuBuilder,
                  'Score': _scoreBuilder,
                  "Clock": _clockMenu
                }),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              decoration: BoxDecoration(color: Colors.green)),
        ))
      ],
    ));
  }
}

//Make Widgets for Menu here

double btnSize = 65;
double textFontSize = 25;
Color btnColor = Color.fromARGB(255, 229, 243, 210);
Color transColor = Color.fromARGB(0, 0, 0, 0);

class adHelp {
  RewardedAd? rewardedAd;
  bool adLoaded = false;
  bool CoinsShown = false;
  adHelp() {}
  void loadAd() {
    if (!adLoaded) {
      RewardedAd.load(
          adUnitId: 'ca-app-pub-5674541835266474/9058867560',
          request: AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              print('$ad loaded.');
              // Keep a reference to the ad so you can show it later.
              rewardedAd = ad;
              setCallBack();
              print('RewardedAd LOADED!');
              adLoaded = true;
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('RewardedAd failed to load: $error');
            },
          ));
    }
  }

  void setCallBack() {
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        adLoaded = false;
        ad.dispose();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        adLoaded = false;
        ad.dispose();
        loadAd();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
  }

  void showAd(BuildContext c, HexGameFlame game) {
    if (adLoaded) {
      rewardedAd?.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        //rewardItem.amount;
        //game.levelStart = DateTime.now();
        checkGame(c, game, true);
      });
    }
    loadAd();
  }

  void showAdCoins(BuildContext c, int coins, Function update) {
    if (adLoaded) {
      rewardedAd?.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        final playerProgress = c.read<PlayerProgress>();
        playerProgress.changeCoins(coins);
        CoinsShown = true;
        update();
      });
    }
    loadAd();
  }
}

Widget _actionMenuBuilder(BuildContext buildContext, HexGameFlame game) {
  return Align(
    alignment: FractionalOffset.bottomLeft,
    child: Container(
      height: 100,
      child: Center(
          child: Row(children: [
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.track_changes, // track changes
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => toggleRules(game)),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.skip_next, //remove timer!!
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => (myadHelper.showAd(buildContext, game))),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.check,
              size: btnSize,
              color: (game.par <= game.score)
                  ? Color.fromARGB(255, 14, 202, 14)
                  : btnColor,
            ),
            onPressed: () => checkGame(buildContext, game, false))
      ])),
    ),
  );
}

void pre(HexGameFlame test) {
  //debugPrint(test.centerX.toString());
}

void pauseHandler(HexGameFlame game) {
  if (game.overlays.isActive('PauseMenu')) {
    game.overlays.remove('PauseMenu');
    game.resumeEngine();
  } else {
    game.overlays.add('PauseMenu');
    game.pauseEngine();
  }
}

Widget _scoreBuilder(BuildContext buildContext, HexGameFlame game) {
  return (Container(
      child: Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Material(
                type: MaterialType.transparency,
                child: Text(
                    style: TextStyle(
                      fontFamily: "Silkscreen",
                      color: (game.par <= game.score)
                          ? Color.fromARGB(255, 14, 202, 14)
                          : Color.fromARGB(255, 255, 255, 255),
                      fontSize: 25,
                    ),
                    "Score: " + game.score.toString())),
            Material(
                type: MaterialType.transparency,
                child: Text(
                    style: TextStyle(
                      fontFamily: "Silkscreen",
                      color: (game.par <= game.score)
                          ? Color.fromARGB(255, 14, 202, 14)
                          : Color.fromARGB(255, 255, 255, 255),
                      fontSize: 25,
                    ),
                    "Par: " + game.par.toString())),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
            Material(
                type: MaterialType.transparency,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                          style: TextStyle(
                            fontFamily: "Silkscreen",
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 25,
                          ),
                          buildContext.read<PlayerProgress>().coins.toString()),
                    ),
                    Icon(
                      Icons.hexagon_outlined,
                      size: 25,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ],
                ))
          ]))));
}

Widget _pauseMenuBtnBuilder(BuildContext buildContext, HexGameFlame game) {
  return (Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        child: TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.menu,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => pauseHandler(game)),
      )));
}

Widget _pauseMenuBuilder(BuildContext buildContext, HexGameFlame game) {
  return Center(
    child: Container(
        width: MediaQuery.of(buildContext).size.width * 3 / 4,
        height: (btnSize + 16) * 5,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.all(18.0),
            child: ListView(
              //cont her TODO
              children: [
                OutlinedButton(
                    onPressed: () => pauseHandler(game),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Back",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => backonce(buildContext),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Level Select",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => backtwice(buildContext),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Main Menu",
                      style: TextStyle(fontSize: textFontSize),
                    )),
                Padding(padding: const EdgeInsets.all(16.0)),
                OutlinedButton(
                    onPressed: () => GoRouter.of(buildContext).go("/shop"),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Shop 🛒",
                      style: TextStyle(fontSize: textFontSize),
                    )),
              ],
            ))),
  );
}

Widget _rulesMenuBuilder(BuildContext buildContext, HexGameFlame game) {
  return Center(
    child: Container(
        width: MediaQuery.of(buildContext).size.width * 3 / 4,
        height: (btnSize + 16) * 5,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.all(18.0),
            child: Material(
                type: MaterialType.transparency,
                child: ListView(
                    //cont her TODO
                    children: [
                      Center(
                          child: Text(
                              style: TextStyle(
                                fontFamily: "Silkscreen",
                                color: Color.fromARGB(255, 251, 255, 211),
                                fontSize: 45,
                              ),
                              "Rules")),
                      (game.adjRule != [1, 2, 3, 4, 5, 6])
                          ? Text(
                              style: TextStyle(
                                fontFamily: "Silkscreen",
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 20,
                              ),
                              "- Every hexagon that has been turned on must border " +
                                  game.getAdjRulesData())
                          : Text(""),
                      Text("\n"),
                      (game.ringRule[0] != game.ringRule[1])
                          ? Text(
                              style: TextStyle(
                                fontFamily: "Silkscreen",
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 20,
                              ),
                              "- There must be the same amount of turned on hexagons in ring " +
                                  game.ringRule[0].toString() +
                                  " and ring " +
                                  game.ringRule[1].toString() +
                                  ". (Ring 1 is the outermost ring)")
                          : Text(""),
                      Text("\n"),
                      Text(
                          style: TextStyle(
                            fontFamily: "Silkscreen",
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 20,
                          ),
                          "- Score must reach par to pass the level!"),
                      Text("\n"),
                      OutlinedButton(
                          onPressed: () => toggleRules(game),
                          style: OutlinedButton.styleFrom(
                              backgroundColor: btnColor,
                              minimumSize:
                                  Size(game.orgSizeX * 3 / 5, btnSize)),
                          child: Text(
                            "Back",
                            style: TextStyle(fontSize: textFontSize),
                          )),
                    ])))),
  );
}

Widget _clockMenu(BuildContext buildContext, HexGameFlame game) {
  return Align(
      alignment: FractionalOffset.bottomLeft,
      child: Container(
          height: 225,
          child: Center(
              child: Material(
            type: MaterialType.transparency,
            child: Text(
                style: TextStyle(
                  fontFamily: "Silkscreen",
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 25,
                ),
                game.timerString),
          ))));
}

void toggleRules(HexGameFlame game) {
  if (game.overlays.isActive('RulesMenu')) {
    game.overlays.remove('RulesMenu');
    game.resumeEngine();
  } else {
    game.overlays.add('RulesMenu');
    game.pauseEngine();
  }
}

void backonce(BuildContext c) {
  GoRouter.of(c).pop();
}

void backtwice(BuildContext c) {
  GoRouter.of(c).pop();
  GoRouter.of(c).pop();
}

void checkGame(BuildContext c, HexGameFlame game, bool forceWin) {
  game.HexGrid.unflash();
  if (game.HexGrid.validSolution() || forceWin) {
    //go to win screen
    myadHelper.loadAd();
    Score temp = Score(
        game.level, game.score, DateTime.now().difference(game.levelStart));

    final playerProgress = c.read<PlayerProgress>();

    int dcoins = temp.coinsEarned(playerProgress.highestLevelReached);

    playerProgress.setLevelReached(game.level);
    playerProgress.changeCoins(dcoins);

    GoRouter.of(c).go('/play/won', extra: {
      'score': temp,
      'coins': dcoins,
      "adHelp": myadHelper,
      "banner": Banner
    });
  }
}
