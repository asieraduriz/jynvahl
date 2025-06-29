import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class ArcherTroop extends BaseTroop {
  ArcherTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : super(
         name: "Ranged Archer",
         baseStats: BaseStats(
           health: health ?? 70,
           healthPerLevel: 18.0,
           damage: baseDamage ?? {DamageType.physical: 25.0},
           damagePerLevel: 2.0,
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.RANGED];
}
