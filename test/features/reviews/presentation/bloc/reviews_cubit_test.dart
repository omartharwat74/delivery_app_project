import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/reviews/data/models/review_model.dart';
import 'package:delivery_app_project/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:delivery_app_project/features/reviews/presentation/bloc/reviews_cubit.dart';
import 'package:delivery_app_project/features/reviews/presentation/bloc/reviews_state.dart';

class FakeReviewsRepository implements ReviewsRepository {
  bool shouldThrow = false;
  ReviewPaginatedResponse response = const ReviewPaginatedResponse(reviews: []);

  @override
  Future<ReviewPaginatedResponse> getReviews({int page = 1, int perPage = 10}) async {
    if (shouldThrow) {
      throw Exception('Server error');
    }
    return response;
  }
}

void main() {
  late FakeReviewsRepository repository;
  late ReviewsCubit cubit;

  setUp(() {
    repository = FakeReviewsRepository();
    cubit = ReviewsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is ReviewsInitial', () {
    expect(cubit.state, const ReviewsInitial());
  });

  test('loadReviews emits Loading and Loaded with reviews', () async {
    repository.response = const ReviewPaginatedResponse(
      reviews: [
        ReviewModel(
          id: 1,
          rating: 5,
          comment: 'خدمة ممتازة',
          isReported: false,
          createdAt: '2026-06-06T12:00:00Z',
          user: ReviewUserModel(name: 'أحمد'),
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: 1,
    );

    expectLater(
      cubit.stream,
      emitsInOrder([
        const ReviewsLoading(),
        ReviewsLoaded(
          reviews: repository.response.reviews,
          currentPage: 1,
          hasMore: false,
          isLoadingMore: false,
        ),
      ]),
    );

    await cubit.loadReviews();
  });

  test('loadReviews emits Loading and Error on failure', () async {
    repository.shouldThrow = true;

    expectLater(
      cubit.stream,
      emitsInOrder([
        const ReviewsLoading(),
        isA<ReviewsError>(),
      ]),
    );

    await cubit.loadReviews();
  });
}
