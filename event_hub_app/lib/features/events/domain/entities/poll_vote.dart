class PollVote {
  const PollVote({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.userId,
  });

  final String id;
  final String pollId;
  final String optionId;
  final String userId;

  PollVote copyWith({
    String? id,
    String? pollId,
    String? optionId,
    String? userId,
  }) {
    return PollVote(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      optionId: optionId ?? this.optionId,
      userId: userId ?? this.userId,
    );
  }
}
