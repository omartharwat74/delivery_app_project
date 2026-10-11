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
  final num rating;
  final String comment;
  final bool isReported;
  final String createdAt;
  final ReviewUserModel user;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.isReported,
    required this.createdAt,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?) ?? 0,
      comment: json['comment']?.toString() ?? '',
      isReported: json['is_reported'] == true || json['is_reported'] == 1,
      createdAt: json['created_at']?.toString() ?? '',
      user: json['user'] is Map<String, dynamic>
          ? ReviewUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const ReviewUserModel(name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'is_reported': isReported,
      'created_at': createdAt,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, rating, comment, isReported, createdAt, user];
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

  @override
  List<Object?> get props => [reviews, currentPage, lastPage, total];
}
