import 'package:jynvahl_hex_game/players/unit.dart';

class Player {
  late List<Unit> units = [];

  Player() {
    units.addAll([Unit(id: 1, name: "Gnoll"), Unit(id: 2, name: "Orc")]);
  }
}
