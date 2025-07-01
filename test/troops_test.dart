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
        name: 'Infantry1',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: armorRating,
        health: 100.0, // Assuming a default health or making it explicit
      );

      final healthBeforeDamage = infantry.health;

      expect(infantry.armorRating, armorRating);
      infantry.takeDamage(10.0, DamageType.physical);

      final damageTaken = 10.0 * (1.0 - (armorRating / 100.0));

      expect(
        infantry.health,
        closeTo(
          healthBeforeDamage - damageTaken,
          0.001,
        ), // Use closeTo for double comparison
        reason: 'Infantry should take reduced damage due to armor',
      );
    });

    test('Takes full damage from magic', () {
      final armorRating = 20.0;
      final health = 50.0;
      final infantry = InfantryTroop(
        name: 'Infantry2',
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
        closeTo(
          healthBeforeDamage - 10.0,
          0.001,
        ), // Use closeTo for double comparison
        reason: 'Infantry should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final infantryTroop = InfantryTroop(
        name: 'InfantryTarget',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: 10.0,
        health: 100.0,
      );
      final archerTroop = ArcherTroop(
        name: 'ArcherAttacker',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );
      // Assuming effectiveDamage exists and is deterministic for testing
      final archerDamage =
          archerTroop.effectiveDamage[DamageType.physical] ?? 0.0;
      final healthBeforeDamage = infantryTroop.health;

      archerTroop.attack(infantryTroop);

      // The expectation is based on a deterministic 'effectiveDamage' and the armor reduction.
      // Assuming 1.25 is the weakness multiplier and 0.9 is the armor reduction (10% armor).
      final expectedHealth = healthBeforeDamage - (archerDamage * 1.25) * 0.9;
      expect(
        infantryTroop.health,
        closeTo(expectedHealth, 0.001), // Use closeTo for double comparison
      );
    });
  });

  group('Archer Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final archer = ArcherTroop(
        name: 'Archer1',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
        armorRating: 0.0, // Explicitly no armor for full physical damage
      );

      final healthBeforeDamage = archer.health;

      archer.takeDamage(10.0, DamageType.physical);

      expect(archer.health, closeTo(healthBeforeDamage - 10.0, 0.001));
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final archer = ArcherTroop(
        name: 'Archer2',
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
        closeTo(healthBeforeDamage - 10.0, 0.001),
        reason: 'Archer should take full damage from magic',
      );
    });

    test('Takes higher damage from cavalry', () {
      final cavalryTroop = CavalryTroop(
        name: 'CavalryAttacker',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 100.0, // Assuming a health for Cavalry
      );

      final archerTroop = ArcherTroop(
        name: 'ArcherTarget',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {
          DamageType.physical: 30.0,
        }, // Dummy baseDamage for Archer target
        health: 80.0,
      );

      final healthBeforeDamage = archerTroop.health;
      // print("Health before damage $healthBeforeDamage cavalry damage ${cavalryTroop.effectiveDamage[DamageType.physical]}"); // Removed print

      cavalryTroop.attack(archerTroop);

      final cavalryDamage =
          cavalryTroop.effectiveDamage[DamageType.physical] ?? 0.0;
      final expectedHealth =
          healthBeforeDamage -
          (cavalryDamage * 1.25); // Assuming 1.25 is weakness multiplier
      expect(archerTroop.health, closeTo(expectedHealth, 0.001));
    });
  });

  group('Cavalry Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final cavalry = CavalryTroop(
        name: 'Cavalry1',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
        armorRating: 0.0, // Explicitly no armor
      );

      final healthBeforeDamage = cavalry.health;

      cavalry.takeDamage(10.0, DamageType.physical);

      expect(cavalry.health, closeTo(healthBeforeDamage - 10.0, 0.001));
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final cavalry = CavalryTroop(
        // Changed 'infantry' to 'cavalry' for clarity
        name: 'Cavalry2',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = cavalry.health;

      cavalry.takeDamage(10.0, DamageType.magical);

      expect(cavalry.health, closeTo(healthBeforeDamage - 10.0, 0.001));
    });

    test('Takes higher damage from infantry', () {
      final infantryTroop = InfantryTroop(
        name: 'InfantryAttacker',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        armorRating: 10.0, // Armor for Infantry, if applicable
        health: 100.0,
        baseDamage: {DamageType.physical: 30.0},
      );

      final cavalryTroop = CavalryTroop(
        name: 'CavalryTarget',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: 80.0,
      );

      final healthBeforeDamage = cavalryTroop.health;

      infantryTroop.attack(cavalryTroop);

      // The expectation is based on a deterministic 'effectiveDamage' and the weakness multiplier.
      final expectedHealth =
          healthBeforeDamage -
          (infantryTroop.effectiveDamage[DamageType.physical]! *
              1.25); // Assuming 1.25 is weakness multiplier
      expect(cavalryTroop.health, closeTo(expectedHealth, 0.001));
    });
  });

  group('Mage Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final mageTroop = MageTroop(
        name: 'Mage1',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
        armorRating: 0.0, // Explicitly no armor
      );

      final healthBeforeDamage = mageTroop.health;

      mageTroop.takeDamage(10.0, DamageType.physical);

      expect(mageTroop.health, closeTo(healthBeforeDamage - 10.0, 0.001));
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final mageTroop = MageTroop(
        // Changed 'infantry' to 'mageTroop' for clarity
        name: 'Mage2',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: health,
      );

      final healthBeforeDamage = mageTroop.health;

      mageTroop.takeDamage(10.0, DamageType.magical);

      expect(
        mageTroop.health,
        closeTo(healthBeforeDamage - 10.0, 0.001),
        reason: 'Mage should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final mageTroop = MageTroop(
        name: 'MageTarget',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        health: 100.0,
      );
      final archerTroop = ArcherTroop(
        name: 'ArcherAttacker',
        rarity: TroopRarity.common,
        rarityEmblems: 0,
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );

      final healthBeforeDamage = mageTroop.health;

      archerTroop.attack(mageTroop);

      // The expectation is based on a deterministic 'effectiveDamage' and the weakness multiplier.
      final expectedHealth =
          healthBeforeDamage -
          (archerTroop.effectiveDamage[DamageType.physical]! *
              1.25); // Assuming 1.25 is weakness multiplier
      expect(mageTroop.health, closeTo(expectedHealth, 0.001));
    });
  });
}
