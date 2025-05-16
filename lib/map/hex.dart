import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class HexagonTile extends PositionComponent {
  final String id;
  final Paint _paint;
  final double hexSize;

  late List<Offset> _hexagonPoints = [];

  HexagonTile({
    super.position,
    required this.id,
    required this.hexSize,
    Color color = Colors.blue,
  }) : _paint =
           Paint()
             ..color = color
             ..style = PaintingStyle.fill,
       super(
         size: Vector2(hexSize * 2, hexSize * sqrt(3)),
         anchor: Anchor.center,
       ) {
    final center = Offset(width / 2, height / 2);
    _hexagonPoints = calculateHexagonPoints(center, hexSize);
  }

  @override
  void render(Canvas canvas) {
    final path = Path()..addPolygon(_hexagonPoints, true);
    canvas.drawPath(path, _paint);
  }

  void changeColor(Color color) {
    _paint.color = color;
  }
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
