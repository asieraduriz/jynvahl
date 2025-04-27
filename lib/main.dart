import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart'; // Import flame_tiled
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: HexMapGame(),
      loadingBuilder: (BuildContext context) {
        return CircularProgressIndicator();
      },
    ),
  );
}

class HexMapGame extends FlameGame
    with DragCallbacks, ScrollDetector, ScaleDetector, PanDetector {
  // Define the path to your TMX file within the assets folder
  // Adjust the path based on your assets structure in pubspec.yaml
  static const String mapFileName = 'bg-1.tmx';
  // If your map is in assets/maps/, and 'assets/maps/' is in pubspec.yaml,
  // the path flame_tiled needs is just 'hex_map.tmx'.
  // If only 'assets/' is listed, you might need 'maps/hex_map.tmx'.

  @override
  Color backgroundColor() => Colors.white60;

  late World _world;
  late CameraComponent _camera;
  late TiledComponent mapComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    super.debugMode = true;

    // Define the desired render size for each tile.
    // This usually matches the tilewidth/tileheight from your Tiled map.
    final Vector2 tileRenderSize = Vector2(72.0, 72.0);

    // Load the Tiled map
    mapComponent = await TiledComponent.load(
      mapFileName, // The filename relative to asset paths in pubspec.yaml
      tileRenderSize, // The size each tile should be rendered at
      prefix: 'assets/tiled/',
    );

    _world = World(children: [mapComponent]);

    await add(_world);

    _camera = CameraComponent.withFixedResolution(
      width: 300,
      height: 200,
      world: _world,
    );
    await add(_camera);

    _camera.moveTo(mapComponent.size * 0.5);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final Vector2 screenDelta = event.canvasDelta;

    if (_camera.viewfinder.zoom > 0) {
      // Convert screen delta to world delta by scaling with zoom
      final worldDelta = screenDelta / _camera.viewfinder.zoom;

      // Move the _camera
      _camera.viewfinder.position -= worldDelta;
    }

    super.onDragUpdate(event);
  }

  double clampZoom(double delta) {
    return delta.clamp(1, 3.0);
  }

  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = _camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    _camera.viewfinder.zoom = 3;
  }
}
