import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';

mixin HasMovement on BaseTroop {
  int get baseMovement;
  int movementBonus = 0;

  int get movement => baseMovement + movementBonus;
}
