import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HexagonComponent extends PositionComponent {
  final Paint _paint;
  final double hexSize;

  HexagonComponent({
    super.position,
    required this.hexSize,
    Color color = Colors.blue,
  }) : _paint =
           Paint()
             ..color = color
             ..style = PaintingStyle.fill,
       super(size: Vector2(72, 72));

  @override
  void render(Canvas canvas) {
    final center = Offset(width / 2, height / 2);
    final points = _calculateHexagonPoints(center, hexSize);
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, _paint);
  }

  List<Offset> _calculateHexagonPoints(Offset center, double size) {
    final List<Offset> points = [];
    for (int i = 0; i < 6; i++) {
      final angle = (2 * pi / 6) * i;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      points.add(Offset(x, y));
    }
    return points;
  }
}

class HexagonGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final firstHexPosition = Vector2(0, 0);
    add(
      HexagonComponent(
        position: firstHexPosition,
        hexSize: 36,
        color: Colors.green,
      ),
    );

    final secondHexPosition = _calculateNextStaggeredHexagonPositionRight(
      firstHexPosition,
      36,
    );
    add(
      HexagonComponent(
        position: secondHexPosition,
        hexSize: 36,
        color: Colors.purple,
      ),
    );

    final thirdHexPosition = _calculateNextStaggeredRowHexagonPosition(
      firstHexPosition,
      36,
    );
    add(
      HexagonComponent(
        position: thirdHexPosition,
        hexSize: 36,
        color: Colors.orange,
      ),
    );
  }

  Vector2 _calculateNextStaggeredHexagonPositionRight(
    Vector2 previousPosition,
    double hexRadius,
  ) {
    final sideLength = hexRadius;
    final horizontalShift = 1.5 * sideLength;
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
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
