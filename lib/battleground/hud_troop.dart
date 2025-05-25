import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';
import 'package:jynvahl_hex_game/players/troop.dart';

enum TroopState { idle, selected, deployed }

class HudTroop extends PositionComponent
    with TapCallbacks, HasGameReference<JynvahlGame> {
  final int index;
  final Troop troop;
  late TroopState state;

  HudTroop({
    required this.troop,
    required Vector2 position,
    required Vector2 size,
    required this.index,
    required this.state,
  }) : super(position: position, size: size);

  late RectangleComponent backgroundRectange;
  late SpriteComponent troopPortrait;

  @override
  Future<void> onLoad() async {
    debugMode = true;

    backgroundRectange = RectangleComponent(size: size);
    setBackground();
    add(backgroundRectange);

    final image = await game.loadSprite('unit_infantry_germany.png');
    troopPortrait = SpriteComponent(sprite: image, size: size);
    if (state == TroopState.idle) {
      troopPortrait.flipHorizontallyAroundCenter();
    }
    add(troopPortrait);
  }

  void setBackground() {
    switch (state) {
      case TroopState.idle:
        backgroundRectange.paint.color = Colors.grey;
        break;
      case TroopState.selected:
        backgroundRectange.paint.color = Colors.white;
        break;
      case TroopState.deployed:
        backgroundRectange.paint.color = Colors.transparent;
        break;
    }
  }

  @override
  void update(double dt) {
    setBackground();
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.battleground.onHudTroopTapped(this);
  }
}
