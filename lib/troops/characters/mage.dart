import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class MageTroop extends BaseTroop {
  MageTroop({double? health, Map<DamageType, double>? baseDamage})
    : super(
        name: "Mage",
        health: health ?? 60,
        baseDamage: baseDamage ?? {DamageType.magical: 22.0},
      );

  @override
  List<TraitType> get traits => [
    TraitType.MAGICAL,
    TraitType.MAGIC_CASTER,
    TraitType.RANGED,
  ];
}
