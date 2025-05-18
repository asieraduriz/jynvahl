import 'package:jynvahl_hex_game/players/unit.dart';

class Player {
  late List<Unit> units = [];

  Player() {
    units.addAll([Unit(name: "Gnoll"), Unit(name: "Orc")]);
  }
}
