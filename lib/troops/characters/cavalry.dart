import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class CavalryTroop extends BaseTroop {
  CavalryTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
  }) : super(
         name: "Cavalry Troop",
         health: health ?? 150,
         baseDamage: baseDamage ?? {DamageType.physical: 30.0},
         level: level,
         experience: experience,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.MELEE];

  @override
  void updateStatsForLevel() {
    // TODO: implement updateStatsForLevel
    throw UnimplementedError(
      "CavalryTroop.updateStatsForLevel is not implemented yet.",
    );
  }
}
