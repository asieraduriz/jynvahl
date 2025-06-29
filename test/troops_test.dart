import 'package:jynvahl_hex_game/troops/characters/archer.dart';
import 'package:jynvahl_hex_game/troops/characters/cavalry.dart';
import 'package:jynvahl_hex_game/troops/characters/infantry.dart';
import 'package:jynvahl_hex_game/troops/characters/mage.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:test/test.dart';

void main() {
  group('Infantry Troop Tests', () {
    test('Takes less physical damage', () {
      final armorRating = 20.0;
      final infantry = InfantryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: armorRating,
      );

      final healthBeforeDamage = infantry.health;

      expect(infantry.armorRating, armorRating);
      infantry.takeDamage(10.0, DamageType.physical);

      final damageTaken = 10.0 * (1.0 - (armorRating / 100.0));

      expect(
        infantry.health,
        healthBeforeDamage - damageTaken,
        reason: 'Infantry should take reduced damage due to armor',
      );
    });

    test('Takes full damage from magic', () {
      final armorRating = 20.0;
      final health = 50.0;
      final infantry = InfantryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: armorRating,
        health: health,
      );

      final healthBeforeDamage = infantry.health;

      infantry.takeDamage(10.0, DamageType.magical);

      expect(
        infantry.health,
        healthBeforeDamage - 10.0, // No reduction for magic damage
        reason: 'Infantry should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final infantryTroop = InfantryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: 10.0,
        health: 100.0,
      );
      final archerTroop = ArcherTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );
      final archerDamage =
          archerTroop.effectiveDamage[DamageType.physical] ?? 0.0;
      final healthBeforeDamage = infantryTroop.health;

      archerTroop.attack(infantryTroop);

      expect(
        infantryTroop.health,
        healthBeforeDamage - (archerDamage * 1.25) * 0.9,
      ); // 25% amplify, 10% armor reduction
    });
  });
  group('Archer Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final archer = ArcherTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = archer.health;

      archer.takeDamage(10.0, DamageType.physical);

      expect(archer.health, healthBeforeDamage - 10.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final archer = ArcherTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = archer.health;

      archer.takeDamage(10.0, DamageType.magical);

      expect(
        archer.health,
        healthBeforeDamage - 10.0,
        reason: 'Archer should take full damage from magic',
      );
    });

    test('Takes higher damage from cavalry', () {
      final cavalryTroop = CavalryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
      );

      final archerTroop = ArcherTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
      );

      final healthBeforeDamage = archerTroop.health;
      print(
        "Health before damage $healthBeforeDamage cavalry damage ${cavalryTroop.effectiveDamage[DamageType.physical]}",
      );
      cavalryTroop.attack(archerTroop);

      final cavalryDamage =
          cavalryTroop.effectiveDamage[DamageType.physical] ?? 0.0;
      expect(archerTroop.health, healthBeforeDamage - (cavalryDamage * 1.25));
    });
  });

  group('Cavalry Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final cavalry = CavalryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = cavalry.health;

      cavalry.takeDamage(10.0, DamageType.physical);

      expect(cavalry.health, healthBeforeDamage - 10.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final infantry = CavalryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = infantry.health;

      infantry.takeDamage(10.0, DamageType.magical);

      expect(infantry.health, healthBeforeDamage - 10.0);
    });

    test('Takes higher damage from infantry', () {
      final infantryTroop = InfantryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: 10.0,
        health: 100.0,
        baseDamage: {DamageType.physical: 30.0},
      );

      final cavalryTroop = CavalryTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: 80.0,
      );

      final healthBeforeDamage = cavalryTroop.health;

      infantryTroop.attack(cavalryTroop);

      expect(
        cavalryTroop.health,
        healthBeforeDamage -
            (infantryTroop.effectiveDamage[DamageType.physical]! * 1.25),
      );
    });
  });

  group('Mage Troop Tests', () {
    test('Takes full damage from  physical', () {
      final health = 50.0;
      final mageTroop = MageTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = mageTroop.health;

      mageTroop.takeDamage(10.0, DamageType.physical);

      expect(mageTroop.health, healthBeforeDamage - 10.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final infantry = MageTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = infantry.health;

      infantry.takeDamage(10.0, DamageType.magical);

      expect(
        infantry.health,
        healthBeforeDamage - 10.0,
        reason: 'Mage should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final mageTroop = MageTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: 100.0,
      );
      final archerTroop = ArcherTroop(
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );

      final healthBeforeDamage = mageTroop.health;

      archerTroop.attack(mageTroop);

      expect(
        mageTroop.health,
        healthBeforeDamage -
            (archerTroop.effectiveDamage[DamageType.physical]! * 1.25),
      );
    });
  });
}
