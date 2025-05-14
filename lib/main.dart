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
    final List<Offset> vertices = [];
    for (int i = 0; i < 6; i++) {
      final angle = (2 * pi / 6) * i;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      vertices.add(Offset(x, y));
    }

    return vertices;
  }

  // @override
  // void onTapUp(TapUpEvent event) {
  //   // TODO: implement onTapUp
  //   print("Tapped on hexagon at position: $id");
  // }
}

class HexagonGame extends FlameGame with TapCallbacks {
  final List<HexagonComponent> _hexes = [];
  @override
  Future<void> onLoad() async {
    debugMode = true;
    final firstHexPosition = Vector2.all(0);
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

    final thirdHexPos = _calculateNextNegativeStaggeredHexagonPositionRight(
      secondHexPosition,
      36,
    );
    final thirdHexagonComponent = HexagonComponent(
      id: 3,
      row: 0,
      column: 2,
      position: thirdHexPos,
      hexSize: 36,
      color: Colors.red,
    );
    add(thirdHexagonComponent);

    final thirdHexOnRow = HexagonComponent(
      row: 0,
      column: 2,
      hexSize: 36,
      id: 4,
      position: Vector2.all(0),
    );

    add(thirdHexOnRow);

    final thirdHexPosition = _calculateNextStaggeredRowHexagonPosition(
      Vector2.all(0),
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

    final fourthHexPosition = _calculateNextStaggeredHexagonPositionRight(
      thirdHexPosition,
      36,
    );

    final fourthHexagonComponent = HexagonComponent(
      id: 4,
      row: 1,
      column: 1,
      position: fourthHexPosition,
      hexSize: 36,
      color: Colors.yellow,
    );
    add(fourthHexagonComponent);

    final fifthHexPosition =
        _calculateNextNegativeStaggeredHexagonPositionRight(
          fourthHexPosition,
          36,
        );
    final fifthHexagonComponent = HexagonComponent(
      id: 5,
      row: 1,
      column: 2,
      position: fifthHexPosition,
      hexSize: 36,
      color: Colors.brown,
    );
    add(fifthHexagonComponent);

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

  Vector2 _calculateNextNegativeStaggeredHexagonPositionRight(
    Vector2 previousPosition,
    double hexRadius,
  ) {
    final horizontalShift = 1.5 * hexRadius;
    final verticalShift = sqrt(3) / 2 * -hexRadius;
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
  }
}

void main() {
  runApp(GameWidget(game: HexagonGame()));
}
