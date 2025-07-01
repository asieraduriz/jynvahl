import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/has_movement.dart';
import 'package:jynvahl_hex_game/troops/traits/has_range.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class ArcherTroop extends BaseTroop with HasMovement, HasRange {
  // Mixin traits
  @override
  int get baseMovement => 3;

  @override
  int get baseRange => 4;

  ArcherTroop({
    String? name,
    double? health,
    DamageProfile? baseDamage,
    DamageProfile? damagePerLevel,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : super(
         name: name ?? "Ranged Archer",
         baseStats: BaseStats(
           health: health ?? 70,
           healthPerLevel: 11.0,
           damage: baseDamage ?? {DamageType.physical: DamageRange(18.0, 22.0)},
           damagePerLevel:
               damagePerLevel ?? {DamageType.physical: DamageRange(2.0, 2.0)},
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.RANGED];
}
