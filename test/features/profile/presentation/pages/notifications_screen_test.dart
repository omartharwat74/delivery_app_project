import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/constants/app_assets.dart';
import 'package:delivery_app_project/features/notifications/data/models/notification_model.dart';
import 'package:delivery_app_project/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:delivery_app_project/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:delivery_app_project/features/profile/presentation/pages/notifications_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class MockNotificationsRepository implements NotificationsRepository {
  List<NotificationModel> notificationsToReturn = [];

  @override
  Future<List<NotificationModel>> getNotifications() async => notificationsToReturn;
}

void main() {
  testWidgets('NotificationsScreen displays empty placeholder text and 80x80 asset image when empty', (tester) async {
    final mockRepo = MockNotificationsRepository()..notificationsToReturn = [];
    final cubit = NotificationsCubit(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: cubit..loadNotifications(),
          child: const NotificationsScreen(),
        ),
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

  testWidgets('NotificationsScreen displays notifications list when data is loaded', (tester) async {
    final mockRepo = MockNotificationsRepository()
      ..notificationsToReturn = [
        const NotificationModel(
          id: 1,
          title: 'طلب جديد',
          body: 'لديك طلب جديد في انتظار القبول',
          isAdmin: false,
          createdAt: '2026-06-06T10:00:00.000000Z',
        ),
      ];
    final cubit = NotificationsCubit(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: cubit..loadNotifications(),
          child: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('طلب جديد'), findsOneWidget);
    expect(find.text('لديك طلب جديد في انتظار القبول'), findsOneWidget);
  });
}
