import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:jynvahl_hex_game/battleground/hud_troop.dart';
import 'package:jynvahl_hex_game/battleground/manager.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/map.dart';
import 'package:jynvahl_hex_game/map/pathfinding.dart';
import 'package:jynvahl_hex_game/map/tile.dart';
import 'package:jynvahl_hex_game/players/player.dart';
import 'package:jynvahl_hex_game/players/troop.dart';
import 'package:jynvahl_hex_game/settings.dart';

Vector2 calculateHexOrigin(int row, int column, double hexRadius) {
  double x = startX + column * horizontalSpacing;
  double y = startY + row * verticalSpacing;

  if (column % 2 == 1) {
    y += verticalSpacing / 2;
  }

  return Vector2(x, y);
}

final int numRows = 7;
final int numCols = 8;

class Battleground extends PositionComponent with TapCallbacks {
  final String mapId;

  late Map<Hex, HexagonTile> _hexMap = {};
  final Player player;
  final Map<Hex, Troop?> playerLineup = {};
  final List<HudTroop> hudTroops = [];
  final List<PlayingTroop> deployedSprites = [];

  final Map<Hex, PlayingTroop> _opponentLineup = {};

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
    _hexMap = loadMap(mapId);
    _hexMap.forEach((hex, tile) {
      if (tile.isPlaceable) {
        playerLineup[hex] = null;
      }

      add(tile);
    });

    // load opponent lineup
    _opponentLineup.clear();
    loadOpponentLineup();

    // Adding items to the "HUD"
    player.troops.forEachIndexed((index, troop) {
      final positionX = 40 + (70.0 * index);
      final hudTroop = HudTroop(
        position: Vector2(positionX, 30),
        size: Vector2.all(48),
        index: index,
        state: index == 0 ? TroopState.selected : TroopState.idle,
        troop: troop,
      );
      hudTroops.add(hudTroop);
      add(hudTroop);
    });
  }

  void loadOpponentLineup() {
    List<Hex> lineupPositions = [Hex(5, 2), Hex(6, 1), Hex(6, 2), Hex(7, -1)];

    lineupPositions.forEach((position) {
      final troop = PlayingTroop(
        position: _hexMap[position]!.position,
        name: 'troll',
      );
      _opponentLineup[position] = troop;
      add(troop);
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
          // if tile has troop, remove troop
          if (playerLineup[hex] != null) {
            // Get deployed troom from Hex
            final deployedTroop = playerLineup[hex]!;
            playerLineup[hex] = null; // Remove troop from lineup

            // Set the deployed HUD troop state back to idle
            hudTroops
                .firstWhere((hudTroop) => hudTroop.troop.id == deployedTroop.id)
                .state = TroopState.idle;

            // Find first idle troop in HUD and set it to selected
            hudTroops.forEach((troop) {
              if (troop.state == TroopState.selected) {
                troop.state = TroopState.idle;
              }
            });
            hudTroops
                .firstWhere((troop) => troop.state == TroopState.idle)
                .state = TroopState.selected;

            // Remove deployed sprite
            final spriteToDelete = deployedSprites.firstWhere(
              (deployedTroop) => deployedTroop.name == deployedTroop.name,
            );

            deployedSprites.remove(spriteToDelete);
            spriteToDelete.removeFromParent();

            return;
          }

          if (playerLineup[hex] == null) {
            // If tile has no troop, deploy selected troop from HUD if there's any selected
            final selectedTroop = hudTroops.firstWhereOrNull(
              (hudTroop) => hudTroop.state == TroopState.selected,
            );

            if (selectedTroop == null) {
              print("No available troops to deploy");
              return;
            }

            selectedTroop.state = TroopState.deployed;
            playerLineup[hex] = selectedTroop.troop;

            final playingTrool = PlayingTroop(
              position: tile.position,
              name: selectedTroop.troop.name,
            )..flipHorizontallyAroundCenter();

            deployedSprites.add(playingTrool);
            add(playingTrool);

            // And make next troop in HUD selected
            final firstIdleTroop = hudTroops.firstWhereOrNull(
              (troop) => troop.state == TroopState.idle,
            );
            firstIdleTroop?.state = TroopState.selected;

            return;
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

  void onHudTroopTapped(HudTroop tappedHudTroop) {
    if (tappedHudTroop.state == TroopState.idle) {
      hudTroops.forEach((troop) {
        if (troop.state != TroopState.deployed) {
          troop.state = TroopState.idle;
        }
      });
      tappedHudTroop.state = TroopState.selected;

      return;
    }

    if (tappedHudTroop.state == TroopState.selected) {
      final selectedTroop = hudTroops.firstWhereOrNull(
        (hudTroop) => hudTroop.state == TroopState.selected,
      );

      if (selectedTroop == null) {
        print("No available troops to deploy");
        return;
      }

      final firstAvailableHex =
          playerLineup.entries.firstWhere((entry) => entry.value == null).key;
      final firstAvailableTile = _hexMap[firstAvailableHex];
      playerLineup[firstAvailableHex] = selectedTroop.troop;

      final playingTroop = PlayingTroop(
        position: firstAvailableTile!.position,
        name: selectedTroop.troop.name,
      )..flipHorizontallyAroundCenter();

      deployedSprites.add(playingTroop);
      add(playingTroop);

      selectedTroop.state = TroopState.deployed;
      // And make next troop in HUD selected
      final firstIdleTroop = hudTroops.firstWhereOrNull(
        (troop) => troop.state == TroopState.idle,
      );
      firstIdleTroop?.state = TroopState.selected;

      return;
    }

    if (tappedHudTroop.state == TroopState.deployed) {
      final matchingLineupTroop = playerLineup.entries.firstWhere(
        (entry) => entry.value?.id == tappedHudTroop.troop.id,
      );
      print("Deployed troop tapped at hex ${matchingLineupTroop.key}");

      playerLineup[matchingLineupTroop.key] = null;

      hudTroops.forEach((troop) {
        if (troop.state != TroopState.deployed) {
          troop.state = TroopState.idle;
        }
      });
      tappedHudTroop.state = TroopState.selected;

      // Remove deployed sprite
      final spriteToDelete = deployedSprites.firstWhere(
        (deployedTrool) => deployedTrool.name == tappedHudTroop.troop.name,
      );
      deployedSprites.remove(spriteToDelete);
      spriteToDelete.removeFromParent();
      return;
    }
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
