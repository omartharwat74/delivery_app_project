import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewModel> reviews;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ReviewsLoaded({
    required this.reviews,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ReviewsLoaded copyWith({
    List<ReviewModel>? reviews,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [reviews, currentPage, hasMore, isLoadingMore];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError({required this.message});

  @override
  List<Object?> get props => [message];
}
