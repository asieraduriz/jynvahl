import 'dart:async';

import 'package:flame/components.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

class Troop {
  int id;
  String name;

  Troop({required this.id, required this.name});
}

class PlayingTroop extends SpriteComponent with HasGameReference<JynvahlGame> {
  String name;
  PlayingTroop({required Vector2 position, required this.name})
    : super(size: Vector2.all(60), anchor: Anchor.center, position: position);

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await game.images.load('unit_infantry_germany.png');
    sprite = Sprite(spriteImage);
  }

  moveTo(Vector2 targetPosition) {
    position = targetPosition;
  }
}
