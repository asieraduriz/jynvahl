import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/players/troop.dart';

class BottomHud extends PositionComponent with HasGameReference<JynvahlGame> {
  List<PositionComponent> playerLineup = [];
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
      final component = PositionComponent(
        size: Vector2(50, 50),
        position: Vector2(size.x / 2 + (i + 1) * 60, size.y / 2),
        anchor: Anchor.center,
        children: [
          SpriteComponent(
            sprite: await game.loadSprite('unit_infantry_germany.png'),
            size: Vector2(50, 50),
          ),
        ],
      );
      add(component);
      playerLineup.add(component);
    }
  }

  addDeployedTroop(PositionComponent component) {
    playerLineup.add(component);
    component.position = Vector2(
      size.x / 2 + (playerLineup.length - 1) * 60,
      size.y / 2,
    );
    add(component);
  }

  removeDeployedTroop(PositionComponent component) {
    playerLineup.remove(component);
    component.removeFromParent();
  }
}
