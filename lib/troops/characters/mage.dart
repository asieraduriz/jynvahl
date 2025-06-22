import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class MageTroop extends BaseTroop {
  MageTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
  }) : super(
         name: "Mage",
         health: health ?? 60,
         baseDamage: baseDamage ?? {DamageType.magical: 22.0},
         level: level,
         experience: experience,
       );

  @override
  List<TraitType> get traits => [
    TraitType.MAGICAL,
    TraitType.MAGIC_CASTER,
    TraitType.RANGED,
  ];

  @override
  void updateStatsForLevel() {
    // TODO: implement updateStatsForLevel
    throw UnimplementedError(
      "MageTroop.updateStatsForLevel is not implemented yet.",
    );
  }
}
