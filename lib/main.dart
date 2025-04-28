import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart' hide Text;

void main() {
  // Create an instance of your game
  final hexMapGame = HexMapGame();

  // Run the app with the GameWidget and overlay UI
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // The Flame game widget
            GameWidget(
              game: hexMapGame,
              loadingBuilder: (BuildContext context) {
                // Show a loading indicator while the game is loading
                return const Center(child: CircularProgressIndicator());
              },
              // You can optionally add overlays here using overlayBuilderMap
              // or use a Stack as we are doing for more complex UI layers
            ),
            // Overlay for static buttons in the top right corner
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Add some padding
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Column should take minimum space
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align buttons to the right
                  children: [
                    // Zoom In Button
                    ElevatedButton(
                      onPressed: () {
                        // Call the zoom in method in the game instance
                        hexMapGame.zoomInButton();
                      },
                      child: const Text('Zoom In'),
                    ),
                    const SizedBox(height: 8.0), // Space between buttons
                    // Zoom Out Button
                    ElevatedButton(
                      onPressed: () {
                        // Call the zoom out method in the game instance
                        hexMapGame.zoomOutButton();
                      },
                      child: const Text('Zoom Out'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Main Flame Game class
class HexMapGame extends FlameGame
    with DragCallbacks, ScrollDetector, ScaleDetector, PanDetector {
  // Define the path to your TMX file within the assets folder
  static const String mapFileName = 'bg-1.tmx';

  // Override the background color
  @override
  Color backgroundColor() => Colors.white60; // Using white60 as in your code

  late TiledComponent mapComponent;

  // Variables for zoom handling
  late double startZoom;
  final double minZoom = 0.1; // Minimum zoom level
  final double maxZoom = 4.0; // Maximum zoom level

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = true; // Enable debug mode if helpful

    // Define the desired render size for each tile.
    // This usually matches the tilewidth/tileheight from your Tiled map.
    final Vector2 tileRenderSize = Vector2(
      72.0,
      72.0,
    ); // Adjust if your tile size is different

    // Load the Tiled map component
    mapComponent = await TiledComponent.load(
      mapFileName, // The filename relative to asset paths in pubspec.yaml
      tileRenderSize, // The size each tile should be rendered at
      prefix: 'assets/tiled/', // The folder within assets where your map is
    );

    // Add the map component to the world
    world.add(mapComponent);

    // --- Camera Setup ---
    // Use the default camera which adapts to the screen size.
    // Assign the world to the default camera.
    camera.world = world;

    // Center the camera on the map after it's loaded and sized.
    if (mapComponent.isLoaded) {
      // Center the camera's viewfinder on the middle of the map's size
      camera.viewfinder.position = mapComponent.size / 2;

      // Optional: Adjust initial zoom to fit the map on screen if needed
      // This part can be complex depending on desired initial view,
      // map size, and screen size. A simple approach is to start at zoom 1.0
      // or calculate a zoom level to fit the smaller dimension of the map.
      // Example: Fit the smaller dimension of the map within the viewport
      // final viewportSize = camera.viewport.effectiveViewport.size;
      // final mapSize = mapComponent.size;
      // double zoomX = viewportSize.x / mapSize.x;
      // double zoomY = viewportSize.y / mapSize.y;
      // camera.viewfinder.zoom = min(zoomX, zoomY) * 0.9; // Use the smaller zoom, add padding
    }

    // You can also set world bounds to prevent the camera from panning outside the map
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, mapComponent.size.x, mapComponent.size.y),
    );

    // Note: With PanDetector and ScaleDetector, you might handle both
    // pan and zoom within onScaleUpdate as scale is a superset of pan.
    // However, keeping onDragUpdate for clarity of separate pan handling is also possible,
    // but be mindful of potential gesture conflicts if not handled carefully.
  }

  // --- Gesture Handling ---

  // Pan (Drag) Handling
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Move the camera's viewfinder position by the screen delta,
    // scaled by the inverse of the current zoom level.
    // We negate the delta because dragging the screen left should move
    // the camera view left (towards higher world x coordinates).
    camera.viewfinder.position -= event.canvasDelta / camera.viewfinder.zoom;

    // If using camera.setBounds, the camera position will be automatically clamped.
    // If not using setBounds, you would manually clamp the position here.
    // clampCameraPosition(); // If you had a custom clamp method
  }

  // Zoom (Pinch) Handling
  @override
  void onScaleStart(ScaleStartInfo info) {
    // Store the zoom level when the scale gesture begins
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Get the overall scale factor relative to the start of the gesture
    final currentScale = info.scale.global;

    // If the scale is not identity (meaning it's a pinch gesture)
    if (!currentScale.isIdentity()) {
      // Calculate the new zoom level based on the starting zoom and the scale factor
      // Using currentScale.y (or .x) as scaling is usually uniform
      double newZoom = startZoom * currentScale.y;

      // Clamp the new zoom level within your defined min/max bounds
      newZoom = newZoom.clamp(minZoom, maxZoom);

      // Apply the new zoom level to the camera's viewfinder
      camera.viewfinder.zoom = newZoom;

      // Optional: Adjust camera position to zoom around the focal point
      // This is more complex and requires converting screen coordinates to world coordinates
      // and adjusting the camera position to keep the world point under the focal point.
      // For simplicity, this example zooms around the camera's current focus point.
    } else {
      // If the scale is identity, it's likely a pan gesture.
      // If you are not using onDragUpdate, you would handle pan here.
      // However, since we have onDragUpdate, it handles the pan.
    }
  }

  // --- Button Actions ---
  // Methods to be called by the Flutter UI buttons

  void zoomInButton() {
    print("Zoom In button pressed");
    // Increase zoom level
    camera.viewfinder.zoom = (camera.viewfinder.zoom * 1.2).clamp(
      minZoom,
      maxZoom,
    );
  }

  void zoomOutButton() {
    print("Zoom Out button pressed");
    // Decrease zoom level
    camera.viewfinder.zoom = (camera.viewfinder.zoom / 1.2).clamp(
      minZoom,
      maxZoom,
    );
  }

  // You can add other game logic, components, update methods, etc. below this.
}
