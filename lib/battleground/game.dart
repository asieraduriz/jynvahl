import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:jynvahl_hex_game/battleground/battleground.dart';
import 'package:jynvahl_hex_game/battleground/skeleton.dart';
import 'package:jynvahl_hex_game/players/player.dart';

class JynvahlGame extends FlameGame with TapCallbacks {
  late final RouterComponent router;

  final String mapId;
  final Player player;

  late final Battleground battleground;

  JynvahlGame({required this.mapId, required this.player}) {}

  @override
  Future<void> onLoad() async {
    battleground = Battleground(mapId: mapId, player: player);
    add(
      router = RouterComponent(
        routes: {
          'home': Route(() => battleground),
          'battle': Route(Skeleton.new),
        },
        initialRoute: 'battle',
      ),
    );
  }
}
