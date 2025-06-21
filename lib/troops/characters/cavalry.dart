import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class CavalryTroop extends BaseTroop {
  CavalryTroop({double? health, Map<DamageType, double>? baseDamage})
    : super(
        name: "Cavalry Troop",
        health: health ?? 150,
        baseDamage: baseDamage ?? {DamageType.physical: 30.0},
      );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.MELEE];
}
