// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An interface of persistence stores for the player's progress.
///
/// Implementations can range from simple in-memory storage through
/// local preferences to cloud saves.
abstract class PlayerProgressPersistence {
  Future<int> getHighestLevelReached();
  Future<int> getCoins();
  Future<int> getCurrentItem();
  Future<String> getShopItems();

  Future<void> saveHighestLevelReached(int level);
  Future<void> changeCoins(int deltaCoins);
  Future<void> setCoins(int coins);
  Future<void> setShopItems(String items);
  Future<void> setCurrentItem(int num);
}
