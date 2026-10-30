import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/reviews/data/models/review_model.dart';
import 'package:delivery_app_project/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:delivery_app_project/features/reviews/presentation/bloc/reviews_cubit.dart';
import 'package:delivery_app_project/features/profile/presentation/pages/reviews_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class MockReviewsRepository implements ReviewsRepository {
  ReviewPaginatedResponse response = const ReviewPaginatedResponse(reviews: []);

  @override
  Future<ReviewPaginatedResponse> getReviews({int page = 1, int perPage = 10}) async {
    return response;
  }
}

void main() {
  final sampleReviews = [
    const ReviewModel(
      id: 1,
      orderId: 101,
      rating: 4.5,
      comment: 'الاكل هنا جميل جداً انصح بالتعامل مع المطعم ده',
      isReported: false,
      createdAt: '2026-06-06T12:00:00Z',
      user: ReviewUserModel(name: 'احمد محمد'),
    ),
    const ReviewModel(
      id: 2,
      orderId: 102,
      rating: 5,
      comment: 'الخدمة كانت ممتازة، وميزانية الأسعار معقولة جداً',
      isReported: false,
      createdAt: '2026-06-07T14:30:00Z',
      user: ReviewUserModel(name: 'سارة علي'),
    ),
  ];

  testWidgets('ReviewsScreen renders Figma design without user avatar, without order ID, and without numeric rating', (tester) async {
    final mockRepo = MockReviewsRepository()
      ..response = ReviewPaginatedResponse(
        reviews: sampleReviews,
        currentPage: 1,
        lastPage: 1,
        total: 2,
      );
    final cubit = ReviewsCubit(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: cubit..loadReviews(),
          child: const ReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies names and comments
    expect(find.text('احمد محمد'), findsOneWidget);
    expect(find.text('الاكل هنا جميل جداً انصح بالتعامل مع المطعم ده'), findsOneWidget);
    expect(find.text('سارة علي'), findsOneWidget);

    // Formatted date 2026/6/6
    expect(find.text('2026/6/6'), findsOneWidget);
    expect(find.text('2026/6/7'), findsOneWidget);

    // Verifies NO CircleAvatar or person icon
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byIcon(Icons.person_rounded), findsNothing);

    // Verifies NO order ID badge
    expect(find.text('#101'), findsNothing);
    expect(find.text('#102'), findsNothing);

    // Verifies NO numeric rating text like "4.5" or "5.0"
    expect(find.text('4.5'), findsNothing);
    expect(find.text('5.0'), findsNothing);

    // Verifies star icons are present
    expect(find.byIcon(Icons.star_rounded), findsWidgets);
    expect(find.byIcon(Icons.star_half_rounded), findsWidgets);

    // Verifies Dividers are present between items
    expect(find.byType(Divider), findsWidgets);
  });

  testWidgets('ReviewsScreen renders properly in dark mode and in English LTR', (tester) async {
    final mockRepo = MockReviewsRepository()
      ..response = ReviewPaginatedResponse(
        reviews: sampleReviews,
        currentPage: 1,
        lastPage: 1,
        total: 2,
      );
    final cubit = ReviewsCubit(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider.value(
          value: cubit..loadReviews(),
          child: const ReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('احمد محمد'), findsOneWidget);
    expect(find.text('2026/6/6'), findsOneWidget);
  });
}
