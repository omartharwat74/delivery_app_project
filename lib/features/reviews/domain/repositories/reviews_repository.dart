import '../../data/models/review_model.dart';

abstract class ReviewsRepository {
  Future<ReviewPaginatedResponse> getReviews({int page = 1, int perPage = 10});
}
