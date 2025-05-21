import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/players/player.dart';

void main() {
  final player = Player();
  runApp(GameWidget(game: JynvahlGame(mapId: "1", player: player)));
}
