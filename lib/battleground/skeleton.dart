import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:jynvahl_hex_game/battleground/game.dart';

final double hexRadius = 50.0;
final int numRows = 7;
final int numCols = 8;

class Skeleton extends PositionComponent
    with TapCallbacks, HasGameReference<JynvahlGame> {
  Skeleton()
    : super(priority: 10, size: Vector2(500, 300), position: Vector2(200, 150));
  @override
  Future<void> onLoad() async {
    debugMode = true;
    final sprite = await game.loadSprite('water.png');
    add(
      SpriteComponent(
        sprite: sprite,
        position: Vector2(200, 150),
        size: Vector2.all(200),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.router.pushNamed('home');
    print('Tapped at ${event.localPosition}');
  }
}
