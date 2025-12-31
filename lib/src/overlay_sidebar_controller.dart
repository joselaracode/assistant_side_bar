import 'package:flutter/foundation.dart';
import 'overlay_sidebar_state.dart';

/// Controller for managing the state of an [OverlaySidebar].
///
/// Use this controller to programmatically expand, collapse, request attention,
/// or dismiss the sidebar.
class OverlaySidebarController extends ChangeNotifier {
  SidebarState _state;
  SidebarEdge _currentEdge;

  /// Creates a controller with optional initial state and edge.
  OverlaySidebarController({
    SidebarState initialState = SidebarState.collapsed,
    SidebarEdge initialEdge = SidebarEdge.right,
  })  : _state = initialState,
        _currentEdge = initialEdge;

  /// The current state of the sidebar.
  SidebarState get state => _state;

  /// The current edge to which the sidebar is anchored.
  SidebarEdge get currentEdge => _currentEdge;

  /// Whether the sidebar is currently visible (not dismissed or dismissing).
  bool get isVisible =>
      _state != SidebarState.dismissed && _state != SidebarState.dismissing;

  /// Whether the sidebar is expanded.
  bool get isExpanded => _state == SidebarState.expanded;

  /// Whether the sidebar is collapsed (including attention state).
  bool get isCollapsed =>
      _state == SidebarState.collapsed ||
      _state == SidebarState.collapsedAttention;

  /// Expands the sidebar to its full width.
  void expand() {
    if (_state == SidebarState.dismissed || _state == SidebarState.dismissing) {
      return;
    }
    _state = SidebarState.expanded;
    notifyListeners();
  }

  /// Collapses the sidebar to the current edge.
  void collapse() {
    if (_state == SidebarState.dismissed || _state == SidebarState.dismissing) {
      return;
    }
    _state = SidebarState.collapsed;
    notifyListeners();
  }

  /// Sets the sidebar to collapsed attention state.
  ///
  /// Use this to draw the user's attention to the sidebar with a visual indicator.
  void requestAttention() {
    if (_state == SidebarState.dismissed || _state == SidebarState.dismissing) {
      return;
    }
    _state = SidebarState.collapsedAttention;
    notifyListeners();
  }

  /// Clears the attention state and returns to normal collapsed state.
  void clearAttention() {
    if (_state == SidebarState.collapsedAttention) {
      _state = SidebarState.collapsed;
      notifyListeners();
    }
  }

  /// Starts the dismiss animation.
  ///
  /// The sidebar will animate towards the dismiss target and then become hidden.
  void dismiss() {
    if (_state == SidebarState.dismissed || _state == SidebarState.dismissing) {
      return;
    }
    _state = SidebarState.dismissing;
    notifyListeners();
  }

  /// Called when the dismiss animation completes.
  void completeDismiss() {
    _state = SidebarState.dismissed;
    notifyListeners();
  }

  /// Shows the sidebar after it has been dismissed.
  ///
  /// Returns to the collapsed state.
  void show() {
    if (_state != SidebarState.dismissed) {
      return;
    }
    _state = SidebarState.collapsed;
    notifyListeners();
  }

  /// Updates the edge to which the sidebar is anchored.
  void setEdge(SidebarEdge edge) {
    if (_currentEdge != edge) {
      _currentEdge = edge;
      notifyListeners();
    }
  }

  /// Internal method to update state without validation.
  /// Used by the widget during drag operations.
  void updateState(SidebarState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
}
