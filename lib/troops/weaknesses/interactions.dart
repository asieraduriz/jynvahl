import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/characters/infantry.dart';
import 'package:jynvahl_hex_game/troops/characters/archer.dart';
import 'package:jynvahl_hex_game/troops/characters/cavalry.dart';
import 'package:jynvahl_hex_game/troops/characters/mage.dart';

class WeaknessInteraction {
  final double multiplier;
  final String message;
  const WeaknessInteraction(this.multiplier, this.message);
}

const multiplier = 1.25; // 25% increased damage

final Map<Type, Map<Type, WeaknessInteraction>> _typeInteractions = {
  ArcherTroop: {
    InfantryTroop: const WeaknessInteraction(
      multiplier,
      'Archer bonus damage vs. Infantry!',
    ),
    MageTroop: const WeaknessInteraction(
      multiplier,
      'Archer bonus damage vs Mage!',
    ),
  },

  InfantryTroop: {
    CavalryTroop: const WeaknessInteraction(
      multiplier,
      'Infantry bonus damage vs. Cavalry!',
    ),
  },

  CavalryTroop: {
    ArcherTroop: const WeaknessInteraction(
      multiplier,
      'Cavalry bonus damage vs. Archer!',
    ),
  },
};

WeaknessInteraction? getWeaknessInteraction(
  BaseTroop attacker,
  BaseTroop target,
) {
  return _typeInteractions[attacker.runtimeType]?[target.runtimeType];
}
