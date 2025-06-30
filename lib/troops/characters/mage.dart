import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/has_movement.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class MageTroop extends BaseTroop with HasMovement {
  // Mixin traits
  @override
  int get baseMovement => 3;

  MageTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : super(
         name: "Mage",
         baseStats: BaseStats(
           health: health ?? 60,
           healthPerLevel: 8.0,
           damage: baseDamage ?? {DamageType.magical: 22.0},
           damagePerLevel: 8.0,
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [
    TraitType.MAGICAL,
    TraitType.MAGIC_CASTER,
    TraitType.RANGED,
  ];
}
