import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/pathfinding.dart';
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

class Battleground extends FlameGame with TapCallbacks {
  final Map<Hex, HexagonTile> _hexMap = {};
  final double hexRadius = 50.0;
  final int numRows = 7;
  final int numCols = 8;

  @override
  Future<void> onLoad() async {
    // debugMode = true;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final origin = calculateHexOrigin(row, col, hexRadius);
        final id = "hex_${row} ${col}";

        final axial_coords = oddq_to_axial(row, col);
        final isImpassable = axial_coords.q == 1 && axial_coords.r > 0;
        final hexagon = HexagonTile(
          id: id,
          origin: origin,
          hexSize: hexRadius,
          color: isImpassable ? Colors.blueGrey : Colors.green,
          text: "${axial_coords.q}, ${axial_coords.r}",
          isImpassable: isImpassable,
        );
        _hexMap[axial_coords] = hexagon;
        add(hexagon);
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    Map<Hex, HexagonTile> hexes = {};
    final tappedAt = Vector2(event.localPosition.x, event.localPosition.y);
    print("\nTapped at: $tappedAt");
    for (final entry in _hexMap.entries) {
      final hex = entry.key;
      final tile = entry.value;
      if (tile.containsPoint(tappedAt)) {
        print("Potential hexagon found ${tile.position}");
        hexes[hex] = tile;
      }
    }

    if (hexes.isEmpty) {
      print("No hexagon found");
      return;
    }
    double closestDistanceSquared = double.infinity;
    var closestHex = hexes.entries.first.key;
    var closestTile = hexes.entries.first.value;

    for (final entry in hexes.entries) {
      final hex = entry.key;
      final tile = entry.value;
      final distanceSquared = (tappedAt - tile.position).length2;

      if (distanceSquared < closestDistanceSquared) {
        closestDistanceSquared = distanceSquared;
        closestHex = hex;
        closestTile = tile;
      }
    }
    closestTile.changeColor(Colors.pink);

    final neighbours = getNeighbourCoordinates(closestHex, 2);
    print("Neighbours $neighbours");

    neighbours.forEach(
      (neighbour) => _hexMap[neighbour]?.changeColor(Colors.cyan),
    );

    final path = findPathAStar(
      start: Hex(0, 5),
      end: Hex(3, 4),
      hexMap: _hexMap,
    );
    path?.forEach((hex) => _hexMap[hex]?.changeColor(Colors.brown));
    // If I click on top-left hexagon, on the top left corner outside of the hexagon, it still indicates I clicked on 0,0 and this is wrong
    print(
      "Closest hexagon found ${closestHex.q} ${closestHex.r} ${closestTile.id}",
    );
  }
}
