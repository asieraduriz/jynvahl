import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';
import 'package:jynvahl_hex_game/troops/weaknesses/interactions.dart';

class BaseStats {
  double health;
  double healthPerLevel;

  DamageProfile damage;
  double damagePerLevel;

  int level;
  TroopRarity rarity;

  BaseStats({
    required this.health,
    required this.healthPerLevel,
    required this.damage,
    required this.damagePerLevel,
    required this.level,
    required this.rarity,
  });
}

abstract class BaseTroop {
  final String name;

  final BaseStats baseStats;
  final int experience;
  final int rarityEmblems;

  // Visual stats
  late double _currentHealth;
  double get health => _currentHealth;
  set health(double value) {
    _currentHealth = value;
    if (_currentHealth < 0) _currentHealth = 0;
  }

  late int effectiveLevel;

  late DamageProfile effectiveDamage;

  BaseTroop({
    required this.name,
    required this.baseStats,
    required this.experience,
    required this.rarityEmblems,
  }) {
    calculateInitialStats();
  }

  void calculateInitialStats() {
    effectiveLevel = baseStats.level + baseStats.rarity.index;
    _currentHealth =
        baseStats.health + (effectiveLevel * baseStats.healthPerLevel);
    effectiveDamage = baseStats.damage.map(
      (type, value) =>
          MapEntry(type, value + effectiveLevel * baseStats.damagePerLevel),
    );
  }

  List<TraitType> get traits;

  bool hasTrait(TraitType type) => traits.contains(type);

  DamageProfile calculateOutgoingDamage(BaseTroop target) {
    DamageProfile damages = Map.from(effectiveDamage);

    print('\n${name} performs an attack on ${target.name}.');

    final weaknessInteraction = getWeaknessInteraction(this, target);
    if (weaknessInteraction != null) {
      for (final type in damages.keys.toList()) {
        damages[type] = damages[type]! * weaknessInteraction.multiplier;
      }
      print('  Effect: ${weaknessInteraction.message}');
    }

    return damages;
  }

  void takeDamage(double amount, DamageType type) {
    health -= amount;
    if (health < 0) health = 0;
    print(
      '  ${name} took ${amount.toStringAsFixed(2)} total damage of type ${type.name}. Health now: ${health.toStringAsFixed(2)}',
    );
  }

  void attack(BaseTroop target) {
    final Map<DamageType, double> finalDamages = Map.from(effectiveDamage);

    print('\n${name} performs an attack on ${target.name}.');

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
}
