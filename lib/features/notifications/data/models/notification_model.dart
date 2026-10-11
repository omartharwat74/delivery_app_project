import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? image;
  final bool isAdmin;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    required this.isAdmin,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      image: json['image']?.toString(),
      isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image': image,
      'is_admin': isAdmin,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, title, body, image, isAdmin, createdAt];
}
