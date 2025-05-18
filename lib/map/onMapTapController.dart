import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/manager.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/tile.dart';

class OnMapTapController {
  final Map<Hex, HexagonTile> _hexMap;
  final BattlegroundManager _battlegroundManager;

  OnMapTapController(this._hexMap, this._battlegroundManager);

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

  onTapUp(TapUpEvent event) {
    final tappedAt = Vector2(event.localPosition.x, event.localPosition.y);

    final closestHex = _findClosestHex(tappedAt);

    if (closestHex == null) {
      print("No hexagon found");
      return;
    }

    final hex = closestHex.key, tile = closestHex.value;

    switch (_battlegroundManager.battleState) {
      case BattleState.placing:
        if (tile.isPlaceable) {
          print("We can place the unit here");
          tile.changeColor(Colors.deepPurple);
          tile.isPlaceable = false;
        }
        break;

      default:
        break;
    }
  }
}
