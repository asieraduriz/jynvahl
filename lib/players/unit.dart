import 'dart:async';

import 'package:flame/components.dart';
import 'package:jynvahl_hex_game/battleground/battleground.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

class Unit {
  int id;
  String name;

  Unit({required this.id, required this.name});
}

class PlayingUnit extends SpriteComponent with HasGameReference<JynvahlGame> {
  String name;
  PlayingUnit({required Vector2 position, required this.name})
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
