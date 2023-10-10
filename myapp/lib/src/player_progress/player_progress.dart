// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../shop/shop_items.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  static const maxHighestScoresPerPlayer = 10;

  final PlayerProgressPersistence _store;

  int _highestLevelReached = 0;
  int _coins = 0;

  String _allShopItems = "0" * shopItems.length;
  int _currentItem = 0;

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress(PlayerProgressPersistence store) : _store = store;

  /// The highest level that the player has reached so far.
  int get highestLevelReached => _highestLevelReached;
  int get coins => _coins;

  String get allShopItems => _allShopItems;
  int get currentItem => _currentItem;

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    final level = await _store.getHighestLevelReached();
    final coins = await _store.getCoins();
    final currentItem = await _store.getCurrentItem();
    final allShopItems = await _store.getShopItems();

    _allShopItems = allShopItems;
    _currentItem = currentItem;
    _coins = coins;

    await _store.setShopItems(allShopItems);
    await _store.setCurrentItem(_currentItem);
    await _store.setCoins(_coins);
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
    }
    notifyListeners();
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _highestLevelReached = 0;
    _coins = 0;
    _currentItem = 0;
    for (var i = 0; i < shopItems.length; i++) {
      shopItems[i].owned = false;
    }
    notifyListeners();
    _store.saveHighestLevelReached(_highestLevelReached);
    _store.setCoins(_coins);
    var temp = "";
    for (var i = 0; i < shopItems.length; i++) {
      temp = temp + "0";
    }
    _allShopItems = temp;
    _store.setShopItems(_allShopItems);
    _store.setCurrentItem(_currentItem);
  }

  void setCurrentItem(int num) {
    _currentItem = num;
    notifyListeners();
    unawaited(_store.setCurrentItem(num));
  }

  void setShopItems(String shopStr) {
    _allShopItems = shopStr;
    notifyListeners();
    unawaited(_store.setShopItems(shopStr));
  }

  void changeCoins(int deltacoins) {
    _coins = coins + deltacoins;
    notifyListeners();
    unawaited(_store.changeCoins(deltacoins));
  }

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  void setLevelReached(int level) {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();

      unawaited(_store.saveHighestLevelReached(level));
    }
  }
}
