import 'package:jynvahl_hex_game/troops/characters/base_troop.dart';

mixin HasRange on BaseTroop {
  int get baseRange;

  int rangeBonus = 0;

  int get range => baseRange + rangeBonus;
}
