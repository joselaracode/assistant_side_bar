import 'package:flutter/material.dart';
import 'overlay_sidebar_controller.dart';
import 'overlay_sidebar_state.dart';
import 'sidebar_handle.dart';

/// Builder function for sidebar content.
typedef SidebarWidgetBuilder = Widget Function(
  BuildContext context,
  OverlaySidebarController controller,
);

/// Callback for state changes.
typedef SidebarStateCallback = void Function(SidebarState state);

/// Callback for edge changes.
typedef SidebarEdgeCallback = void Function(SidebarEdge edge);

/// Callback for drag events.
typedef SidebarDragCallback = void Function(DragUpdateDetails details);

/// A draggable overlay sidebar widget that can be expanded, collapsed,
/// and dismissed to a target.
///
/// This widget provides an overlay sidebar that can be:
/// - Dragged horizontally to collapse to an edge
/// - Dragged vertically to reposition
/// - Tapped on the handle to expand
/// - Dismissed with an animation to a target widget
/// - Set to an attention state to draw user focus
///
/// ## Example
///
/// ```dart
/// OverlaySidebar(
///   controller: _controller,
///   expandedBuilder: (context, controller) => MyContent(),
///   expandedWidth: 300,
///   expandedHeight: 400,
///   onStateChanged: (state) => print('State: $state'),
/// )
/// ```
class OverlaySidebar extends StatefulWidget {
  /// Controller for managing sidebar state.
  final OverlaySidebarController controller;

  /// Builder for the expanded sidebar content.
  final SidebarWidgetBuilder expandedBuilder;

  /// Builder for the collapsed handle widget.
  /// If null, a default [SidebarHandle] is used.
  final SidebarWidgetBuilder? collapsedBuilder;

  /// Builder for the collapsed attention handle widget.
  /// If null, a default [SidebarHandle] with attention indicator is used.
  final SidebarWidgetBuilder? attentionBuilder;

  /// GlobalKey of the widget to animate towards when dismissing.
  final GlobalKey? dismissTargetKey;

  /// Width of the sidebar when expanded.
  final double expandedWidth;

  /// Height of the sidebar when expanded.
  final double expandedHeight;

  /// Width of the handle when collapsed.
  final double collapsedWidth;

  /// Height of the handle when collapsed.
  final double collapsedHeight;

  /// Initial edge to anchor the sidebar.
  final SidebarEdge initialEdge;

  /// Whether dragging is enabled.
  final bool enableDrag;

  /// Initial vertical position of the sidebar (distance from top).
  /// If null, the sidebar is centered vertically.
  final double? initialVerticalPosition;

  /// Padding from the edge when expanded.
  final double edgePadding;

  /// Duration of the expand/collapse animation.
  final Duration expandCollapseDuration;

  /// Duration of the dismiss animation.
  final Duration dismissDuration;

  /// Curve for expand/collapse animations.
  final Curve expandCollapseCurve;

  /// Curve for dismiss animation.
  final Curve dismissCurve;

  /// Horizontal drag distance threshold to trigger expand from collapsed state.
  final double dragExpandThreshold;

  /// Horizontal drag distance threshold to trigger collapse/edge switch.
  final double dragCollapseThresholdRatio;

  /// Velocity threshold for fling gestures (pixels per second).
  final double flingVelocityThreshold;

  /// Called when the sidebar state changes.
  final SidebarStateCallback? onStateChanged;

  /// Called when the sidebar edge changes.
  final SidebarEdgeCallback? onEdgeChanged;

  /// Called when the sidebar is dismissed.
  final VoidCallback? onDismissed;

  /// Called when a drag gesture starts.
  final GestureDragStartCallback? onDragStart;

  /// Called during drag updates.
  final SidebarDragCallback? onDragUpdate;

  /// Called when a drag gesture ends.
  final GestureDragEndCallback? onDragEnd;

  /// Background color for the expanded sidebar.
  final Color? backgroundColor;

  /// Border radius for the expanded sidebar.
  final BorderRadius? borderRadius;

  /// Box shadow for the expanded sidebar.
  final List<BoxShadow>? boxShadow;

  /// Creates an overlay sidebar.
  const OverlaySidebar({
    super.key,
    required this.controller,
    required this.expandedBuilder,
    this.collapsedBuilder,
    this.attentionBuilder,
    this.dismissTargetKey,
    this.expandedWidth = 300,
    this.expandedHeight = 400,
    this.collapsedWidth = 24,
    this.collapsedHeight = 80,
    this.initialEdge = SidebarEdge.right,
    this.enableDrag = true,
    this.initialVerticalPosition,
    this.edgePadding = 0,
    this.expandCollapseDuration = const Duration(milliseconds: 450),
    this.dismissDuration = const Duration(milliseconds: 400),
    this.expandCollapseCurve = Curves.easeOutCubic,
    this.dismissCurve = Curves.easeInOutCubic,
    this.dragExpandThreshold = 60.0,
    this.dragCollapseThresholdRatio = 0.3,
    this.flingVelocityThreshold = 300.0,
    this.onStateChanged,
    this.onEdgeChanged,
    this.onDismissed,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  State<OverlaySidebar> createState() => _OverlaySidebarState();
}

class _OverlaySidebarState extends State<OverlaySidebar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _dismissController;
  late Animation<double> _slideAnimation;
  late Animation<double> _dismissScaleAnimation;
  late Animation<double> _dismissOpacityAnimation;

  double _dragOffsetX = 0;
  double _dragOffsetY = 0;
  double _verticalPosition = 0;
  bool _isDragging = false;
  Offset? _dismissTargetPosition;
  double _screenHeight = 0;
  SidebarEdge? _lastEdge;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    if (widget.controller.isExpanded) {
      _slideController.value = 1.0;
    }

    _lastEdge = widget.controller.currentEdge;
    widget.controller.addListener(_onControllerChanged);
    _dismissController.addListener(_onDismissAnimation);
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: widget.expandCollapseDuration,
      vsync: this,
    );

    _dismissController = AnimationController(
      duration: widget.dismissDuration,
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: widget.expandCollapseCurve,
    );

    _dismissScaleAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _dismissController,
        curve: Interval(0.0, 0.8, curve: widget.dismissCurve),
      ),
    );

    _dismissOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(OverlaySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation durations if changed
    if (oldWidget.expandCollapseDuration != widget.expandCollapseDuration) {
      _slideController.duration = widget.expandCollapseDuration;
    }
    if (oldWidget.dismissDuration != widget.dismissDuration) {
      _dismissController.duration = widget.dismissDuration;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _dismissController.removeListener(_onDismissAnimation);
    _slideController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final state = widget.controller.state;
    final edge = widget.controller.currentEdge;

    // Notify edge change
    if (_lastEdge != edge) {
      _lastEdge = edge;
      widget.onEdgeChanged?.call(edge);
    }

    switch (state) {
      case SidebarState.expanded:
        _slideController.forward();
        break;
      case SidebarState.collapsed:
      case SidebarState.collapsedAttention:
        _slideController.reverse();
        break;
      case SidebarState.dismissing:
        _startDismissAnimation();
        break;
      case SidebarState.dismissed:
        break;
    }

    widget.onStateChanged?.call(state);
    setState(() {});
  }

  void _onDismissAnimation() {
    if (_dismissController.isCompleted) {
      widget.controller.completeDismiss();
      widget.onDismissed?.call();
    }
  }

  void _startDismissAnimation() {
    _dismissTargetPosition = _getWidgetCenter(widget.dismissTargetKey);
    _dismissController.forward(from: 0);
  }

  Offset? _getWidgetCenter(GlobalKey? key) {
    if (key == null) return null;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enableDrag) return;
    _isDragging = true;
    _dragOffsetX = 0;
    _dragOffsetY = 0;
    widget.onDragStart?.call(details);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag || !_isDragging) return;

    setState(() {
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;
    });

    widget.onDragUpdate?.call(details);

    // Auto-expand when collapsed and dragged past threshold
    if (widget.controller.isCollapsed) {
      final edge = widget.controller.currentEdge;

      bool shouldExpand = false;
      if (edge == SidebarEdge.right) {
        shouldExpand = _dragOffsetX < -widget.dragExpandThreshold;
      } else {
        shouldExpand = _dragOffsetX > widget.dragExpandThreshold;
      }

      if (shouldExpand) {
        _isDragging = false;
        _dragOffsetX = 0;
        _dragOffsetY = 0;
        widget.controller.expand();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enableDrag || !_isDragging) return;

    _isDragging = false;
    final edge = widget.controller.currentEdge;
    final velocity = details.velocity.pixelsPerSecond;
    final isExpanded = widget.controller.isExpanded;
    final isCollapsed = widget.controller.isCollapsed;

    final distanceThreshold = widget.expandedWidth * widget.dragCollapseThresholdRatio;

    if (isExpanded) {
      bool shouldCollapse = false;
      bool shouldSwitchEdge = false;

      if (edge == SidebarEdge.right) {
        shouldCollapse = velocity.dx > widget.flingVelocityThreshold ||
                        _dragOffsetX > distanceThreshold;
        shouldSwitchEdge = velocity.dx < -widget.flingVelocityThreshold ||
                         _dragOffsetX < -distanceThreshold;

        if (shouldCollapse) {
          widget.controller.collapse();
        } else if (shouldSwitchEdge) {
          widget.controller.setEdge(SidebarEdge.left);
        }
      } else {
        shouldCollapse = velocity.dx < -widget.flingVelocityThreshold ||
                        _dragOffsetX < -distanceThreshold;
        shouldSwitchEdge = velocity.dx > widget.flingVelocityThreshold ||
                         _dragOffsetX > distanceThreshold;

        if (shouldCollapse) {
          widget.controller.collapse();
        } else if (shouldSwitchEdge) {
          widget.controller.setEdge(SidebarEdge.right);
        }
      }
    } else if (isCollapsed) {
      bool shouldExpand = false;

      if (edge == SidebarEdge.right) {
        shouldExpand = velocity.dx < -widget.flingVelocityThreshold ||
                      _dragOffsetX < -widget.dragExpandThreshold;
      } else {
        shouldExpand = velocity.dx > widget.flingVelocityThreshold ||
                      _dragOffsetX > widget.dragExpandThreshold;
      }

      if (shouldExpand) {
        widget.controller.expand();
      }
    }

    // Update vertical position
    if (_dragOffsetY.abs() > 5) {
      final newVerticalPos = _verticalPosition + _dragOffsetY;
      final minY = 20.0;
      final maxY = _screenHeight - widget.expandedHeight - 20;
      _verticalPosition = newVerticalPos.clamp(minY, maxY);
    }

    widget.onDragEnd?.call(details);

    setState(() {
      _dragOffsetX = 0;
      _dragOffsetY = 0;
    });
  }

  void _onHandleTap() {
    if (widget.controller.isCollapsed) {
      widget.controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    if (state == SidebarState.dismissed) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        _screenHeight = constraints.maxHeight;
        final edge = widget.controller.currentEdge;

        // Initialize vertical position if not set
        if (_verticalPosition == 0) {
          _verticalPosition = widget.initialVerticalPosition ??
              (_screenHeight - widget.collapsedHeight) / 2;
        }

        if (state == SidebarState.dismissing) {
          return _buildDismissingWidget(screenWidth, edge);
        }

        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            final slideValue = _slideAnimation.value;

            // Calculate dimensions
            final currentWidth = widget.collapsedWidth +
                (widget.expandedWidth - widget.collapsedWidth) * slideValue;
            final currentHeight = widget.collapsedHeight +
                (widget.expandedHeight - widget.collapsedHeight) * slideValue;

            // Calculate vertical position
            var verticalPos = _verticalPosition;
            if (_isDragging) {
              verticalPos += _dragOffsetY;
            }

            // Clamp to screen bounds
            final maxY = _screenHeight - currentHeight - 20;
            verticalPos = verticalPos.clamp(20.0, maxY);

            // Calculate horizontal position
            double left;
            if (edge == SidebarEdge.right) {
              final expandedLeft = screenWidth - widget.expandedWidth - widget.edgePadding;
              final collapsedLeft = screenWidth - widget.collapsedWidth;
              left = collapsedLeft + (expandedLeft - collapsedLeft) * slideValue;

              if (_isDragging) {
                left += _dragOffsetX;
              }
            } else {
              final expandedLeft = widget.edgePadding;
              final collapsedLeft = 0.0;
              left = collapsedLeft + (expandedLeft - collapsedLeft) * slideValue;

              if (_isDragging) {
                left += _dragOffsetX;
              }
            }

            return Stack(
              children: [
                Positioned(
                  left: left,
                  top: verticalPos,
                  width: currentWidth,
                  height: currentHeight,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTap: slideValue < 0.1 ? _onHandleTap : null,
                    child: _buildContent(state, slideValue),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(SidebarState state, double slideValue) {
    if (slideValue < 0.1) {
      return _buildCollapsedWidget(state);
    }
    return _buildExpandedWidget(slideValue);
  }

  Widget _buildCollapsedWidget(SidebarState state) {
    final edge = widget.controller.currentEdge;
    final showAttention = state == SidebarState.collapsedAttention;

    if (showAttention && widget.attentionBuilder != null) {
      return widget.attentionBuilder!(context, widget.controller);
    }

    if (widget.collapsedBuilder != null) {
      return widget.collapsedBuilder!(context, widget.controller);
    }

    return SidebarHandle(
      edge: edge,
      onTap: _onHandleTap,
      showAttention: showAttention,
      width: widget.collapsedWidth,
      height: widget.collapsedHeight,
    );
  }

  Widget _buildExpandedWidget(double slideValue) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    final shadow = widget.boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ];

    return Opacity(
      opacity: slideValue.clamp(0.0, 1.0),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            boxShadow: shadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: widget.expandedWidth,
            maxWidth: widget.expandedWidth,
            minHeight: widget.expandedHeight,
            maxHeight: widget.expandedHeight,
            child: widget.expandedBuilder(context, widget.controller),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissingWidget(double screenWidth, SidebarEdge edge) {
    double startLeft;
    if (edge == SidebarEdge.right) {
      startLeft = screenWidth - widget.expandedWidth - widget.edgePadding;
    } else {
      startLeft = widget.edgePadding;
    }
    final startTop = (_screenHeight - widget.expandedHeight) / 2;
    final startCenterX = startLeft + widget.expandedWidth / 2;
    final startCenterY = startTop + widget.expandedHeight / 2;

    return AnimatedBuilder(
      animation: _dismissController,
      builder: (context, child) {
        final scale = _dismissScaleAnimation.value;
        final opacity = _dismissOpacityAnimation.value;
        final progress = widget.dismissCurve.transform(_dismissController.value);

        double currentCenterX = startCenterX;
        double currentCenterY = startCenterY;

        if (_dismissTargetPosition != null) {
          currentCenterX = startCenterX +
              (_dismissTargetPosition!.dx - startCenterX) * progress;
          currentCenterY = startCenterY +
              (_dismissTargetPosition!.dy - startCenterY) * progress;
        }

        final currentWidth = widget.expandedWidth * scale;
        final currentHeight = widget.expandedHeight * scale;
        final left = currentCenterX - currentWidth / 2;
        final top = currentCenterY - currentHeight / 2;

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: currentWidth,
              height: currentHeight,
              child: Opacity(
                opacity: opacity,
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ??
                             Theme.of(context).colorScheme.surface,
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                      boxShadow: widget.boxShadow ??
                          [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: widget.expandedWidth,
                      maxWidth: widget.expandedWidth,
                      minHeight: widget.expandedHeight,
                      maxHeight: widget.expandedHeight,
                      child: widget.expandedBuilder(context, widget.controller),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
