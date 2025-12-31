# assistant_side_bar

[![Pub Version](https://img.shields.io/pub/v/assistant_side_bar)](https://pub.dev/packages/assistant_side_bar)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-blue)](https://flutter.dev)

A Flutter package for creating a draggable overlay sidebar widget that can be expanded, collapsed to edges, and dismissed to a target widget with smooth animations.

## Features

- **Draggable Positioning** - Drag the sidebar horizontally to collapse to screen edges or vertically to reposition
- **Expand/Collapse Animation** - Smooth animated transitions between expanded and collapsed states
- **Edge Anchoring** - Anchor the sidebar to the left or right edge of the screen
- **Dismiss Animation** - Animate the sidebar to a target widget (e.g., FAB) when dismissing
- **Attention State** - Visual indicator to draw user attention with a pulsing animation
- **Customizable Builders** - Provide custom widgets for expanded, collapsed, and attention states
- **Gesture Support** - Fling gestures, tap-to-expand, and drag thresholds
- **Theming** - Customizable colors, border radius, and shadows that integrate with Material 3

## Screenshots

<!-- Add your screenshots or GIFs here -->
| Collapsed | Expanded | Attention |
|-----------|----------|-----------|
| ![Collapsed](screenshots/collapsed.gif) | ![Expanded](screenshots/expanded.gif) | ![Attention](screenshots/attention.gif) |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  assistant_side_bar: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:assistant_side_bar/assistant_side_bar.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final OverlaySidebarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OverlaySidebarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main content
          Center(child: Text('Main Content')),

          // The overlay sidebar
          OverlaySidebar(
            controller: _controller,
            expandedBuilder: (context, controller) => Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Sidebar Content'),
                  ElevatedButton(
                    onPressed: () => controller.collapse(),
                    child: Text('Collapse'),
                  ),
                ],
              ),
            ),
            expandedWidth: 300,
            expandedHeight: 400,
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### OverlaySidebar

The main widget that renders the draggable overlay sidebar.

#### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `OverlaySidebarController` | Controller for managing sidebar state |
| `expandedBuilder` | `SidebarWidgetBuilder` | Builder function for the expanded sidebar content |

#### Size & Position Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `expandedWidth` | `double` | `300` | Width of the sidebar when expanded |
| `expandedHeight` | `double` | `400` | Height of the sidebar when expanded |
| `collapsedWidth` | `double` | `24` | Width of the handle when collapsed |
| `collapsedHeight` | `double` | `80` | Height of the handle when collapsed |
| `initialEdge` | `SidebarEdge` | `SidebarEdge.right` | Initial edge to anchor the sidebar |
| `initialVerticalPosition` | `double?` | `null` | Initial vertical position (centered if null) |
| `edgePadding` | `double` | `0` | Padding from the edge when expanded |

#### Animation Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `expandCollapseDuration` | `Duration` | `450ms` | Duration of expand/collapse animation |
| `dismissDuration` | `Duration` | `400ms` | Duration of dismiss animation |
| `expandCollapseCurve` | `Curve` | `Curves.easeOutCubic` | Curve for expand/collapse animations |
| `dismissCurve` | `Curve` | `Curves.easeInOutCubic` | Curve for dismiss animation |

#### Drag Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDrag` | `bool` | `true` | Whether dragging is enabled |
| `dragExpandThreshold` | `double` | `60.0` | Horizontal drag distance to trigger expand |
| `dragCollapseThresholdRatio` | `double` | `0.3` | Ratio of width to trigger collapse |
| `flingVelocityThreshold` | `double` | `300.0` | Velocity threshold for fling gestures (px/s) |

#### Builder Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `collapsedBuilder` | `SidebarWidgetBuilder?` | Custom builder for collapsed handle (uses default `SidebarHandle` if null) |
| `attentionBuilder` | `SidebarWidgetBuilder?` | Custom builder for attention state handle |
| `dismissTargetKey` | `GlobalKey?` | GlobalKey of widget to animate towards when dismissing |

#### Styling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `backgroundColor` | `Color?` | Theme surface color | Background color for expanded sidebar |
| `borderRadius` | `BorderRadius?` | `BorderRadius.circular(12)` | Border radius for expanded sidebar |
| `boxShadow` | `List<BoxShadow>?` | Default shadow | Box shadow for expanded sidebar |

---

### OverlaySidebarController

Controller for managing the state of an `OverlaySidebar`. Extends `ChangeNotifier` for reactive updates.

#### Constructor

```dart
OverlaySidebarController({
  SidebarState initialState = SidebarState.collapsed,
  SidebarEdge initialEdge = SidebarEdge.right,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `state` | `SidebarState` | Current state of the sidebar |
| `currentEdge` | `SidebarEdge` | Current edge the sidebar is anchored to |
| `isVisible` | `bool` | Whether sidebar is visible (not dismissed/dismissing) |
| `isExpanded` | `bool` | Whether sidebar is in expanded state |
| `isCollapsed` | `bool` | Whether sidebar is collapsed (includes attention state) |

#### Methods

| Method | Description |
|--------|-------------|
| `expand()` | Expands the sidebar to its full width |
| `collapse()` | Collapses the sidebar to the current edge |
| `requestAttention()` | Sets sidebar to collapsed attention state with visual indicator |
| `clearAttention()` | Clears attention state, returns to normal collapsed |
| `dismiss()` | Starts dismiss animation towards target |
| `show()` | Shows sidebar after it has been dismissed |
| `setEdge(SidebarEdge edge)` | Updates the edge the sidebar is anchored to |
| `dispose()` | Disposes the controller (call in widget's dispose) |

---

### SidebarState

Enum representing the current state of the overlay sidebar.

| Value | Description |
|-------|-------------|
| `expanded` | Sidebar is fully visible and expanded |
| `collapsed` | Sidebar is collapsed to edge with only handle visible |
| `collapsedAttention` | Sidebar is collapsed but showing attention indicator |
| `dismissing` | Sidebar is animating towards dismiss target |
| `dismissed` | Sidebar is completely hidden after dismissal |

---

### SidebarEdge

Enum representing which edge the sidebar is anchored to.

| Value | Description |
|-------|-------------|
| `left` | Sidebar anchored to the left edge |
| `right` | Sidebar anchored to the right edge |

---

### SidebarHandle

Default handle widget displayed when the sidebar is collapsed.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `edge` | `SidebarEdge` | **required** | The edge the handle is on |
| `onTap` | `VoidCallback?` | `null` | Called when handle is tapped |
| `showAttention` | `bool` | `false` | Whether to show attention indicator |
| `width` | `double` | `24` | Width of the handle |
| `height` | `double` | `80` | Height of the handle |
| `backgroundColor` | `Color?` | Theme color | Background color of handle |
| `indicatorColor` | `Color?` | Theme color | Color of drag indicator lines |

## Customization

### Custom Expanded Content

```dart
OverlaySidebar(
  controller: _controller,
  expandedBuilder: (context, controller) => Column(
    children: [
      // Header
      Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.chat),
            SizedBox(width: 8),
            Text('Chat Assistant'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => controller.dismiss(),
            ),
          ],
        ),
      ),
      // Content
      Expanded(
        child: ListView(
          children: [/* Your content */],
        ),
      ),
    ],
  ),
  expandedWidth: 320,
  expandedHeight: 500,
)
```

### Custom Collapsed Handle

```dart
OverlaySidebar(
  controller: _controller,
  expandedBuilder: (context, controller) => MyContent(),
  collapsedBuilder: (context, controller) => Container(
    width: 40,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.chevron_left, color: Colors.white),
  ),
  collapsedWidth: 40,
  collapsedHeight: 100,
)
```

### Custom Attention Indicator

```dart
OverlaySidebar(
  controller: _controller,
  expandedBuilder: (context, controller) => MyContent(),
  attentionBuilder: (context, controller) => Container(
    width: 50,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Icon(Icons.notification_important, color: Colors.white),
  ),
)
```

### Custom Styling

```dart
OverlaySidebar(
  controller: _controller,
  expandedBuilder: (context, controller) => MyContent(),
  backgroundColor: Colors.grey[900],
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ],
)
```

### Dismiss to Target Widget

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _controller = OverlaySidebarController();
  final _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content...
          OverlaySidebar(
            controller: _controller,
            expandedBuilder: (context, controller) => MyContent(),
            dismissTargetKey: _fabKey, // Animate towards FAB when dismissing
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () => _controller.show(),
        child: Icon(Icons.chat),
      ),
    );
  }
}
```

## Callbacks

All callback options for monitoring sidebar events:

```dart
OverlaySidebar(
  controller: _controller,
  expandedBuilder: (context, controller) => MyContent(),

  // Called when sidebar state changes
  onStateChanged: (SidebarState state) {
    print('State changed to: $state');
    // Handle state: expanded, collapsed, collapsedAttention, dismissing, dismissed
  },

  // Called when sidebar edge changes
  onEdgeChanged: (SidebarEdge edge) {
    print('Edge changed to: $edge');
    // Handle edge: left, right
  },

  // Called when dismiss animation completes
  onDismissed: () {
    print('Sidebar was dismissed');
    // Perform cleanup or show snackbar
  },

  // Called when drag gesture starts
  onDragStart: (DragStartDetails details) {
    print('Drag started at: ${details.globalPosition}');
  },

  // Called during drag updates
  onDragUpdate: (DragUpdateDetails details) {
    print('Drag delta: ${details.delta}');
  },

  // Called when drag gesture ends
  onDragEnd: (DragEndDetails details) {
    print('Drag velocity: ${details.velocity}');
  },
)
```

## Platform Support

| Platform | Support |
|----------|---------|
| Android | Fully supported |
| iOS | Fully supported |
| Web | Fully supported |
| macOS | Fully supported |
| Windows | Fully supported |
| Linux | Fully supported |

## Requirements

- Flutter >= 3.10.0
- Dart SDK >= 3.0.0

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/your-username/assistant_side_bar.git

# Navigate to the package directory
cd assistant_side_bar

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run the example app
cd example
flutter run
```

### Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for linting.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
