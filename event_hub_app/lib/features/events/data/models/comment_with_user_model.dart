import 'package:event_hub_app/features/events/domain/entities/comment.dart';
import 'package:event_hub_app/shared/data/models/user_model.dart';
import 'package:event_hub_app/shared/domain/entities/user.dart';

class CommentWithUserModel {
  const CommentWithUserModel({
    required this.comment,
    required this.user,
    required this.replies,
  });

  final Comment comment;
  final User user;
  final List<CommentWithUserModel> replies;

  factory CommentWithUserModel.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return CommentWithUserModel(
      comment: Comment(
        id: json['id'] as String,
        eventId: eventId,
        parentId: json['parentId'] as String?,
        userId: (json['user'] as Map<String, dynamic>)['id'] as String,
        content: json['content'] as String,
        upvotes: json['upvotes'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      ),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>?)
              ?.map(
                (e) => CommentWithUserModel.fromJson(
                  e as Map<String, dynamic>,
                  eventId: eventId,
                ),
              )
              .toList() ??
          [],
    );
  }

  CommentWithUserModel copyWith({
    Comment? comment,
    User? user,
    List<CommentWithUserModel>? replies,
  }) {
    return CommentWithUserModel(
      comment: comment ?? this.comment,
      user: user ?? this.user,
      replies: replies ?? this.replies,
    );
  }
}
