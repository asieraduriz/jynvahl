import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class CavalryTroop extends BaseTroop {
  CavalryTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : super(
         name: "Cavalry Troop",
         baseStats: BaseStats(
           health: health ?? 150,
           healthPerLevel: 18.0,
           damage: baseDamage ?? {DamageType.physical: 30.0},
           damagePerLevel: 2.0,
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.MELEE];
}
