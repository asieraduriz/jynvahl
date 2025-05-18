import 'dart:async';

import 'package:flame/components.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

class Character extends SpriteComponent with HasGameReference<Battleground> {
  Character()
    : super(
        size: Vector2.all(50),
        anchor: Anchor.center,
        position: Vector2(68, 50),
      );

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await game.images.load('unit_infantry_germany.png');
    print("Sprite $spriteImage");
    sprite = Sprite(spriteImage);
  }

  moveTo(Vector2 targetPosition) {
    position = targetPosition;
  }
}
