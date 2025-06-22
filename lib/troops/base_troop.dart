import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';
import 'package:jynvahl_hex_game/troops/weaknesses/interactions.dart';

abstract class BaseTroop {
  final String name;
  double health;
  final Map<DamageType, double> baseDamage;

  int level;
  int experience;

  BaseTroop({
    required this.name,
    required this.health,
    required this.baseDamage,
    required this.level,
    required this.experience,
  }) {}

  DamageProfile get baseDamageProfile => DamageProfile(baseDamage);
  DamageProfile calculateOutgoingDamage() => baseDamageProfile;

  void takeDamage(double amount, DamageType type) {
    health -= amount;
    if (health < 0) health = 0;
    print(
      '  ${name} took ${amount.toStringAsFixed(2)} total damage of type ${type.name}. Health now: ${health.toStringAsFixed(2)}',
    );
  }

  void attack(BaseTroop target) {
    final baseDamage = calculateOutgoingDamage();

    final Map<DamageType, double> finalDamages = Map.from(baseDamage.damages);

    print(
      '\n${name} performs an attack on ${target.name}. Base Damage Profile: $baseDamage.',
    );

    final weaknessInteraction = getWeaknessInteraction(this, target);
    if (weaknessInteraction != null) {
      for (final type in finalDamages.keys.toList()) {
        finalDamages[type] =
            finalDamages[type]! * weaknessInteraction.multiplier;
      }
      print('  Effect: ${weaknessInteraction.message}');
    }

    for (final entry in finalDamages.entries) {
      final damageType = entry.key;
      final damageAmount = entry.value;

      if (damageAmount > 0) {
        target.takeDamage(damageAmount, damageType);
      }
    }
  }

  List<TraitType> get traits;

  bool hasTrait(TraitType type) => traits.contains(type);

  void updateStatsForLevel();
}
