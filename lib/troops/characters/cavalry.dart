import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/rarity.dart';
import 'package:jynvahl_hex_game/troops/traits/has_movement.dart';
import 'package:jynvahl_hex_game/troops/traits/is_melee.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class CavalryTroop extends BaseTroop with HasMovement, IsMelee {
  // Mixin traits
  @override
  int get baseMovement => 4;

  CavalryTroop({
    String? name,
    double? health,
    DamageProfile? baseDamage,
    DamageProfile? damagePerLevel,
    required int level,
    required int experience,
    required TroopRarity rarity,
    required int rarityEmblems,
  }) : super(
         name: name ?? "Cavalry Troop",
         baseStats: BaseStats(
           health: health ?? 120,
           healthPerLevel: 15.0,
           damage: baseDamage ?? {DamageType.physical: DamageRange(22.0, 28.0)},
           damagePerLevel:
               damagePerLevel ?? {DamageType.physical: DamageRange(3.0, 3.0)},
           level: level,
           rarity: rarity,
         ),
         experience: experience,
         rarityEmblems: rarityEmblems,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.MELEE];
}
