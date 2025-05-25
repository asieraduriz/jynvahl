import 'package:jynvahl_hex_game/players/troop.dart';

class Player {
  late List<Troop> troops = [];

  Player() {
    troops.addAll([
      Troop(id: 1, name: "Gnoll", spritePath: "unit_infantry_germany.png"),
      Troop(id: 3, name: "Orc", spritePath: "unit_infantry_blue.png"),
      Troop(id: 5, name: "Troll", spritePath: "unit_infantry_red.png"),
    ]);
  }
}
