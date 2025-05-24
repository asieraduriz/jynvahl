import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/hud.dart';
import 'package:jynvahl_hex_game/battleground/hud_troop.dart';
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
  final startY = 150.0;

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

class Battleground extends PositionComponent with TapCallbacks {
  final String mapId;
  final Map<Hex, HexagonTile> _hexMap = {};

  final Player player;
  final Map<Hex, Unit?> playerLineup = {};
  final List<HudTroop> hudTroops = [];
  final List<PlayingUnit> deployedSprites = [];

  final Map<Hex, PlayingUnit> _opponentUnits = {};

  late BattlegroundManager battlegroundManager;

  Battleground({
    required this.mapId,
    required this.player,
    required Vector2 size,
  }) : super(size: size) {
    this.battlegroundManager = BattlegroundManager(mapId: mapId)
      ..battleState = BattleState.placing;
  }

  @override
  Future<void> onLoad() async {
    loadMap(mapId);

    // load opponent unitsl
    loadOpponentUnits();
    // add(HudTroop(position: Vector2(68.0, 20), size: Vector2.all(70)));

    // Adding items to the "HUD"
    player.units.forEachIndexed((index, unit) {
      final positionX = 40 + (70.0 * index);
      final hudTroop = HudTroop(
        position: Vector2(positionX, 30),
        size: Vector2.all(48),
        index: index,
        state: index == 0 ? TroopState.selected : TroopState.idle,
        unit: unit,
      );
      hudTroops.add(hudTroop);
      add(hudTroop);
    });
  }

  void loadMap(String mapId) {
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        final origin = calculateHexOrigin(row, col, hexRadius);
        final id = "hex_${row} ${col}";

        final axial_coords = oddq_to_axial(row, col);
        final isImpassable = axial_coords.q == 1 && axial_coords.r > 0;

        final isPlaceable = [
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
        if (isPlaceable) {
          playerLineup[axial_coords] = null;
        }
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

        if (tile.isPlaceable) {
          // if tile has unit, remove unit
          if (playerLineup[hex] != null) {
            print("There is already a unit");
            final deployedTroop = playerLineup[hex]!;
            playerLineup[hex] = null;

            hudTroops
                .firstWhere((troop) => troop.unit.id == deployedTroop.id)
                .state = TroopState.idle;

            // Handle selected HUD troop

            final firstIdleTroop = hudTroops.firstWhere(
              (troop) => troop.state == TroopState.idle,
            );
            firstIdleTroop.state = TroopState.selected;

            // Remove deployed sprite
            final spriteToDelete = deployedSprites.firstWhere(
              (deployedUnit) => deployedUnit.name == deployedTroop.name,
            );

            deployedSprites.remove(spriteToDelete);
            spriteToDelete.removeFromParent();

            return;
          }

          if (playerLineup[hex] == null) {
            // If tile has no unit, deploy selected troop from HUD if there's any selected
            final selectedTroop = hudTroops.firstWhereOrNull(
              (hudTroop) => hudTroop.state == TroopState.selected,
            );

            if (selectedTroop == null) {
              print("No available troops to deploy");
              return;
            }
            print("Selected troop is ${selectedTroop.index}");

            selectedTroop.state = TroopState.deployed;
            playerLineup[hex] = selectedTroop.unit;

            final playingUnit = PlayingUnit(
              position: tile.position,
              name: selectedTroop.unit.name,
            )..flipHorizontallyAroundCenter();

            deployedSprites.add(playingUnit);
            add(playingUnit);

            // And make next troop in HUD selected
            final firstIdleTroop = hudTroops.firstWhereOrNull(
              (troop) => troop.state == TroopState.idle,
            );
            firstIdleTroop?.state = TroopState.selected;
          }
        }

        break;

      default:
        print(
          "Other state ${battlegroundManager.battleState} not implemented yet",
        );
        break;
    }

    // Maybe other type of tiles have useful information, so don't disregard them
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
