import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_template/src/level_selection/levels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'newplayscreen.dart';

adHelp myadHelper = adHelp();

class GameDisplayScreen extends StatefulWidget {
  final GameLevel level;

  const GameDisplayScreen(this.level, {super.key});

  @override
  State<GameDisplayScreen> createState() => _GameDisplayScreenState();
}

class _GameDisplayScreenState extends State<GameDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final iso = IsometricTileMapExample();
    iso.level = widget.level.number;
    iso.adjRule = widget.level.adjRule;
    iso.ringRule = widget.level.ringRule;
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
                  'Score': _scoreBuilder
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
  adHelp() {}
  void loadAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
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

  void setCallBack() {
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        adLoaded = false;
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        adLoaded = false;
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
  }

  void showAd() {
    if (adLoaded) {
      rewardedAd?.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        //rewardItem.amount;
      });
    }
    loadAd();
  }
}

Widget _actionMenuBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
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
            onPressed: () => pre(game)),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.tips_and_updates_outlined,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => (myadHelper.showAd())),
        Spacer(),
        TextButton(
            style: TextButton.styleFrom(shape: CircleBorder()),
            child: Icon(
              Icons.check,
              size: btnSize,
              color: btnColor,
            ),
            onPressed: () => checkGame(game))
      ])),
    ),
  );
}

void pre(IsometricTileMapExample test) {
  //debugPrint(test.centerX.toString());
}

void pauseHandler(IsometricTileMapExample game) {
  if (game.overlays.isActive('PauseMenu')) {
    game.overlays.remove('PauseMenu');
    game.resumeEngine();
  } else {
    game.overlays.add('PauseMenu');
    game.pauseEngine();
  }
}

Widget _scoreBuilder(BuildContext buildContext, IsometricTileMapExample game) {
  return (Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
        child: Material(
            type: MaterialType.transparency,
            child: Text(
                style: TextStyle(
                  fontFamily: "Silkscreen",
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 25,
                ),
                "Score: " + game.score.toString())),
      )));
}

Widget _pauseMenuBtnBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
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

Widget _pauseMenuBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
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
                    onPressed: () => pauseHandler(game),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: btnColor,
                        minimumSize: Size(game.orgSizeX * 3 / 5, btnSize)),
                    child: Text(
                      "Back",
                      style: TextStyle(fontSize: textFontSize),
                    )),
              ],
            ))),
  );
}

Widget _rulesMenuBuilder(
    BuildContext buildContext, IsometricTileMapExample game) {
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
        child: Padding(padding: EdgeInsets.all(18.0), child: ListView(
            //cont her TODO
            children: [Text("test")]))),
  );
}

void toggleRules(IsometricTileMapExample game) {
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

void checkGame(IsometricTileMapExample game) {
  if (game.HexGrid.validSolution()) {
    //go to win screen

  }
}
