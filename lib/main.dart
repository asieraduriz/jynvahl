import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(title: 'Hex Map Game', home: GameWidget(game: HexMapGame())),
  );
}

class Hex {
  final int q; // Column (axial coordinate)
  final int r; // Row (axial coordinate)
  Color color;

  Hex(this.q, this.r, {this.color = Colors.green});

  // Convert axial to pixel coordinates (approximate center)
  Vector2 toPosition(double size) {
    final x = size * (3 / 2 * q);
    final y = size * (sqrt(3) / 2 * q + sqrt(3) * r);
    return Vector2(x, y);
  }

  // Get the six vertices of the hexagon
  List<Offset> getVertices(double size) {
    final center = toPosition(size);
    final points = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final angle = 2 * pi / 6 * i;
      final x = center.x + size * cos(angle);
      final y = center.y + size * sin(angle);
      points.add(Offset(x, y));
    }
    return points;
  }
}

class HexMap extends PositionComponent with TapCallbacks {
  final double width;
  final double height;
  final double hexSize;
  final List<List<Hex>> _grid = [];
  final List<Color> _availableColors = [
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.yellow,
  ];
  final Random _random = Random();

  HexMap({required this.width, required this.height, this.hexSize = 72.0})
    : super(size: Vector2(0, 0)) {
    // Calculate the approximate size of the map
    final mapWidth = hexSize * 3 / 2 * width;
    final mapHeight = hexSize * (sqrt(3) * height + sqrt(3) / 2);
    size.setValues(mapWidth, mapHeight);

    // Initialize the grid with random colors
    for (var q = 0; q < width; q++) {
      _grid.add(
        List.generate(height.toInt(), (r) {
          final randomColor =
              _availableColors[_random.nextInt(_availableColors.length)];
          return Hex(q, r, color: randomColor);
        }),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final row in _grid) {
      for (final hex in row) {
        paint.color = hex.color;
        canvas.drawPath(
          Path()..addPolygon(hex.getVertices(hexSize), true),
          paint,
        );
      }
    }
  }

  // Find the hex that contains the given point
  Hex? _getHexAt(Vector2 worldPosition) {
    final size = hexSize;
    final x = worldPosition.x;
    final y = worldPosition.y;

    final qApprox = x * 2 / 3 / size;
    final rApprox = (-x / 3 + sqrt(3) / 3 * y) / size;

    final qRound = qApprox.round().toInt();
    final rRound = rApprox.round().toInt();

    if (qRound >= 0 && qRound < width && rRound >= 0 && rRound < height) {
      return _grid[qRound][rRound];
    }
    return null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tappedPosition = event.localPosition;
    final hex = _getHexAt(tappedPosition);
    if (hex != null) {
      print('Clicked Hex: q=${hex.q}, r=${hex.r}, Color: ${hex.color}');
      hex.color = Color(
        (Random().nextDouble() * 0xFFFFFF).toInt(),
      ).withOpacity(1.0);
    }
  }
}

class HexMapGame extends FlameGame with TapDetector {
  @override
  Future<void> onLoad() async {
    add(
      HexMap(width: 72, height: 72, hexSize: 36.0),
    ); // Adjust hexSize as needed
  }
}
