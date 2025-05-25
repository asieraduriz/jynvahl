import 'package:jynvahl_hex_game/players/troop.dart';

class Player {
  late List<Troop> troops = [];

  Player() {
    troops.addAll([
      Troop(id: 1, name: "Gnoll"),
      Troop(id: 2, name: "Orc"),
      Troop(id: 3, name: "Troll"),
    ]);
  }
}
