import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/armored.dart';
import 'package:jynvahl_hex_game/troops/traits/has_movement.dart';
import 'package:jynvahl_hex_game/troops/traits/is_melee.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class InfantryTroop extends BaseTroop with Armored, HasMovement, IsMelee {
  // Mixin traits
  @override
  final double armorRating;

  @override
  int get baseMovement => 3;

  InfantryTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    double? armorRating,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : armorRating = armorRating ?? 10.0,
       super(
         name: "Infantry Troop",
         baseStats: BaseStats(
           health: health ?? 120,
           healthPerLevel: 18.0,
           damage: baseDamage ?? {DamageType.physical: 18.0},
           damagePerLevel: 2.0,
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [
    TraitType.PHYSICAL,
    TraitType.MELEE,
    TraitType.ARMORED,
  ];
}
