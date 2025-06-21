import 'package:jynvahl_hex_game/troops/base_troop.dart';
import 'package:jynvahl_hex_game/troops/damage_profile.dart';

mixin Armored on BaseTroop {
  double get armorRating;

  @override
  void takeDamage(double amount, DamageType type) {
    print("Armor rating $armorRating");
    if (type == DamageType.physical) {
      final reducedAmount = amount * (1 - (armorRating / 100));
      print(
        '  - (Armored Trait) ${name} absorbs ${armorRating.toStringAsFixed(0)}% of physical damage. Reduced to ${reducedAmount.toStringAsFixed(2)}.',
      );
      super.takeDamage(reducedAmount, type);
    } else {
      super.takeDamage(amount, type);
    }
  }
}
