import 'dart:math';

import 'package:collection/collection.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/tile.dart';

final _priorityQueue = PriorityQueue<_PriorityQueueElement>(
  (a, b) => a.priority.compareTo(b.priority),
);

double _heuristic(Hex a, Hex b) {
  final dx = (a.q - b.q).abs();
  final dy = (a.r - b.r).abs();
  return max(dx, dy).toDouble();
}

List<Hex>? findPathAStar({
  required Hex start,
  required Hex end,
  required Map<Hex, HexagonTile> hexMap,
}) {
  if (!hexMap.containsKey(start) || !hexMap.containsKey(end)) {
    return null;
  }

  final Map<Hex, double> gScore = {start: 0};
  final Map<Hex, double> fScore = {start: _heuristic(start, end)};
  final Map<Hex, Hex?> cameFrom = {};

  _priorityQueue.clear();
  _priorityQueue.add(_PriorityQueueElement(start, fScore[start]!));

  while (_priorityQueue.isNotEmpty) {
    final current = _priorityQueue.removeFirst().hex;

    if (current == end) {
      return _reconstructPathAStar(cameFrom, current);
    }

    final neighborHexes = getNeighbourCoordinates(current, 1);
    final walkableHexes =
        neighborHexes.where((hex) {
          final tile = hexMap[hex];
          final isImpassable = tile?.isImpassable;
          if (isImpassable != null) {
            return !isImpassable;
          }

          return false;
        }).toList();
    for (final neighborHex in walkableHexes) {
      final tentativeGScore = gScore[current]! + 1;

      if (!gScore.containsKey(neighborHex) ||
          tentativeGScore < gScore[neighborHex]!) {
        cameFrom[neighborHex] = current;
        gScore[neighborHex] = tentativeGScore;
        fScore[neighborHex] = tentativeGScore + _heuristic(neighborHex, end);
        _priorityQueue.add(
          _PriorityQueueElement(neighborHex, fScore[neighborHex]!),
        );
      }
    }
  }

  return null;
}

List<Hex> _reconstructPathAStar(Map<Hex, Hex?> cameFrom, Hex current) {
  final path = <Hex>[current];
  while (cameFrom.containsKey(current)) {
    current = cameFrom[current]!;
    path.add(current);
  }
  return path.reversed.toList();
}

class _PriorityQueueElement {
  final Hex hex;
  final double priority;

  _PriorityQueueElement(this.hex, this.priority);
}
