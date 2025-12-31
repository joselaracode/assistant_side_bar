import 'package:flutter/material.dart';
import 'overlay_sidebar_state.dart';

/// Default handle widget displayed when the sidebar is collapsed.
///
/// Shows a drag affordance and can be tapped to expand the sidebar.
class SidebarHandle extends StatelessWidget {
  /// The edge the handle is on.
  final SidebarEdge edge;

  /// Called when the handle is tapped.
  final VoidCallback? onTap;

  /// Whether the handle should show the attention indicator.
  final bool showAttention;

  /// The width of the handle.
  final double width;

  /// The height of the handle.
  final double height;

  /// Background color of the handle.
  final Color? backgroundColor;

  /// Color of the drag indicator.
  final Color? indicatorColor;

  /// Creates a sidebar handle.
  const SidebarHandle({
    super.key,
    required this.edge,
    this.onTap,
    this.showAttention = false,
    this.width = 24,
    this.height = 80,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final iconColor = indicatorColor ?? theme.colorScheme.onSurfaceVariant;

    final borderRadius = edge == SidebarEdge.left
        ? const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: edge == SidebarEdge.left
                  ? const Offset(2, 0)
                  : const Offset(-2, 0),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Drag indicator lines
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLine(iconColor),
                const SizedBox(height: 4),
                _buildLine(iconColor),
                const SizedBox(height: 4),
                _buildLine(iconColor),
              ],
            ),
            // Attention indicator
            if (showAttention)
              Positioned(
                top: 8,
                child: _AttentionDot(color: theme.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(Color color) {
    return Container(
      width: 4,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Animated attention dot that pulses.
class _AttentionDot extends StatefulWidget {
  final Color color;

  const _AttentionDot({required this.color});

  @override
  State<_AttentionDot> createState() => _AttentionDotState();
}

class _AttentionDotState extends State<_AttentionDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
