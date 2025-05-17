import 'dart:math';

import 'package:flame/game.dart';

class Hex {
  final double q;
  final double r;

  Hex(this.q, this.r);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hex &&
          runtimeType == other.runtimeType &&
          q == other.q &&
          r == other.r;

  @override
  int get hashCode => q.hashCode ^ r.hashCode;

  @override
  String toString() => 'Hex{q: $q, r: $r}';
}

Hex oddq_to_axial(int row, int col) {
  double q = col.toDouble();
  double r = row - (col - (col & 1)) / 2;
  return Hex(q, r);
}

List<int> axial_to_oddq(Hex hex) {
  var col = hex.q;
  var row = hex.r + (hex.q - (hex.q.toInt() & 1)) / 2;

  return [row.toInt(), col.toInt()];
}

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

List<Hex> getRelativeNeighbourCoordinates(int N) {
  List<Hex> results = [];
  for (int q = -N; q <= N; q++) {
    for (int r = max(-N, -q - N); r <= min(N, -q + N); r++) {
      if (q == r && q == 0) continue;
      results.add(Hex(q.toDouble(), r.toDouble()));
    }
  }

  return results;
}

List<Hex> getNeighbourCoordinates(Hex origin, int N) {
  final neighbours = getRelativeNeighbourCoordinates(N);

  return neighbours
      .map((neighbour) => Hex(origin.q + neighbour.q, origin.r + neighbour.r))
      .toList();
}
