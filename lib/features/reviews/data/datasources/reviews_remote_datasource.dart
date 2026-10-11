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
          final itemsList = data['data'];
          final reviews = itemsList is List
              ? itemsList
                  .whereType<Map<String, dynamic>>()
                  .map(ReviewModel.fromJson)
                  .toList()
              : <ReviewModel>[];
          final currentPage = (data['current_page'] as num?)?.toInt() ?? page;
          final lastPage = (data['last_page'] as num?)?.toInt() ?? currentPage;
          final total = (data['total'] as num?)?.toInt() ?? reviews.length;
          return ReviewPaginatedResponse(
            reviews: reviews,
            currentPage: currentPage,
            lastPage: lastPage,
            total: total,
          );
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
