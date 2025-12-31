/// A Flutter package for creating a draggable overlay sidebar widget.
///
/// This package provides an overlay sidebar that can be:
/// - Dragged horizontally to collapse to an edge
/// - Dragged vertically to reposition
/// - Expanded by tapping the handle
/// - Dismissed with an animation to a target widget
/// - Set to an attention state to draw user focus
///
/// ## Usage
///
/// ```dart
/// import 'package:assistant_side_bar/assistant_side_bar.dart';
///
/// // Create a controller
/// final controller = OverlaySidebarController();
///
/// // Use in a Stack
/// Stack(
///   children: [
///     // Your main content
///     Scaffold(...),
///     // The overlay sidebar
///     OverlaySidebar(
///       controller: controller,
///       expandedBuilder: (context, controller) => MyExpandedContent(),
///       expandedWidth: 300,
///       expandedHeight: 400,
///     ),
///   ],
/// )
/// ```
library assistant_side_bar;

export 'src/overlay_sidebar.dart';
export 'src/overlay_sidebar_controller.dart';
export 'src/overlay_sidebar_state.dart';
export 'src/sidebar_handle.dart';
