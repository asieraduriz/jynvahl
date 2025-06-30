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
           health: health ?? 120,
           healthPerLevel: 15.0,
           damage: baseDamage ?? {DamageType.physical: 25.0},
           damagePerLevel: 3.0,
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.MELEE];
}
