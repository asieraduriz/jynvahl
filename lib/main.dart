import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/character.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/tile.dart';

Vector2 calculateHexOrigin(int row, int column, double hexRadius) {
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
  final double hexRadius = 50.0;
  final int numRows = 7;
  final int numCols = 8;

  @override
  Future<void> onLoad() async {
    // debugMode = true;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final origin = calculateHexOrigin(row, col, hexRadius);
        final id = "hex_${row}_${col}";

        final axial_coords = oddq_to_axial(row, col);
        final hexagon = HexagonTile(
          id: id,
          origin: origin,
          hexSize: hexRadius,
          color: Colors.green,
          text: "${axial_coords.q}_${axial_coords.r} | ${row}_$col",
        );
        add(hexagon);
        _hexes.add(hexagon);
      }
    }

    add(new Character());
  }

  @override
  void onTapUp(TapUpEvent event) {
    List<HexagonTile> hexes = [];
    final tappedAt = Vector2(event.localPosition.x, event.localPosition.y);
    print("\nTapped at: $tappedAt");
    for (final hex in _hexes) {
      if (hex.containsPoint(tappedAt)) {
        print("Potential hexagon found ${hex.position}");
        hexes.add(hex);
      }
    }

    if (hexes.isEmpty) {
      print("No hexagon found");
      return;
    }
    double closestDistanceSquared = double.infinity;
    HexagonTile closestHex = hexes[0];

    for (final center in hexes) {
      final distanceSquared =
          (tappedAt - center.origin).length2; // Calculate squared distance

      if (distanceSquared < closestDistanceSquared) {
        closestDistanceSquared = distanceSquared;
        closestHex = center;
      }
    }

    // If I click on top-left hexagon, on the top left corner outside of the hexagon, it still indicates I clicked on 0,0 and this is wrong
    print("Closest hexagon found ${closestHex.id}");
  }
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
