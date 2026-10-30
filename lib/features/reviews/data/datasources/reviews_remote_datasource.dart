import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<ReviewPaginatedResponse> getReviews({int page = 1, int perPage = 10});
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient apiClient;

  ReviewsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReviewPaginatedResponse> getReviews({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await apiClient.getResponse<ReviewPaginatedResponse>(
      ApiConstants.reviews,
      queryParams: {'page': page, 'per_page': perPage},
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return ReviewPaginatedResponse.fromJson(data, page);
        } else if (data is List) {
          final reviews = data
              .whereType<Map<String, dynamic>>()
              .map(ReviewModel.fromJson)
              .toList();
          return ReviewPaginatedResponse(
            reviews: reviews,
            currentPage: page,
            lastPage: page,
            total: reviews.length,
          );
        }
        return const ReviewPaginatedResponse(reviews: []);
      },
    );

    return response.data ?? const ReviewPaginatedResponse(reviews: []);
  }
}
