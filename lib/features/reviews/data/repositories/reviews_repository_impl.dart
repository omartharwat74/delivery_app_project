import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_datasource.dart';
import '../models/review_model.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReviewPaginatedResponse> getReviews({int page = 1, int perPage = 10}) =>
      remoteDataSource.getReviews(page: page, perPage: perPage);
}
