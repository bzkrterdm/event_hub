import 'package:event_hub_app/features/events/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.eventId,
    super.parentId,
    required super.userId,
    required super.content,
    required super.upvotes,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      parentId: json['parentId'] as String?,
      userId: json['userId'] as String,
      content: json['content'] as String,
      upvotes: json['upvotes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory CommentModel.fromDomain(Comment comment) {
    return CommentModel(
      id: comment.id,
      eventId: comment.eventId,
      parentId: comment.parentId,
      userId: comment.userId,
      content: comment.content,
      upvotes: comment.upvotes,
      createdAt: comment.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'parentId': parentId,
      'userId': userId,
      'content': content,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
