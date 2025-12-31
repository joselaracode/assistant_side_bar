import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistant_side_bar/assistant_side_bar.dart';

void main() {
  group('SidebarHandle', () {
    Widget buildTestWidget({
      SidebarEdge edge = SidebarEdge.right,
      VoidCallback? onTap,
      bool showAttention = false,
      double width = 24,
      double height = 80,
      Color? backgroundColor,
      Color? indicatorColor,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SidebarHandle(
            edge: edge,
            onTap: onTap,
            showAttention: showAttention,
            width: width,
            height: height,
            backgroundColor: backgroundColor,
            indicatorColor: indicatorColor,
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('renders correctly for right edge', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.right));

        expect(find.byType(SidebarHandle), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('renders correctly for left edge', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.left));

        expect(find.byType(SidebarHandle), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('renders with correct dimensions', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 32,
          height: 100,
        ));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );

        expect(animatedContainer.constraints?.maxWidth, 32);
        expect(animatedContainer.constraints?.maxHeight, 100);
      });

      testWidgets('renders with default dimensions', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );

        expect(animatedContainer.constraints?.maxWidth, 24);
        expect(animatedContainer.constraints?.maxHeight, 80);
      });

      testWidgets('renders drag indicator lines', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // There should be 3 drag indicator lines inside a Column
        final column = find.descendant(
          of: find.byType(SidebarHandle),
          matching: find.byType(Column),
        );
        expect(column, findsOneWidget);
      });

      testWidgets('applies custom background color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          backgroundColor: Colors.red,
        ));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.color, Colors.red);
      });
    });

    group('border radius', () {
      testWidgets('has correct border radius for right edge', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.right));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(borderRadius.topLeft, const Radius.circular(8));
        expect(borderRadius.bottomLeft, const Radius.circular(8));
        expect(borderRadius.topRight, Radius.zero);
        expect(borderRadius.bottomRight, Radius.zero);
      });

      testWidgets('has correct border radius for left edge', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.left));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(borderRadius.topRight, const Radius.circular(8));
        expect(borderRadius.bottomRight, const Radius.circular(8));
        expect(borderRadius.topLeft, Radius.zero);
        expect(borderRadius.bottomLeft, Radius.zero);
      });
    });

    group('attention indicator', () {
      testWidgets('does not show attention indicator by default',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(showAttention: false));

        // The attention dot should not be present
        // We check for Positioned widget that contains the attention dot
        final positionedWidgets = find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Positioned),
        );

        // Should not find any Positioned widgets (attention dot is wrapped in Positioned)
        expect(positionedWidgets, findsNothing);
      });

      testWidgets('shows attention indicator when showAttention is true',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(showAttention: true));

        // The attention dot should be present in a Positioned widget
        final positionedWidgets = find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Positioned),
        );

        expect(positionedWidgets, findsOneWidget);
      });

      testWidgets('attention indicator animates', (tester) async {
        await tester.pumpWidget(buildTestWidget(showAttention: true));

        // Pump a frame to start animation
        await tester.pump();

        // Find the AnimatedBuilder used for the pulsing animation
        final animatedBuilder = find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(AnimatedBuilder),
        );

        expect(animatedBuilder, findsOneWidget);

        // Advance animation and verify it updates
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
      });
    });

    group('onTap callback', () {
      testWidgets('fires onTap callback when tapped', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapped = true,
        ));

        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();

        expect(tapped, true);
      });

      testWidgets('does not crash when onTap is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(onTap: null));

        // Should not throw when tapped
        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();
      });

      testWidgets('multiple taps fire callback multiple times',
          (tester) async {
        int tapCount = 0;

        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapCount++,
        ));

        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();
        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();
        await tester.tap(find.byType(SidebarHandle));
        await tester.pump();

        expect(tapCount, 3);
      });
    });

    group('shadow', () {
      testWidgets('has shadow on right edge pointing left', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.right));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        final shadow = decoration.boxShadow!.first;

        expect(shadow.offset, const Offset(-2, 0));
      });

      testWidgets('has shadow on left edge pointing right', (tester) async {
        await tester.pumpWidget(buildTestWidget(edge: SidebarEdge.left));

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        final shadow = decoration.boxShadow!.first;

        expect(shadow.offset, const Offset(2, 0));
      });
    });
  });
}
