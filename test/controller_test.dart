import 'package:flutter_test/flutter_test.dart';
import 'package:assistant_side_bar/assistant_side_bar.dart';

void main() {
  group('OverlaySidebarController', () {
    late OverlaySidebarController controller;

    setUp(() {
      controller = OverlaySidebarController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('initialization', () {
      test('initializes with default state (collapsed)', () {
        expect(controller.state, SidebarState.collapsed);
      });

      test('initializes with default edge (right)', () {
        expect(controller.currentEdge, SidebarEdge.right);
      });

      test('initializes with custom initial state', () {
        final customController = OverlaySidebarController(
          initialState: SidebarState.expanded,
        );
        expect(customController.state, SidebarState.expanded);
        customController.dispose();
      });

      test('initializes with custom initial edge', () {
        final customController = OverlaySidebarController(
          initialEdge: SidebarEdge.left,
        );
        expect(customController.currentEdge, SidebarEdge.left);
        customController.dispose();
      });

      test('initializes with both custom state and edge', () {
        final customController = OverlaySidebarController(
          initialState: SidebarState.expanded,
          initialEdge: SidebarEdge.left,
        );
        expect(customController.state, SidebarState.expanded);
        expect(customController.currentEdge, SidebarEdge.left);
        customController.dispose();
      });
    });

    group('expand()', () {
      test('transitions from collapsed to expanded', () {
        expect(controller.state, SidebarState.collapsed);
        controller.expand();
        expect(controller.state, SidebarState.expanded);
      });

      test('transitions from collapsedAttention to expanded', () {
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
        controller.expand();
        expect(controller.state, SidebarState.expanded);
      });

      test('does nothing when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);
        controller.expand();
        expect(controller.state, SidebarState.dismissed);
      });

      test('does nothing when dismissing', () {
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
        controller.expand();
        expect(controller.state, SidebarState.dismissing);
      });

      test('notifies listeners when state changes', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.expand();
        expect(notifyCount, 1);
      });
    });

    group('collapse()', () {
      test('transitions from expanded to collapsed', () {
        controller.expand();
        expect(controller.state, SidebarState.expanded);
        controller.collapse();
        expect(controller.state, SidebarState.collapsed);
      });

      test('transitions from collapsedAttention to collapsed', () {
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
        controller.collapse();
        expect(controller.state, SidebarState.collapsed);
      });

      test('does nothing when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);
        controller.collapse();
        expect(controller.state, SidebarState.dismissed);
      });

      test('does nothing when dismissing', () {
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
        controller.collapse();
        expect(controller.state, SidebarState.dismissing);
      });

      test('notifies listeners when state changes', () {
        controller.expand();
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.collapse();
        expect(notifyCount, 1);
      });
    });

    group('requestAttention()', () {
      test('transitions from collapsed to collapsedAttention', () {
        expect(controller.state, SidebarState.collapsed);
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
      });

      test('transitions from expanded to collapsedAttention', () {
        controller.expand();
        expect(controller.state, SidebarState.expanded);
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
      });

      test('does nothing when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);
        controller.requestAttention();
        expect(controller.state, SidebarState.dismissed);
      });

      test('does nothing when dismissing', () {
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
        controller.requestAttention();
        expect(controller.state, SidebarState.dismissing);
      });

      test('notifies listeners when state changes', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.requestAttention();
        expect(notifyCount, 1);
      });
    });

    group('clearAttention()', () {
      test('transitions from collapsedAttention to collapsed', () {
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
        controller.clearAttention();
        expect(controller.state, SidebarState.collapsed);
      });

      test('does nothing when not in collapsedAttention state', () {
        expect(controller.state, SidebarState.collapsed);
        controller.clearAttention();
        expect(controller.state, SidebarState.collapsed);

        controller.expand();
        controller.clearAttention();
        expect(controller.state, SidebarState.expanded);
      });

      test('notifies listeners when transitioning from collapsedAttention', () {
        controller.requestAttention();
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.clearAttention();
        expect(notifyCount, 1);
      });

      test('does not notify listeners when not in collapsedAttention', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.clearAttention();
        expect(notifyCount, 0);
      });
    });

    group('dismiss()', () {
      test('transitions from collapsed to dismissing', () {
        expect(controller.state, SidebarState.collapsed);
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
      });

      test('transitions from expanded to dismissing', () {
        controller.expand();
        expect(controller.state, SidebarState.expanded);
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
      });

      test('transitions from collapsedAttention to dismissing', () {
        controller.requestAttention();
        expect(controller.state, SidebarState.collapsedAttention);
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
      });

      test('does nothing when already dismissing', () {
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);
        controller.dismiss();
        expect(notifyCount, 0);
      });

      test('does nothing when already dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);
        controller.dismiss();
        expect(notifyCount, 0);
      });

      test('notifies listeners when state changes', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.dismiss();
        expect(notifyCount, 1);
      });
    });

    group('completeDismiss()', () {
      test('transitions from dismissing to dismissed', () {
        controller.dismiss();
        expect(controller.state, SidebarState.dismissing);
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);
      });

      test('notifies listeners when state changes', () {
        controller.dismiss();
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.completeDismiss();
        expect(notifyCount, 1);
      });
    });

    group('show()', () {
      test('transitions from dismissed to collapsed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.state, SidebarState.dismissed);
        controller.show();
        expect(controller.state, SidebarState.collapsed);
      });

      test('does nothing when not dismissed', () {
        expect(controller.state, SidebarState.collapsed);
        controller.show();
        expect(controller.state, SidebarState.collapsed);

        controller.expand();
        controller.show();
        expect(controller.state, SidebarState.expanded);

        controller.requestAttention();
        controller.show();
        expect(controller.state, SidebarState.collapsedAttention);
      });

      test('notifies listeners when transitioning from dismissed', () {
        controller.dismiss();
        controller.completeDismiss();

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.show();
        expect(notifyCount, 1);
      });

      test('does not notify listeners when not dismissed', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.show();
        expect(notifyCount, 0);
      });
    });

    group('setEdge()', () {
      test('changes edge from right to left', () {
        expect(controller.currentEdge, SidebarEdge.right);
        controller.setEdge(SidebarEdge.left);
        expect(controller.currentEdge, SidebarEdge.left);
      });

      test('changes edge from left to right', () {
        controller.setEdge(SidebarEdge.left);
        expect(controller.currentEdge, SidebarEdge.left);
        controller.setEdge(SidebarEdge.right);
        expect(controller.currentEdge, SidebarEdge.right);
      });

      test('does nothing when setting same edge', () {
        expect(controller.currentEdge, SidebarEdge.right);
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.setEdge(SidebarEdge.right);
        expect(notifyCount, 0);
        expect(controller.currentEdge, SidebarEdge.right);
      });

      test('notifies listeners when edge changes', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.setEdge(SidebarEdge.left);
        expect(notifyCount, 1);
      });
    });

    group('updateState()', () {
      test('updates state directly', () {
        controller.updateState(SidebarState.expanded);
        expect(controller.state, SidebarState.expanded);

        controller.updateState(SidebarState.dismissing);
        expect(controller.state, SidebarState.dismissing);
      });

      test('does nothing when setting same state', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.updateState(SidebarState.collapsed);
        expect(notifyCount, 0);
      });

      test('notifies listeners when state changes', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.updateState(SidebarState.expanded);
        expect(notifyCount, 1);
      });
    });

    group('isVisible getter', () {
      test('returns true when collapsed', () {
        expect(controller.isVisible, true);
      });

      test('returns true when expanded', () {
        controller.expand();
        expect(controller.isVisible, true);
      });

      test('returns true when collapsedAttention', () {
        controller.requestAttention();
        expect(controller.isVisible, true);
      });

      test('returns false when dismissing', () {
        controller.dismiss();
        expect(controller.isVisible, false);
      });

      test('returns false when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.isVisible, false);
      });
    });

    group('isExpanded getter', () {
      test('returns false when collapsed', () {
        expect(controller.isExpanded, false);
      });

      test('returns true when expanded', () {
        controller.expand();
        expect(controller.isExpanded, true);
      });

      test('returns false when collapsedAttention', () {
        controller.requestAttention();
        expect(controller.isExpanded, false);
      });

      test('returns false when dismissing', () {
        controller.dismiss();
        expect(controller.isExpanded, false);
      });

      test('returns false when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.isExpanded, false);
      });
    });

    group('isCollapsed getter', () {
      test('returns true when collapsed', () {
        expect(controller.isCollapsed, true);
      });

      test('returns false when expanded', () {
        controller.expand();
        expect(controller.isCollapsed, false);
      });

      test('returns true when collapsedAttention', () {
        controller.requestAttention();
        expect(controller.isCollapsed, true);
      });

      test('returns false when dismissing', () {
        controller.dismiss();
        expect(controller.isCollapsed, false);
      });

      test('returns false when dismissed', () {
        controller.dismiss();
        controller.completeDismiss();
        expect(controller.isCollapsed, false);
      });
    });
  });
}
