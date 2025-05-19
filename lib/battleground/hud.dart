import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

class Hud extends PositionComponent with HasGameReference<Battleground> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late TextComponent _scoreTextComponent;

  @override
  Future<void> onLoad() async {
    _scoreTextComponent = TextComponent(
      text: 'Text goes here',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32, color: Colors.white),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 60, 20),
    );
    add(_scoreTextComponent);

    // final starSprite = await game.loadSprite('star.png');
    // add(
    //   SpriteComponent(
    //     sprite: starSprite,
    //     position: Vector2(game.size.x - 100, 20),
    //     size: Vector2.all(32),
    //     anchor: Anchor.center,
    //   ),
    // );
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
