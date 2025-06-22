import 'package:jynvahl_hex_game/troops/characters/archer.dart';
import 'package:jynvahl_hex_game/troops/characters/cavalry.dart';
import 'package:jynvahl_hex_game/troops/characters/infantry.dart';
import 'package:jynvahl_hex_game/troops/characters/mage.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:test/test.dart';

void main() {
  group('Infantry Troop Tests', () {
    test('Takes less physical damage', () {
      final armorRating = 20.0;
      final health = 50.0;
      final infantry = InfantryTroop(
        level: 1,
        experience: 0,
        armorRating: armorRating,
        health: health,
      );

      expect(infantry.armorRating, armorRating);
      infantry.takeDamage(10.0, DamageType.physical);

      expect(
        infantry.health,
        42.0, // 10 damage reduced by 20%
        reason: 'Infantry should take reduced damage due to armor',
      );
    });

    test('Takes full damage from magic', () {
      final armorRating = 20.0;
      final health = 50.0;
      final infantry = InfantryTroop(
        level: 1,
        experience: 0,
        armorRating: armorRating,
        health: health,
      );

      infantry.takeDamage(10.0, DamageType.magical);

      expect(
        infantry.health,
        40.0, // No reduction for magic damage
        reason: 'Infantry should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final infantryTroop = InfantryTroop(
        level: 1,
        experience: 0,
        armorRating: 10.0,
        health: 100.0,
      );
      final archerTroop = ArcherTroop(
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );

      archerTroop.attack(infantryTroop);

      expect(
        infantryTroop.health,
        100 - (30.0 * 1.25) * 0.9,
      ); // 25% amplify, 10% armor reduction
      expect(archerTroop.health, 80.0);
    });
  });
  group('Archer Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final archer = ArcherTroop(level: 1, experience: 0, health: health);

      archer.takeDamage(10.0, DamageType.physical);

      expect(archer.health, 40.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final archer = ArcherTroop(level: 1, experience: 0, health: health);

      archer.takeDamage(10.0, DamageType.magical);

      expect(
        archer.health,
        40.0,
        reason: 'Archer should take full damage from magic',
      );
    });

    test('Takes higher damage from cavalry', () {
      final cavalryTroop = CavalryTroop(
        level: 1,
        experience: 0,
        health: 100.0,
        baseDamage: {DamageType.physical: 30.0},
      );
      const startingHealth = 80.0;
      final archerTroop = ArcherTroop(
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: startingHealth,
      );

      cavalryTroop.attack(archerTroop);

      expect(archerTroop.health, startingHealth - (30.0 * 1.25));
    });
  });

  group('Cavalry Troop Tests', () {
    test('Takes full damage from physical', () {
      final health = 50.0;
      final cavalry = CavalryTroop(level: 1, experience: 0, health: health);

      cavalry.takeDamage(10.0, DamageType.physical);

      expect(cavalry.health, 40.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final infantry = CavalryTroop(level: 1, experience: 0, health: health);

      infantry.takeDamage(10.0, DamageType.magical);

      expect(infantry.health, 40.0);
    });

    test('Takes higher damage from infantry', () {
      final infantryTroop = InfantryTroop(
        level: 1,
        experience: 0,
        armorRating: 10.0,
        health: 100.0,
        baseDamage: {DamageType.physical: 30.0},
      );

      const startingHealth = 80.0;
      final cavalryTroop = CavalryTroop(
        level: 1,
        experience: 0,
        health: startingHealth,
      );

      infantryTroop.attack(cavalryTroop);

      expect(cavalryTroop.health, startingHealth - (30.0 * 1.25));
    });
  });

  group('Mage Troop Tests', () {
    test('Takes full damage from  physical', () {
      final health = 50.0;
      final mageTroop = MageTroop(level: 1, experience: 0, health: health);

      mageTroop.takeDamage(10.0, DamageType.physical);

      expect(mageTroop.health, 40.0);
    });

    test('Takes full damage from magic', () {
      final health = 50.0;
      final infantry = MageTroop(level: 1, experience: 0, health: health);

      infantry.takeDamage(10.0, DamageType.magical);

      expect(infantry.health, 40.0);
    });

    test('Takes higher damage from archer', () {
      final mageTroop = MageTroop(level: 1, experience: 0, health: 100.0);
      final archerTroop = ArcherTroop(
        level: 1,
        experience: 0,
        baseDamage: {DamageType.physical: 30.0},
        health: 80.0,
      );

      archerTroop.attack(mageTroop);

      expect(mageTroop.health, 100 - (30.0 * 1.25));
      expect(archerTroop.health, 80.0);
    });
  });
}
