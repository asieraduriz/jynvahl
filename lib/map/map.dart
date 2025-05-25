import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/tile.dart';
import 'package:jynvahl_hex_game/settings.dart';

final int numRows = 7;
final int numCols = 8;

Vector2 _calculateHexOrigin(int row, int column, double hexRadius) {
  double x = startX + column * horizontalSpacing;
  double y = startY + row * verticalSpacing;

  if (column % 2 == 1) {
    y += verticalSpacing / 2;
  }

  return Vector2(x, y);
}

Map<Hex, HexagonTile> loadMap(String mapId) {
  final Map<Hex, HexagonTile> hexMap = {};

  for (int row = 0; row < numRows; row++) {
    for (int col = 0; col < numCols; col++) {
      final origin = _calculateHexOrigin(row, col, hexRadius);
      final id = "hex_${row} ${col}";

      final axial_coords = oddq_to_axial(row, col);
      final isImpassable = axial_coords.q == 1 && axial_coords.r > 0;

      final isPlaceable = [
        Hex(1, 0),
        Hex(2, 0),
        Hex(0, 3),
        Hex(2, -1),
      ].contains(axial_coords);

      final hexagon = HexagonTile(
        id: id,
        origin: origin,
        hexSize: hexRadius,
        color:
            isImpassable
                ? Colors.blueGrey
                : isPlaceable
                ? Colors.lightBlue
                : Colors.green,
        text: "${axial_coords.q}, ${axial_coords.r}",
        isImpassable: isImpassable,
        isPlaceable: isPlaceable,
      );

      hexMap[axial_coords] = hexagon;
    }
  }

  return hexMap;
}
