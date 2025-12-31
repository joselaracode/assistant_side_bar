/// The current state of the overlay sidebar.
enum SidebarState {
  /// Sidebar is fully visible and expanded.
  expanded,

  /// Sidebar is collapsed to the edge with only handle visible.
  collapsed,

  /// Sidebar is collapsed but requesting user attention (visual indicator).
  collapsedAttention,

  /// Sidebar is animating towards the dismiss target.
  dismissing,

  /// Sidebar is completely hidden after dismissal.
  dismissed,
}

/// The edge to which the sidebar is anchored.
enum SidebarEdge {
  /// Sidebar anchored to the left edge.
  left,

  /// Sidebar anchored to the right edge.
  right,
}
