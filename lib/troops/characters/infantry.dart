import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/armored.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class InfantryTroop extends BaseTroop with Armored {
  @override
  final double armorRating;

  InfantryTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    double? armorRating,
  }) : armorRating = armorRating ?? 10.0,
       super(
         name: "Infantry Troop",
         health: health ?? 120,
         baseDamage: baseDamage ?? {DamageType.physical: 18.0},
       );

  @override
  List<TraitType> get traits => [
    TraitType.PHYSICAL,
    TraitType.MELEE,
    TraitType.ARMORED,
  ];
}
