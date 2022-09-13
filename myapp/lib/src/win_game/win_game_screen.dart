// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:HexaComb/src/newplay/display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatefulWidget {
  final Score score;
  final int coins;
  final adHelp myAdHelper;

  const WinGameScreen({
    super.key,
    required this.score,
    required this.coins,
    required this.myAdHelper,
  });

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  int _coins = 0;
  bool firstTime = false;
  void doubleCoins() {
    setState(() {
      _coins = _coins * 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!firstTime) {
      _coins = widget.coins;
      firstTime = true;
    }
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
            gap,
            const Center(
              child: Text(
                'Level Complete!',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 35),
              ),
            ),
            gap,
            Center(
              child: Text(
                'Coins Earned:' +
                    _coins.toString() +
                    "\n"
                        'Time: ${widget.score.formattedTime}',
                style: const TextStyle(
                    fontFamily: 'Permanent Marker', fontSize: 20),
              ),
            ),
          ],
        ),
        rectangularMenuArea: Column(
          children: [
            SizedBox(
                width: double.infinity,
                child: (myadHelper.CoinsShown == false)
                    ? ElevatedButton(
                        onPressed: () {
                          myadHelper.showAdCoins(
                              context, widget.coins, doubleCoins);
                        },
                        child: const Text('Double Coins!'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          //myadHelper.showAdCoins(context, widget.coins);
                        },
                        child: const Text('Rewards Given!'),
                      )),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).pop();
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
