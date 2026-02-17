class Comment {
  const Comment({
    required this.id,
    required this.eventId,
    this.parentId,
    required this.userId,
    required this.content,
    required this.upvotes,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String? parentId;
  final String userId;
  final String content;
  final int upvotes;
  final DateTime createdAt;

  Comment copyWith({
    String? id,
    String? eventId,
    Object? parentId = _sentinel,
    String? userId,
    String? content,
    int? upvotes,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      parentId: parentId == _sentinel
          ? this.parentId
          : parentId as String?,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const _sentinel = Object();
}
