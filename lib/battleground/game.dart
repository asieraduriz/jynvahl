import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/manager.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/onMapTapController.dart';
import 'package:jynvahl_hex_game/map/pathfinding.dart';
import 'package:jynvahl_hex_game/map/tile.dart';
import 'package:jynvahl_hex_game/players/player.dart';
import 'package:jynvahl_hex_game/players/unit.dart';

Vector2 calculateHexOrigin(int row, int column, double hexRadius) {
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

final double hexRadius = 50.0;
final int numRows = 7;
final int numCols = 8;

class Battleground extends FlameGame with TapCallbacks {
  final String mapId;
  final Map<Hex, HexagonTile> _hexMap = {};

  final Player player;
  late final List<Unit> _playerPlayableUnits;
  //lineups, nice name
  final Map<Hex, PlayingUnit> _playerUnits = {};
  final Map<Hex, PlayingUnit> _opponentUnits = {};

  late BattlegroundManager battlegroundManager;
  late OnMapTapController onMapTapController;

  Battleground({required this.mapId, required this.player}) {
    this.battlegroundManager = BattlegroundManager(mapId: mapId)
      ..battleState = BattleState.placing;

    this.onMapTapController = OnMapTapController(
      this._hexMap,
      battlegroundManager,
    );

    _playerPlayableUnits =
        player.units.map((unit) => Unit(name: unit.name)).toList();
  }

  @override
  Future<void> onLoad() async {
    loadMap(mapId);

    // load opponent units
    loadOpponentUnits();
  }

  void loadMap(String mapId) {
    // debugMode = true;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final origin = calculateHexOrigin(row, col, hexRadius);
        final id = "hex_${row} ${col}";

        final axial_coords = oddq_to_axial(row, col);
        final isImpassable = axial_coords.q == 1 && axial_coords.r > 0;

        final isPlaceable =
            this.battlegroundManager.battleState == BattleState.placing &&
            [
              Hex(1, 0),
              Hex(2, 0),
              Hex(0, 3),
              Hex(2, -1),
            ].contains(axial_coords);

        final hexagon = HexagonTile(
          id: id,
          origin: origin,
          hexSize: hexRadius,
          color:
              isImpassable
                  ? Colors.blueGrey
                  : isPlaceable
                  ? Colors.lightBlue
                  : Colors.green,
          text: "${axial_coords.q}, ${axial_coords.r}",
          isImpassable: isImpassable,
          isPlaceable: isPlaceable,
        );

        _hexMap[axial_coords] = hexagon;
        add(hexagon);
      }
    }
  }

  void loadOpponentUnits() {
    List<Hex> opponentUnitPositions = [
      Hex(5, 2),
      Hex(6, 1),
      Hex(6, 2),
      Hex(7, -1),
    ];

    opponentUnitPositions.forEach((position) {
      final unit = PlayingUnit(
        position: _hexMap[position]!.position,
        name: 'troll',
      );
      _opponentUnits[position] = unit;
      add(unit);
    });
  }

  @override
  void onTapUp(TapUpEvent event) {
    final tappedAt = Vector2(event.localPosition.x, event.localPosition.y);

    switch (battlegroundManager.battleState) {
      case BattleState.placing:
        final closestHex = _findClosestHex(tappedAt);
        if (closestHex == null) {
          print("No hexagon found");
          return;
        }
        final hex = closestHex.key, tile = closestHex.value;
        // if tile has unit, remove unit and make placeable
        if (!tile.isPlaceable && _playerUnits[hex] != null) {
          final playingUnit = _playerUnits[hex]!;
          _playerPlayableUnits.add(Unit(name: playingUnit.name));
          _playerUnits.remove(hex);
          tile.isPlaceable = true;
          tile.changeColor(Colors.lightBlue);
          playingUnit.removeFromParent();

          return;
        }

        if (_playerPlayableUnits.isEmpty) {
          print("No more units to place, please start");
          return;
        }

        // if tile has no unit, place unit
        if (tile.isPlaceable) {
          final unit = _playerPlayableUnits.removeAt(0);
          final playingUnit = PlayingUnit(
            position: tile.position,
            name: unit.name,
          )..flipHorizontallyAroundCenter();
          _playerUnits[hex] = playingUnit;
          tile.isPlaceable = false;
          tile.changeColor(Colors.green);

          add(playingUnit);

          return;
        }

        break;

      default:
        break;
    }
    // onMapTapController.onTapUp(event);

    // final neighbours = getNeighbourCoordinates(closestHex, 2);
    // print("Neighbours $neighbours");

    // neighbours.forEach(
    //   (neighbour) => _hexMap[neighbour]?.changeColor(Colors.cyan),
    // );

    // final path = findPathAStar(
    //   start: Hex(0, 5),
    //   end: Hex(3, 4),
    //   hexMap: _hexMap,
    // );
    // path?.forEach((hex) => _hexMap[hex]?.changeColor(Colors.brown));
    // If I click on top-left hexagon, on the top left corner outside of the hexagon, it still indicates I clicked on 0,0 and this is wrong
    // print(
    //   "Closest hexagon found ${closestHex.q} ${closestHex.r} ${closestTile.id}",
    // );
  }

  Map<Hex, HexagonTile> _nativelyFindBoudingHex(Vector2 tappedAt) =>
      Map.fromEntries(
        _hexMap.entries.where((entry) => entry.value.containsPoint(tappedAt)),
      );

  MapEntry<Hex, HexagonTile>? _findClosestHex(Vector2 tappedAt) {
    final boundHexes = _nativelyFindBoudingHex(tappedAt);

    if (boundHexes.isEmpty) {
      return null;
    }

    double closestDistanceSquared = double.infinity;
    var closestHex = boundHexes.entries.first.key;
    var closestTile = boundHexes.entries.first.value;

    for (final entry in boundHexes.entries) {
      final hex = entry.key;
      final tile = entry.value;
      final distanceSquared = (tappedAt - tile.position).length2;

      if (distanceSquared < closestDistanceSquared) {
        closestDistanceSquared = distanceSquared;
        closestHex = hex;
        closestTile = tile;
      }
    }

    return MapEntry(closestHex, closestTile);
  }
}
