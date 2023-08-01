import 'dart:ui';

import 'package:flutter/material.dart';

class NetworkOverlay {
  late OverlayEntry view;
  bool isVisible = false;

  void hide() {
    view.remove();
    isVisible = false;
  }

  show(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    view = OverlayEntry(
      builder: (BuildContext context) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              child: Container(
                child: Image.asset(
                  "assets/follow.png",
                  scale: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(view);
    isVisible = true;
  }
}
