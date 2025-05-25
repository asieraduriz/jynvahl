import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/players/troop.dart';

class BottomHud extends PositionComponent with HasGameReference<JynvahlGame> {
  List<Troop> playerLineup = [];
  final List<Troop> opponentLineup;

  BottomHud({required Vector2 size, required this.opponentLineup})
    : super(size: size, anchor: Anchor.bottomCenter, priority: 10);

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;
    size = Vector2(game.size.x, 200);
    position = Vector2(game.size.x / 2, game.size.y);

    final textComponent = TextComponent(
      text: "Start",
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(textComponent);

    // Add opponent lineup
    for (var i = 0; i < opponentLineup.length; i++) {
      final troop = opponentLineup[i];
      final component = PlayingTroop(
        position: Vector2(size.x / 2 + (i + 1) * 70, size.y / 2),
        name: troop.name,
        id: troop.id,
        spritePath: troop.spritePath,
      );

      add(component);
    }
  }

  addDeployedTroop(Troop troop) {
    playerLineup.add(troop);
    print("Added troop, total is ${playerLineup.length}");
    final playingTroop = PlayingTroop(
      position: Vector2(size.x / 2 - (playerLineup.length) * 70, size.y / 2),
      name: troop.name,
      id: troop.id,
      spritePath: troop.spritePath,
    );

    add(playingTroop);
  }

  removeDeployedTroop(Troop troop) {
    // Remove all player troops from HUD
    print("Player lineup: ${playerLineup.map((e) => e.id).join(', ')}");
    children.whereType<PlayingTroop>().forEach((troopComponent) {
      final isPlayerTroop = playerLineup.any(
        (troopEntry) => troopEntry.id == troopComponent.id,
      );

      if (isPlayerTroop) {
        troopComponent.removeFromParent();
      }
    });

    // Remove troop from player lineup
    playerLineup.removeWhere((entry) => entry.id == troop.id);

    // Add remaining troops to HUD
    playerLineup.forEachIndexed((index, remainingTroop) {
      final playingTroop = PlayingTroop(
        position: Vector2(size.x / 2 - (index + 1) * 70, size.y / 2),
        name: remainingTroop.name,
        id: remainingTroop.id,
        spritePath: remainingTroop.spritePath,
      );
      add(playingTroop);
    });
  }
}
