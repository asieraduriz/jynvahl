import 'package:jynvahl_hex_game/troops/characters/archer.dart';
import 'package:jynvahl_hex_game/troops/characters/infantry.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:test/test.dart';

void main() {
  group('Infantry Troop Tests', () {
    test('Takes less physical damage', () {
      final armorRating = 20.0;
      final health = 50.0;
      final infantry = InfantryTroop(armorRating: armorRating, health: health);

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
      final infantry = InfantryTroop(armorRating: armorRating, health: health);

      infantry.takeDamage(10.0, DamageType.magical);

      expect(
        infantry.health,
        40.0, // No reduction for magic damage
        reason: 'Infantry should take full damage from magic',
      );
    });

    test('Takes higher damage from archer', () {
      final infantryTroop = InfantryTroop(armorRating: 10.0, health: 100.0);
      final archerTroop = ArcherTroop(
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
}
