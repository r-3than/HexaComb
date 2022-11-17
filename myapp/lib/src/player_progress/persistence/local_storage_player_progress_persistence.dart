// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<void> changeCoins(int deltaCoins) async {
    final prefs = await instanceFuture;
    var tempcoins = prefs.getInt('coinsAmt') ?? 0;
    await prefs.setInt('coinsAmt', tempcoins + deltaCoins);
  }

  @override
  Future<void> setCurrentItem(int num) async {
    final prefs = await instanceFuture;
    //var currentItem = prefs.getInt('currentItem') ?? 0;
    await prefs.setInt('currentItem', num);
  }

  @override
  Future<void> setCoins(int Coins) async {
    final prefs = await instanceFuture;
    await prefs.setInt('coinsAmt', Coins);
  }

  @override
  Future<int> getCoins() async {
    final prefs = await instanceFuture;
    return prefs.getInt('coinsAmt') ?? 0;
  }

  @override
  Future<void> setShopItems(String items) async {
    final prefs = await instanceFuture;
    await prefs.setString('ShopItems', items);
  }

  @override
  Future<String> getShopItems() async {
    final prefs = await instanceFuture;
    return prefs.getString('ShopItems') ?? "0";
  }

  @override
  Future<int> getCurrentItem() async {
    final prefs = await instanceFuture;
    return prefs.getInt('currentItem') ?? 0;
  }

  @override
  Future<int> getHighestLevelReached() async {
    final prefs = await instanceFuture;
    return prefs.getInt('highestLevelReached') ?? 0;
  }

  @override
  Future<void> saveHighestLevelReached(int level) async {
    final prefs = await instanceFuture;
    await prefs.setInt('highestLevelReached', level);
  }
}
