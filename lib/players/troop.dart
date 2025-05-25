import 'dart:async';

import 'package:flame/components.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

class Troop {
  int id;
  String name;
  String spritePath;

  Troop({required this.id, required this.name, required this.spritePath});
}

class PlayingTroop extends SpriteComponent with HasGameReference<JynvahlGame> {
  int id;
  String name;
  String spritePath;
  PlayingTroop({
    required Vector2 position,
    required this.name,
    required this.id,
    required this.spritePath,
  }) : super(size: Vector2.all(60), anchor: Anchor.center, position: position);

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await game.images.load(spritePath);
    sprite = Sprite(spriteImage);
  }

  moveTo(Vector2 targetPosition) {
    position = targetPosition;
  }
}
