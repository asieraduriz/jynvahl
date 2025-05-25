import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:jynvahl_hex_game/battleground/bottom_hud.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/battleground/manager.dart';
import 'package:jynvahl_hex_game/battleground/top_hud.dart';
import 'package:jynvahl_hex_game/map/hex.dart';
import 'package:jynvahl_hex_game/map/map.dart';
// import 'package:jynvahl_hex_game/map/pathfinding.dart';
import 'package:jynvahl_hex_game/map/tile.dart';
import 'package:jynvahl_hex_game/players/player.dart';
import 'package:jynvahl_hex_game/players/troop.dart';

final int numRows = 7;
final int numCols = 8;

class Battleground extends PositionComponent
    with TapCallbacks, HasGameReference<JynvahlGame> {
  final String mapId;

  late Map<Hex, HexagonTile> _hexMap = {};
  final Player player;
  final Map<Hex, Troop?> playerLineup = {};
  final List<PlayingTroop> deployedSprites = [];

  final Map<Hex, Troop> _opponentLineup = {};

  late final TopHud topHud;
  late final BottomHud bottomHud;

  late BattlegroundManager battlegroundManager;

  Battleground({
    required this.mapId,
    required this.player,
    required Vector2 size,
  }) : super(size: size) {
    this.battlegroundManager = BattlegroundManager(mapId: mapId)
      ..battleState = BattleState.placing;

    _opponentLineup.addAll({
      Hex(5, 2): Troop(
        id: -1,
        name: "Frost Troll Warrior",
        spritePath: 'unit_infantry_orange.png',
      ),
      Hex(6, 1): Troop(
        id: -2,
        name: "Frost Troll Archer",
        spritePath: 'unit_infantry_orange.png',
      ),
      Hex(6, 2): Troop(
        id: -3,
        name: "Frost Troll Shaman",
        spritePath: 'unit_infantry_orange.png',
      ),
      Hex(7, -1): Troop(
        id: -4,
        name: "Frost Troll Berserker",
        spritePath: 'unit_infantry_orange.png',
      ),
    });
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
    loadOpponentLineup();

    loadTopHUD();
    loadBottomHUD();
  }

  void loadOpponentLineup() {
    _opponentLineup.entries.forEach((troopEntry) {
      final hex = troopEntry.key, troop = troopEntry.value;
      final playingTroop = PlayingTroop(
        position: _hexMap[hex]!.position,
        name: troop.name,
        id: troop.id,
        spritePath: troop.spritePath,
      );

      add(playingTroop);
    });
  }

  void loadTopHUD() {
    topHud = TopHud(
      size: Vector2(game.size.x, 100),
      playerLineup: player.troops,
    );

    add(topHud);
  }

  void loadBottomHUD() {
    bottomHud = BottomHud(
      size: Vector2.all(400),
      opponentLineup: _opponentLineup.values.toList(),
    );

    add(bottomHud);
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
            topHud.undeployTroop(deployedTroop);

            // Remove deployed troop from bottom HUD
            bottomHud.removeDeployedTroop(deployedTroop);
            // Remove deployed sprite
            children
                .whereType<PlayingTroop>()
                .firstWhere(
                  (playingTroop) => playingTroop.id == deployedTroop.id,
                )
                .removeFromParent();

            return;
          }

          if (playerLineup[hex] == null) {
            print(
              "Selected troop id ${topHud.selectedTroop!.id} ${topHud.selectedTroop!.spritePath}",
            );
            // Check if there's a selected troop
            if (topHud.selectedTroop == null) {
              print("No troop selected to be deployed");
              return;
            }

            playerLineup[hex] = topHud.selectedTroop;
            print("Added troop ${playerLineup[hex]!.id}");
            topHud.deploySelectedTroop();

            // Paint deployed troop on hex
            final deployedTroop = PlayingTroop(
              position: tile.position,
              name: topHud.selectedTroop!.name,
              id: topHud.selectedTroop!.id,
              spritePath: topHud.selectedTroop!.spritePath,
            );
            add(deployedTroop);

            // Paint deployed troop on bottom HUD
            bottomHud.addDeployedTroop(topHud.selectedTroop!);

            // Select next troop in top HUD
            topHud.selectNextTroop();
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
