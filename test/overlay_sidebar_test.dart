import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistant_side_bar/assistant_side_bar.dart';

void main() {
  group('OverlaySidebar', () {
    late OverlaySidebarController controller;

    setUp(() {
      controller = OverlaySidebarController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildTestWidget({
      OverlaySidebarController? customController,
      SidebarWidgetBuilder? expandedBuilder,
      SidebarWidgetBuilder? collapsedBuilder,
      SidebarWidgetBuilder? attentionBuilder,
      GlobalKey? dismissTargetKey,
      double expandedWidth = 300,
      double expandedHeight = 400,
      double collapsedWidth = 24,
      double collapsedHeight = 80,
      SidebarEdge initialEdge = SidebarEdge.right,
      bool enableDrag = true,
      SidebarStateCallback? onStateChanged,
      SidebarEdgeCallback? onEdgeChanged,
      VoidCallback? onDismissed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: OverlaySidebar(
              controller: customController ?? controller,
              expandedBuilder: expandedBuilder ??
                  (context, ctrl) => Container(
                        color: Colors.blue,
                        child: const Text('Expanded Content'),
                      ),
              collapsedBuilder: collapsedBuilder,
              attentionBuilder: attentionBuilder,
              dismissTargetKey: dismissTargetKey,
              expandedWidth: expandedWidth,
              expandedHeight: expandedHeight,
              collapsedWidth: collapsedWidth,
              collapsedHeight: collapsedHeight,
              initialEdge: initialEdge,
              enableDrag: enableDrag,
              onStateChanged: onStateChanged,
              onEdgeChanged: onEdgeChanged,
              onDismissed: onDismissed,
            ),
          ),
        ),
      );
    }

    group('rendering in collapsed state', () {
      testWidgets('renders SidebarHandle when collapsed', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(OverlaySidebar), findsOneWidget);
        expect(find.byType(SidebarHandle), findsOneWidget);
      });

      testWidgets('does not show expanded content when collapsed',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Expanded Content'), findsNothing);
      });

      testWidgets('uses default SidebarHandle when collapsedBuilder is null',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(collapsedBuilder: null));

        expect(find.byType(SidebarHandle), findsOneWidget);
      });

      testWidgets('uses collapsedBuilder when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          collapsedBuilder: (context, ctrl) => Container(
            key: const Key('custom-collapsed'),
            child: const Text('Custom Collapsed'),
          ),
        ));

        expect(find.byKey(const Key('custom-collapsed')), findsOneWidget);
        expect(find.text('Custom Collapsed'), findsOneWidget);
      });
    });

    group('rendering in expanded state', () {
      testWidgets('renders expanded content when expanded', (tester) async {
        controller.expand();
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Expanded Content'), findsOneWidget);
      });

      testWidgets('does not show SidebarHandle when fully expanded',
          (tester) async {
        controller.expand();
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SidebarHandle), findsNothing);
      });

      testWidgets('expandedBuilder is called with controller', (tester) async {
        OverlaySidebarController? receivedController;

        controller.expand();
        await tester.pumpWidget(buildTestWidget(
          expandedBuilder: (context, ctrl) {
            receivedController = ctrl;
            return const Text('Expanded');
          },
        ));
        await tester.pumpAndSettle();

        expect(receivedController, controller);
      });

      testWidgets('expandedBuilder receives BuildContext', (tester) async {
        BuildContext? receivedContext;

        controller.expand();
        await tester.pumpWidget(buildTestWidget(
          expandedBuilder: (context, ctrl) {
            receivedContext = context;
            return const Text('Expanded');
          },
        ));
        await tester.pumpAndSettle();

        expect(receivedContext, isNotNull);
      });
    });

    group('rendering in dismissed state', () {
      testWidgets('renders nothing when dismissed', (tester) async {
        controller.dismiss();
        controller.completeDismiss();
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(SidebarHandle), findsNothing);
        expect(find.text('Expanded Content'), findsNothing);
      });
    });

    group('rendering in attention state', () {
      testWidgets('shows attention indicator in default handle', (tester) async {
        controller.requestAttention();
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final handle = tester.widget<SidebarHandle>(find.byType(SidebarHandle));
        expect(handle.showAttention, true);
      });

      testWidgets('uses attentionBuilder when provided', (tester) async {
        controller.requestAttention();
        await tester.pumpWidget(buildTestWidget(
          attentionBuilder: (context, ctrl) => Container(
            key: const Key('custom-attention'),
            child: const Text('Custom Attention'),
          ),
        ));

        expect(find.byKey(const Key('custom-attention')), findsOneWidget);
        expect(find.text('Custom Attention'), findsOneWidget);
      });
    });

    group('state callbacks', () {
      testWidgets('onStateChanged fires when state changes', (tester) async {
        final stateChanges = <SidebarState>[];

        await tester.pumpWidget(buildTestWidget(
          onStateChanged: (state) => stateChanges.add(state),
        ));

        controller.expand();
        await tester.pump();

        expect(stateChanges, contains(SidebarState.expanded));
      });

      testWidgets('onStateChanged fires on collapse', (tester) async {
        controller.expand();
        final stateChanges = <SidebarState>[];

        await tester.pumpWidget(buildTestWidget(
          onStateChanged: (state) => stateChanges.add(state),
        ));
        await tester.pumpAndSettle();

        controller.collapse();
        await tester.pump();

        expect(stateChanges, contains(SidebarState.collapsed));
      });

      testWidgets('onStateChanged fires on requestAttention', (tester) async {
        final stateChanges = <SidebarState>[];

        await tester.pumpWidget(buildTestWidget(
          onStateChanged: (state) => stateChanges.add(state),
        ));

        controller.requestAttention();
        await tester.pump();

        expect(stateChanges, contains(SidebarState.collapsedAttention));
      });

      testWidgets('onStateChanged fires on dismiss', (tester) async {
        final stateChanges = <SidebarState>[];

        await tester.pumpWidget(buildTestWidget(
          onStateChanged: (state) => stateChanges.add(state),
        ));

        controller.dismiss();
        await tester.pump();

        expect(stateChanges, contains(SidebarState.dismissing));
      });

      testWidgets('onEdgeChanged fires when edge changes', (tester) async {
        final edgeChanges = <SidebarEdge>[];

        await tester.pumpWidget(buildTestWidget(
          onEdgeChanged: (edge) => edgeChanges.add(edge),
        ));

        controller.setEdge(SidebarEdge.left);
        await tester.pump();

        expect(edgeChanges, contains(SidebarEdge.left));
      });

      testWidgets('onDismissed fires when dismiss animation completes',
          (tester) async {
        bool dismissed = false;

        await tester.pumpWidget(buildTestWidget(
          onDismissed: () => dismissed = true,
        ));

        controller.dismiss();
        await tester.pumpAndSettle();

        expect(dismissed, true);
      });
    });

    group('tap interaction', () {
      testWidgets('tapping handle expands sidebar', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(controller.isCollapsed, true);

        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();

        expect(controller.isExpanded, true);
      });

      testWidgets('tapping expanded sidebar does not collapse', (tester) async {
        controller.expand();
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(controller.isExpanded, true);

        await tester.tap(find.text('Expanded Content'));
        await tester.pump();

        expect(controller.isExpanded, true);
      });
    });

    group('edge positioning', () {
      testWidgets('positions on right edge by default', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // The handle should be positioned near the right edge
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, greaterThan(700)); // Near right edge of 800px container
      });

      testWidgets('positions on left edge when specified', (tester) async {
        controller.setEdge(SidebarEdge.left);
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // The handle should be positioned at the left edge
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, 0);
      });
    });

    group('dimensions', () {
      testWidgets('uses specified collapsed dimensions', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          collapsedWidth: 32,
          collapsedHeight: 100,
        ));
        await tester.pump();

        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.width, 32);
        expect(positioned.height, 100);
      });

      testWidgets('uses specified expanded dimensions', (tester) async {
        controller.expand();
        await tester.pumpWidget(buildTestWidget(
          expandedWidth: 350,
          expandedHeight: 450,
        ));
        await tester.pumpAndSettle();

        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.width, 350);
        expect(positioned.height, 450);
      });
    });

    group('controller lifecycle', () {
      testWidgets('updates when controller state changes externally',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(SidebarHandle), findsOneWidget);
        expect(find.text('Expanded Content'), findsNothing);

        controller.expand();
        await tester.pumpAndSettle();

        expect(find.text('Expanded Content'), findsOneWidget);

        controller.collapse();
        await tester.pumpAndSettle();

        expect(find.byType(SidebarHandle), findsOneWidget);
      });

      testWidgets('handles controller changes via setEdge', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        controller.setEdge(SidebarEdge.left);
        await tester.pump();

        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, 0);

        controller.setEdge(SidebarEdge.right);
        await tester.pump();

        final positioned2 = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned2.left, greaterThan(700));
      });
    });

    group('animation', () {
      testWidgets('animates when expanding', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Record initial state
        final initialPositioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(initialPositioned.width, 24); // Starts collapsed

        controller.expand();

        // First pump to start animation
        await tester.pump();

        // Complete the animation
        await tester.pumpAndSettle();

        // Now should be fully expanded
        final positionedFinal = tester.widget<Positioned>(find.byType(Positioned));
        expect(positionedFinal.width, 300);
      });

      testWidgets('animates when collapsing', (tester) async {
        controller.expand();
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify we start expanded
        final initialPositioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(initialPositioned.width, 300);

        controller.collapse();

        // First pump to start animation
        await tester.pump();

        // Complete the animation
        await tester.pumpAndSettle();

        // Now should be fully collapsed
        final positionedFinal = tester.widget<Positioned>(find.byType(Positioned));
        expect(positionedFinal.width, 24);
      });
    });

    group('dismiss animation', () {
      testWidgets('animates towards dismiss target when dismissing',
          (tester) async {
        final targetKey = GlobalKey();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: Stack(
                children: [
                  Positioned(
                    left: 50,
                    top: 50,
                    child: Container(
                      key: targetKey,
                      width: 40,
                      height: 40,
                      color: Colors.red,
                    ),
                  ),
                  OverlaySidebar(
                    controller: controller,
                    expandedBuilder: (context, ctrl) =>
                        const Text('Expanded Content'),
                    dismissTargetKey: targetKey,
                  ),
                ],
              ),
            ),
          ),
        ));

        controller.expand();
        await tester.pumpAndSettle();

        controller.dismiss();
        await tester.pump(const Duration(milliseconds: 200));

        // The dismiss animation should be in progress
        expect(controller.state, SidebarState.dismissing);

        await tester.pumpAndSettle();

        // After animation completes, should be dismissed
        expect(controller.state, SidebarState.dismissed);
      });
    });

    group('show after dismiss', () {
      testWidgets('can show sidebar after dismissal', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        controller.dismiss();
        await tester.pumpAndSettle();

        expect(controller.state, SidebarState.dismissed);
        expect(find.byType(SidebarHandle), findsNothing);

        controller.show();
        await tester.pump();

        expect(controller.state, SidebarState.collapsed);
        expect(find.byType(SidebarHandle), findsOneWidget);
      });
    });
  });
}
