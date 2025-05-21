import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/hud.dart';
import 'package:jynvahl_hex_game/battleground/manager.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/onMapTapController.dart';
import 'package:jynvahl_hex_game/map/pathfinding.dart';
import 'package:jynvahl_hex_game/map/tile.dart';
import 'package:jynvahl_hex_game/players/player.dart';
import 'package:jynvahl_hex_game/players/unit.dart';

final double hexRadius = 50.0;
final int numRows = 7;
final int numCols = 8;

class Skeleton extends PositionComponent {
  @override
  Future<void> onLoad() async {
    add(Hud());
  }
}
