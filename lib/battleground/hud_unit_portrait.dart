import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

enum UnitPortraitState { idle, selected, deployed }

class HudUnitPortrait extends SpriteGroupComponent<UnitPortraitState>
    with HasGameReference<Battleground>, TapCallbacks {
  final int index;

  HudUnitPortrait({
    required Vector2 position,
    required Vector2 size,
    required this.index,
  }) : super(size: size, anchor: Anchor.center, position: position);

  @override
  FutureOr<void> onLoad() async {
    final idleSprite = await game.loadSprite('unit_infantry_germany.png');
    final spriteRight = await game.loadSprite(
      'unit_infantry_germany_right.png',
    );
    final spriteLeft = await game.loadSprite('unit_infantry_germany_left.png');

    sprites = {
      UnitPortraitState.idle: idleSprite,
      UnitPortraitState.selected: spriteRight,
      UnitPortraitState.deployed: spriteLeft,
    };

    current = UnitPortraitState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("Tapped on unit portrait $index");

    switch (current) {
      case UnitPortraitState.idle:
        current = UnitPortraitState.selected;
        break;
      case UnitPortraitState.selected:
        current = UnitPortraitState.deployed;
        break;
      case UnitPortraitState.deployed:
        current = UnitPortraitState.idle;
        break;
      default:
        break;
    }
    super.onTapUp(event);
  }
}
