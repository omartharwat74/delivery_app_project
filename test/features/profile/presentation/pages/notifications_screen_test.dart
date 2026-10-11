import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/constants/app_assets.dart';
import 'package:delivery_app_project/features/profile/presentation/pages/notifications_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

void main() {
  testWidgets('NotificationsScreen displays empty placeholder text and 80x80 asset image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ar'),
        home: NotificationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد اشعارات حتى الآن'), findsOneWidget);

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.width, 80);
    expect(imageWidget.height, 80);
    expect(imageWidget.image, isA<AssetImage>());
    final assetImage = imageWidget.image as AssetImage;
    expect(assetImage.assetName, AppAssets.emptyNotifications);
  });
}
