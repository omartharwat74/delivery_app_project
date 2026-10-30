import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/reviews_repository.dart';
import 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository repository;
  static const int perPage = 10;

  ReviewsCubit({required this.repository}) : super(const ReviewsInitial());

  Future<void> loadReviews({bool refresh = false}) async {
    if (!refresh) {
      emit(const ReviewsLoading());
    }
    try {
      final response = await repository.getReviews(page: 1, perPage: perPage);
      emit(
        ReviewsLoaded(
          reviews: response.reviews,
          currentPage: response.currentPage,
          hasMore: response.currentPage < response.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      emit(ReviewsError(message: msg));
    }
  }

  Future<void> loadMoreReviews() async {
    final currentState = state;
    if (currentState is! ReviewsLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = currentState.currentPage + 1;
      final response = await repository.getReviews(
        page: nextPage,
        perPage: perPage,
      );
      emit(
        ReviewsLoaded(
          reviews: [...currentState.reviews, ...response.reviews],
          currentPage: response.currentPage,
          hasMore: response.currentPage < response.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
