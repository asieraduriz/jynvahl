import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class BottomHudButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultLabel = TextComponent(text: 'Start');

    defaultSkin =
        RoundedRectComponent()..setColor(const Color.fromRGBO(0, 200, 0, 1));
    disabledSkin =
        RoundedRectComponent()
          ..setColor(const Color.fromRGBO(100, 100, 100, 1));

    hoverSkin =
        RoundedRectComponent()..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin =
        RoundedRectComponent()..setColor(const Color.fromRGBO(0, 100, 0, 1));
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    print("Button clicked ${isDisabled}");
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}
