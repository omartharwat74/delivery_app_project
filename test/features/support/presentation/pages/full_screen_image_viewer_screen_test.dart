import 'package:delivery_app_project/features/support/presentation/pages/full_screen_image_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testImageUrl = 'https://example.com/test_image.jpg';

  Widget buildTestWidget() {
    return const MaterialApp(
      home: FullScreenImageViewerScreen(imageUrl: testImageUrl),
    );
  }

  testWidgets('renders FullScreenImageViewerScreen with InteractiveViewer and Hero', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    // Verify black background
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);

    // Verify InteractiveViewer exists
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Verify Hero with imageUrl as tag exists
    final heroFinder = find.byWidgetPredicate(
      (widget) => widget is Hero && widget.tag == testImageUrl,
    );
    expect(heroFinder, findsOneWidget);

    // Verify close button exists
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('tapping close button pops the screen', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => FullScreenImageViewerScreen.open(context, testImageUrl),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    // Tap Open to push
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FullScreenImageViewerScreen), findsOneWidget);

    // Tap Close button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FullScreenImageViewerScreen), findsNothing);
  });

  testWidgets('tapping outside image edges pops the screen', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => FullScreenImageViewerScreen.open(context, testImageUrl),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    // Tap Open to push
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FullScreenImageViewerScreen), findsOneWidget);

    // Tap near top edge (outside image)
    await tester.tapAt(const Offset(50, 50));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FullScreenImageViewerScreen), findsNothing);
  });
}
