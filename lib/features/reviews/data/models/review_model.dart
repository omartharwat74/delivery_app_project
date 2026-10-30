import 'package:equatable/equatable.dart';

class ReviewUserModel extends Equatable {
  final String name;

  const ReviewUserModel({required this.name});

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [name];
}

class ReviewModel extends Equatable {
  final int id;
  final dynamic orderId;
  final num rating;
  final String comment;
  final bool isReported;
  final String createdAt;
  final ReviewUserModel user;

  const ReviewModel({
    required this.id,
    this.orderId,
    required this.rating,
    required this.comment,
    required this.isReported,
    required this.createdAt,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      orderId: json['order_id'],
      rating: (json['rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '') ??
          0.0,
      comment: json['comment']?.toString() ?? '',
      isReported: json['is_reported'] == true ||
          json['is_reported'] == 1 ||
          json['is_reported']?.toString() == '1' ||
          json['is_reported']?.toString().toLowerCase() == 'true',
      createdAt: json['created_at']?.toString() ?? '',
      user: json['user'] is Map<String, dynamic>
          ? ReviewUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : ReviewUserModel(
              name: json['user_name']?.toString() ??
                  json['customer_name']?.toString() ??
                  '',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'is_reported': isReported,
      'created_at': createdAt,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props =>
      [id, orderId, rating, comment, isReported, createdAt, user];
}

class ReviewPaginatedResponse extends Equatable {
  final List<ReviewModel> reviews;
  final int currentPage;
  final int lastPage;
  final int total;

  const ReviewPaginatedResponse({
    required this.reviews,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory ReviewPaginatedResponse.fromJson(
    Map<String, dynamic> json, [
    int fallbackPage = 1,
  ]) {
    final rawList = json['items'] ?? json['data'] ?? json['reviews'];
    final reviews = rawList is List
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(ReviewModel.fromJson)
            .toList()
        : <ReviewModel>[];

    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    final currentPage =
        (meta['current_page'] ?? json['current_page'] as num?)?.toInt() ??
            fallbackPage;
    final lastPage =
        (meta['last_page'] ?? json['last_page'] as num?)?.toInt() ??
            currentPage;
    final total =
        (meta['total'] ?? json['total'] as num?)?.toInt() ?? reviews.length;

    return ReviewPaginatedResponse(
      reviews: reviews,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }

  @override
  List<Object?> get props => [reviews, currentPage, lastPage, total];
}
