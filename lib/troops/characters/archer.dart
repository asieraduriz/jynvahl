import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';
import 'package:jynvahl_hex_game/troops/traits/trait_types.dart';

class ArcherTroop extends BaseTroop {
  ArcherTroop({
    double? health,
    Map<DamageType, double>? baseDamage,
    required int level,
    required int experience,
  }) : super(
         name: "Ranged Archer",
         health: health ?? 70,
         baseDamage: baseDamage ?? {DamageType.physical: 25.0},
         level: level,
         experience: experience,
       );

  @override
  List<TraitType> get traits => [TraitType.PHYSICAL, TraitType.RANGED];

  @override
  void updateStatsForLevel() {
    // TODO: implement updateStatsForLevel
    throw UnimplementedError(
      "ArcherTroop.updateStatsForLevel is not implemented yet.",
    );
  }
}
