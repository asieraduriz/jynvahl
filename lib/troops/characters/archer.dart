import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class ArcherTroop extends BaseTroop {
  ArcherTroop({double? health, Map<DamageType, double>? baseDamage})
    : super(
        name: "Ranged Archer",
        health: health ?? 70,
        baseDamage: baseDamage ?? {DamageType.physical: 25.0},
      );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.RANGED];
}
