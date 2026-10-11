import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/document_upload_tile.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

void main() {
  Widget buildTile({
    required Locale locale,
    required bool readOnly,
    String? imageUrl,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: DocumentUploadTile(
          label: 'وثيقة',
          hintText: 'ارفع الوثيقة',
          tapToUploadLabel: 'اضغط للرفع',
          imageUrl: imageUrl,
          readOnly: readOnly,
          onTap: () {},
          onRemove: () {},
        ),
      ),
    );
  }

  testWidgets('renders network image in readOnly mode aligned to start (right in RTL)', (tester) async {
    await tester.pumpWidget(
      buildTile(
        locale: const Locale('ar'),
        readOnly: true,
        imageUrl: 'https://example.com/license.jpg',
      ),
    );
    await tester.pump();

    final networkImageFinder = find.byType(CachedNetworkImage);
    expect(networkImageFinder, findsOneWidget);

    final tileBoxFinder = find.byType(NetworkUploadSuccessCard);
    expect(tileBoxFinder, findsOneWidget);

    final cardRect = tester.getRect(tileBoxFinder);
    final imageRect = tester.getRect(networkImageFinder);

    // In Arabic RTL, start is the right side:
    // The image right edge should be near the card right edge.
    final distFromRight = cardRect.right - imageRect.right;
    final distFromLeft = imageRect.left - cardRect.left;
    expect(distFromRight, lessThan(distFromLeft));
  });

  testWidgets('renders network image in readOnly mode aligned to start (left in LTR)', (tester) async {
    await tester.pumpWidget(
      buildTile(
        locale: const Locale('en'),
        readOnly: true,
        imageUrl: 'https://example.com/license.jpg',
      ),
    );
    await tester.pump();

    final networkImageFinder = find.byType(CachedNetworkImage);
    expect(networkImageFinder, findsOneWidget);

    final tileBoxFinder = find.byType(NetworkUploadSuccessCard);
    expect(tileBoxFinder, findsOneWidget);

    final cardRect = tester.getRect(tileBoxFinder);
    final imageRect = tester.getRect(networkImageFinder);

    // In English LTR, start is the left side:
    // The image left edge should be near the card left edge.
    final distFromLeft = imageRect.left - cardRect.left;
    final distFromRight = cardRect.right - imageRect.right;
    expect(distFromLeft, lessThan(distFromRight));
  });
}
