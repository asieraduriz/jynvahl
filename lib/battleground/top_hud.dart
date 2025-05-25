import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/battleground/hud_troop.dart';
import 'package:jynvahl_hex_game/players/troop.dart';

class TopHud extends PositionComponent with HasGameReference<JynvahlGame> {
  List<Troop> playerLineup = [];

  Troop? selectedTroop;

  TopHud({required Vector2 size, required this.playerLineup})
    : super(size: size, priority: 10, position: Vector2.zero());

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;

    for (int i = 0; i < playerLineup.length; i++) {
      final troop = playerLineup[i];
      final hudTroop = HudTroop(
        troop: troop,
        position: Vector2((i + 1) * 70.0, 20),
        size: Vector2.all(48),
        state: i == 0 ? TroopState.selected : TroopState.idle,
        onSelectTroop: selectTroop,
      );
      add(hudTroop);
    }

    selectedTroop = playerLineup[0];
    print("Selected troop image ${selectedTroop!.spritePath}");
  }

  void selectTroop(int id) {
    final hudTroop = children.toList().whereType<HudTroop>().firstWhere(
      (hudTroop) => hudTroop.troop.id == id,
    );

    if (hudTroop.state == TroopState.deployed) return;

    // Deselect all non-deployed troops
    children.toList().whereType<HudTroop>().forEach((hudTroop) {
      if (hudTroop.state == TroopState.deployed) return;
      hudTroop.setState(TroopState.idle);
    });

    // Mark selected troop as selected
    hudTroop.setState(TroopState.selected);
    selectedTroop = hudTroop.troop;
  }

  void deploySelectedTroop() {
    if (selectedTroop == null) {
      print("No troop selected to be deployed");
      return;
    }

    print("Deploying selected troop $selectedTroop");
    final hudTroop = children.toList().whereType<HudTroop>().firstWhere(
      (hudTroop) => hudTroop.troop.id == selectedTroop!.id,
    );

    hudTroop.setState(TroopState.deployed);
  }

  void selectNextTroop() {
    // Find first idle troop
    final nextIdleHudTroop = children
        .toList()
        .whereType<HudTroop>()
        .firstWhereOrNull((hudTroop) => hudTroop.state == TroopState.idle);

    if (nextIdleHudTroop == null) {
      print("No next idle troop found");
      selectedTroop = null;
      return;
    }

    nextIdleHudTroop.setState(TroopState.selected);
    final nextIdleTroop = playerLineup.firstWhere(
      (troop) => troop.id == nextIdleHudTroop.troop.id,
    );

    selectedTroop = nextIdleTroop;
  }

  void undeployTroop(Troop troop) {
    children
        .whereType<HudTroop>()
        .firstWhere((hudTroop) => hudTroop.troop.id == troop.id)
        .setState(TroopState.idle);

    // Set itself as selected it there is no other troop to be selected
    // If not, keep with the other selected troop
    if (selectedTroop == null) {
      selectNextTroop();
    }
  }
}
