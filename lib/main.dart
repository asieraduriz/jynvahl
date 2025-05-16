import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/map/hex.dart';

Vector2 _calculateHexPositionOddQ(int row, int column, double hexRadius) {
  final horizontalSpacing = 1.5 * hexRadius;
  final verticalSpacing = sqrt(3) * hexRadius;
  final startX = 50.0;
  final startY = 50.0;

  double x = startX + column * horizontalSpacing;
  double y = startY + row * verticalSpacing;

  if (column % 2 == 1) {
    y += verticalSpacing / 2;
  }

  return Vector2(x, y);
}

class HexagonGame extends FlameGame with TapCallbacks {
  final List<HexagonTile> _hexes = [];
  final double hexRadius = 36.0;
  final int numRows = 1;
  final int numCols = 7;

  @override
  Future<void> onLoad() async {
    debugMode = true;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final position = _calculateHexPositionOddQ(row, col, hexRadius);
        final id = "hex_${row}_${col}";

        final hexagon = HexagonTile(
          id: id,
          position: position,
          hexSize: hexRadius,
          color: Colors.green,
        );
        add(hexagon);
        _hexes.add(hexagon);
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    List<HexagonTile> hexes = [];
    for (var hex in _hexes) {
      if (hex.containsPoint(
        Vector2(event.localPosition.x, event.localPosition.y),
      )) {
        print("\nPotential hexagon found ${hex.id}");
        hexes.add(hex);
        hex.changeColor(Colors.pink);
      }
    }
  }
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
