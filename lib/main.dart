import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HexagonComponent extends PositionComponent {
  final int id;
  final int row;
  final int column;
  final Vector2 center;
  final Paint _paint;
  final double hexSize;

  List<Offset> _hexagonPoints = [];

  List<Offset> get points => _hexagonPoints;
  set points(List<Offset> value) {
    _hexagonPoints.clear();
    _hexagonPoints.addAll(value);
  }

  HexagonComponent({
    super.position,
    required this.row,
    required this.column,
    required this.center,
    required this.hexSize,
    required this.id,
    Color color = Colors.blue,
  }) : _paint =
           Paint()
             ..color = color
             ..style = PaintingStyle.fill,
       super(size: Vector2(hexSize * 2, hexSize * sqrt(3)));

  @override
  void render(Canvas canvas) {
    final center = Offset(width / 2, height / 2);
    final hexPoints = calculateHexagonPoints(center, hexSize);
    _hexagonPoints = hexPoints;
    final path = Path()..addPolygon(hexPoints, true);
    canvas.drawPath(path, _paint);
  }

  List<Offset> calculateHexagonPoints(Offset center, double size) {
    final List<Offset> vertices = [];
    for (int i = 0; i < 6; i++) {
      final angle = (2 * pi / 6) * i;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      vertices.add(Offset(x, y));
    }
    return vertices;
  }
}

class HexagonGame extends FlameGame with TapCallbacks {
  final List<HexagonComponent> _hexes = [];
  final double hexRadius = 36.0;
  final int numRows = 3;
  final int numCols = 5;

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

  @override
  Future<void> onLoad() async {
    debugMode = true;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final position = _calculateHexPositionOddQ(row, col, hexRadius);
        final id = row * numCols + col + 1;

        final hexagonCenter = Vector2(
          position.x + hexRadius,
          position.y + (hexRadius * sqrt(3)),
        );

        final hexagonEnd = Vector2(
          position.x + (2 * hexRadius),
          position.y + (2 * hexRadius * sqrt(3)),
        );
        print("Hexagon position $position $hexagonCenter $hexagonEnd");

        final hexagon = HexagonComponent(
          id: id,
          row: row,
          column: col,
          position: position,
          center: hexagonCenter,
          hexSize: hexRadius,
          color: Color.fromRGBO(
            row * 50 % 255,
            col * 50 % 255,
            (row + col) * 25 % 255,
            1.0,
          ),
        );
        add(hexagon);
        _hexes.add(hexagon);
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("Tapped at ${event.localPosition}");

    for (var hex in _hexes) {
      if (hex.containsPoint(
        Vector2(event.localPosition.x, event.localPosition.y),
      )) {
        print("\nPotential hexagon found ${hex.id}");
      }
    }
  }
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
