import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class HexagonTile extends PositionComponent {
  final String id;
  final Vector2 origin;
  final Paint _paint;
  final double hexSize;
  final bool isImpassable;
  late bool isPlaceable;

  late List<Offset> _hexagonPoints = [];

  HexagonTile({
    required this.id,
    required this.origin,
    required this.hexSize,
    required this.isImpassable,
    required String text,
    required this.isPlaceable,
    Color color = Colors.blue,
  }) : _paint =
           Paint()
             ..color = color
             ..style = PaintingStyle.fill,
       super(
         size: Vector2(hexSize * 2, hexSize * sqrt(3)),
         anchor: Anchor.center,
         position: origin,
       ) {
    final center = Offset(width / 2, height / 2);
    _hexagonPoints = calculateHexagonPoints(center, hexSize);

    final textComponent =
        TextComponent(
            text: text,
            textRenderer: TextPaint(
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          )
          ..position = center.toVector2()
          ..anchor = Anchor.center;

    add(textComponent);
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
