import 'package:flutter/widgets.dart';

/// Animation constants and utilities for the overlay sidebar.
abstract class SidebarAnimations {
  /// Duration for expand/collapse animations.
  static const Duration expandCollapseDuration = Duration(milliseconds: 450);

  /// Duration for dismiss animation.
  static const Duration dismissDuration = Duration(milliseconds: 400);

  /// Curve for expand/collapse animations.
  static const Curve expandCollapseCurve = Curves.easeOutCubic;

  /// Curve for dismiss animation.
  static const Curve dismissCurve = Curves.easeInOutCubic;

  /// Threshold percentage of width to trigger collapse when dragging.
  static const double collapseThreshold = 0.5;

  /// Gets the position and size of a widget from its GlobalKey.
  ///
  /// Returns null if the key doesn't have a valid render object.
  static Rect? getWidgetRect(GlobalKey? key) {
    if (key == null) return null;

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Calculates the center point of a widget from its GlobalKey.
  static Offset? getWidgetCenter(GlobalKey? key) {
    final rect = getWidgetRect(key);
    return rect?.center;
  }
}
