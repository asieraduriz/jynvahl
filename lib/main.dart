import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Import the collection package

void main() {
  runApp(
    MaterialApp(title: 'Hex Map Game', home: GameWidget(game: HexMapGame())),
  );
}

class Hex {
  final int q; // Column (axial coordinate)
  final int r; // Row (axial coordinate)
  Color color;
  bool isPath =
      false; // Added to track if this hex is part of the path.  IMPORTANT CHANGE
  bool isWall = false; // Added to track if this hex is a wall. IMPORTANT CHANGE

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

  @override
  bool operator ==(Object other) {
    if (other is! Hex) return false;
    return other.q == q && other.r == r;
  }

  @override
  int get hashCode => q.hashCode ^ r.hashCode;
}

class HexMap extends PositionComponent with TapCallbacks {
  final double width;
  final double height;
  final double hexSize;
  final List<List<Hex>> _grid = [];
  final List<Color> _availableColors = [
    Colors.grey,
    Colors.green,
    Colors.orange, // Wall color
    Colors.blue,
    Colors.yellow,
  ];
  final Random _random = Random();
  Hex? _startHex; // Keep track of the start and end hexes for pathfinding
  Hex? _endHex;
  List<Hex> _path =
      []; // Store the calculated path.  IMPORTANT CHANGE - path list.  used in render

  HexMap({required this.width, required this.height, this.hexSize = 72.0})
    : super(size: Vector2(0, 0)) {
    // Calculate the approximate size of the map
    final mapWidth = hexSize * 3 / 2 * width;
    final mapHeight = hexSize * (sqrt(3) * height + sqrt(3) / 2);
    size.setValues(mapWidth, mapHeight);

    // Initialize the grid with random colors and set walls
    for (var q = 0; q < width; q++) {
      _grid.add(
        List.generate(height.toInt(), (r) {
          final randomColor =
              _availableColors[_random.nextInt(_availableColors.length)];
          final hex = Hex(q, r, color: randomColor);
          if (randomColor == Colors.orange) {
            hex.isWall = true; // Set orange hexes as walls
          }
          return hex;
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
        // Use a different color if the hex is part of the path
        paint.color = hex.isPath ? Colors.pink : hex.color; // CHANGED COLOR
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

  // Implementation of the A* pathfinding algorithm
  List<Hex> _findPath(Hex start, Hex end) {
    // Initialize the open and closed sets
    final openSet = PriorityQueue<_Node>();
    final closedSet = <Hex>{};

    // Create a start node
    final startNode = _Node(start, 0, _calculateDistance(start, end));
    openSet.add(startNode);

    // Keep track of the cameFrom information
    final cameFrom = <Hex, Hex>{};

    // While the open set is not empty
    while (openSet.isNotEmpty) {
      // Get the node with the lowest fScore
      final currentNode = openSet.removeFirst();
      final currentHex = currentNode.hex;

      // If we reached the goal, reconstruct the path and return it
      if (currentHex == end) {
        return _reconstructPath(cameFrom, currentHex);
      }

      // Move the current node to the closed set
      closedSet.add(currentHex);

      // Get the neighbors of the current hex
      final neighbors = _getNeighbors(currentHex);

      // For each neighbor
      for (final neighbor in neighbors) {
        // If the neighbor is in the closed set or is a wall, skip it
        if (closedSet.contains(neighbor) || neighbor.isWall) {
          // Check for wall here
          continue;
        }

        // Calculate the tentative gScore
        final tentativeGScore =
            currentNode.gScore +
            1; // Cost of moving from one hex to another is 1

        // Check if neighbor is in openset
        _Node? neighborNode;
        for (final node in openSet.toList()) {
          if (node.hex == neighbor) {
            neighborNode = node;
            break;
          }
        }

        // If the neighbor is not in the open set, add it
        if (neighborNode == null) {
          final newNode = _Node(
            neighbor,
            tentativeGScore,
            _calculateDistance(neighbor, end),
          );
          openSet.add(newNode);
          cameFrom[neighbor] = currentHex;
        }
        // Otherwise, check if the new path is better
        else if (tentativeGScore < neighborNode.gScore) {
          // Update the gScore and fScore of the neighbor
          neighborNode.gScore = tentativeGScore;
          neighborNode.fScore =
              tentativeGScore + _calculateDistance(neighbor, end);
          cameFrom[neighbor] = currentHex;
          cameFrom[neighbor] = currentHex;
        }
      }
    }

    // If the open set is empty and we haven't reached the goal, there is no path
    return [];
  }

  // Function to reconstruct the path from the cameFrom information
  List<Hex> _reconstructPath(Map<Hex, Hex> cameFrom, Hex current) {
    final path = <Hex>[current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.add(current);
    }
    return path.reversed
        .toList(); // Reverse the path to get it from start to end
  }

  // Function to get the neighbors of a hex
  List<Hex> _getNeighbors(Hex hex) {
    final neighbors = <Hex>[];
    final directions = [
      [1, 0],
      [1, -1],
      [0, -1],
      [-1, 0],
      [-1, 1],
      [0, 1],
    ]; // Axial directions

    for (final dir in directions) {
      final newQ = hex.q + dir[0];
      final newR = hex.r + dir[1];
      if (newQ >= 0 &&
          newQ < width &&
          newR >= 0 &&
          newR <
              height) // Make sure the neighbor is within the grid bounds.  IMPORTANT
      {
        neighbors.add(_grid[newQ][newR]);
      }
    }
    return neighbors;
  }

  // Function to calculate the distance between two hexes (using axial coordinates)
  int _calculateDistance(Hex a, Hex b) {
    final dq = b.q - a.q;
    final dr = b.r - a.r;
    return (dq.abs() + dr.abs() + (dq + dr).abs()) ~/
        2; // Axial distance formula
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tappedPosition = event.localPosition;
    final hex = _getHexAt(tappedPosition);
    if (hex != null) {
      if (_startHex == null) {
        // If this is the first tap, set the start hex
        _startHex = hex;
        print('Start Hex: q=${hex.q}, r=${hex.r}, Color: ${hex.color}');
      } else if (_endHex == null) {
        // If this is the second tap, set the end hex and find the path
        _endHex = hex;
        print('End Hex: q=${hex.q}, r=${hex.r}, Color: ${hex.color}');
        _path = _findPath(_startHex!, _endHex!); // Calculate the path

        // Reset the isPath property for all hexes first
        for (final row in _grid) {
          for (final h in row) {
            h.isPath = false;
          }
        }
        //set the path
        for (final pathHex in _path) {
          pathHex.isPath = true;
        }
        _startHex =
            null; // Reset start and end hexes so you can select a new path.
        _endHex = null;
        // Print the path to the console
        print('Path:');
        for (final pathHex in _path) {
          print('q=${pathHex.q}, r=${pathHex.r}');
        }
      }
      //basic color change.  Make Walls toggle on tap.
      hex.isWall = !hex.isWall;
      hex.color =
          hex.isWall
              ? Colors.orange
              : _availableColors[_random.nextInt(_availableColors.length)];
    }
  }
}

// A* Node class for use in the priority queue
class _Node implements Comparable<_Node> {
  final Hex hex;
  int gScore;
  int fScore;

  _Node(this.hex, this.gScore, this.fScore);

  @override
  int compareTo(_Node other) {
    // Lowest fScore first.  This is what makes it a priority queue.
    if (fScore != other.fScore) {
      return fScore.compareTo(other.fScore);
    }
    // If fScores are equal, compare gScores (optional tie-breaker)
    return gScore.compareTo(other.gScore);
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
