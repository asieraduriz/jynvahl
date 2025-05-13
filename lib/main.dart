import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HexagonComponent extends PositionComponent {
  final int id;
  final int row;
  final int column;
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
    required this.hexSize,
    required this.id,
    Color color = Colors.blue,
  }) : _paint =
           Paint()
             ..color = color
             ..style = PaintingStyle.fill,
       super(size: Vector2(72, 72));

  @override
  void render(Canvas canvas) {
    final center = Offset(width / 2, height / 2);
    final hexPoints = calculateHexagonPoints(center, hexSize);
    _hexagonPoints = hexPoints;
    final path = Path()..addPolygon(hexPoints, true);
    canvas.drawPath(path, _paint);
  }

  List<Offset> calculateHexagonPoints(Offset center, double size) {
    final List<Offset> points = [];
    for (int i = 0; i < 6; i++) {
      final angle = (2 * pi / 6) * i;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      points.add(Offset(x, y));
    }
    return points;
  }

  // @override
  // void onTapUp(TapUpEvent event) {
  //   // TODO: implement onTapUp
  //   print("Tapped on hexagon at position: $id");
  // }
}

bool isTapInsideFlatTopHexagon(Offset tapPoint, List<Offset> vertices) {
  int n = vertices.length;
  Offset p1, p2;

  for (int i = 0; i < n; i++) {
    p1 = vertices[i];
    p2 = vertices[(i + 1) % n];
    if (((p1.dy <= tapPoint.dy && tapPoint.dy < p2.dy) ||
            (p2.dy <= tapPoint.dy && tapPoint.dy < p1.dy)) &&
        tapPoint.dx <
            (p2.dx - p1.dx) * (tapPoint.dy - p1.dy) / (p2.dy - p1.dy) + p1.dx) {
      return true;
    }
  }
  return false;
}

class HexagonGame extends FlameGame with TapCallbacks {
  final List<HexagonComponent> _hexes = [];
  @override
  Future<void> onLoad() async {
    debugMode = true;
    final firstHexPosition = Vector2(20, 20);
    final firstHexagonComponent = HexagonComponent(
      id: 1,
      row: 0,
      column: 0,
      position: firstHexPosition,
      hexSize: 36,
      color: Colors.green,
    );

    add(firstHexagonComponent);

    final secondHexPosition = _calculateNextStaggeredHexagonPositionRight(
      firstHexPosition,
      36,
    );

    print("Second hex position $secondHexPosition");

    final secondHexagonComponent = HexagonComponent(
      id: 2,
      row: 0,
      column: 1,
      position: secondHexPosition,
      hexSize: 36,
      color: Colors.purple,
    );
    add(secondHexagonComponent);

    final thirdHexOnRow = HexagonComponent(
      row: 0,
      column: 2,
      hexSize: 36,
      id: 4,
      position: Vector2(128, 20),
    );

    add(thirdHexOnRow);

    final thirdHexPosition = _calculateNextStaggeredRowHexagonPosition(
      Vector2(20, 20),
      36,
    );
    add(
      HexagonComponent(
        id: 3,
        row: 1,
        column: 0,
        position: thirdHexPosition,
        hexSize: 36,
        color: Colors.orange,
      ),
    );

    print("Third hex position $thirdHexPosition");
    _hexes.addAll([firstHexagonComponent, secondHexagonComponent]);
  }

  Vector2 _calculateNextStaggeredHexagonPositionRight(
    Vector2 previousPosition,
    double hexRadius,
  ) {
    final horizontalShift = 1.5 * hexRadius;
    final verticalShift = sqrt(3) / 2 * hexRadius;
    return Vector2(
      previousPosition.x + horizontalShift,
      previousPosition.y + verticalShift,
    );
  }

  Vector2 _calculateNextStaggeredRowHexagonPosition(
    Vector2 firstRowHexPosition,
    double hexRadius,
  ) {
    final verticalDistanceBetweenRows = sqrt(3) * hexRadius;
    return Vector2(
      firstRowHexPosition.x,
      firstRowHexPosition.y + verticalDistanceBetweenRows,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: implement onTapUp
    print("Tapped at ${event.localPosition}");

    final offset = Offset(event.localPosition.x, event.localPosition.y);

    for (var hex in _hexes) {
      final isInside = isTapInsideFlatTopHexagon(offset, hex.points);
      if (isInside) {
        print("Tapped inside ${hex.id}");
      }
    }
  }
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
