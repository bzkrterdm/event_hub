import 'package:event_hub_app/features/events/domain/entities/poll_vote.dart';

class PollVoteModel extends PollVote {
  const PollVoteModel({
    required super.id,
    required super.pollId,
    required super.optionId,
    required super.userId,
  });

  factory PollVoteModel.fromJson(Map<String, dynamic> json) {
    return PollVoteModel(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      optionId: json['optionId'] as String,
      userId: json['userId'] as String,
    );
  }

  factory PollVoteModel.fromDomain(PollVote vote) {
    return PollVoteModel(
      id: vote.id,
      pollId: vote.pollId,
      optionId: vote.optionId,
      userId: vote.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'pollId': pollId, 'optionId': optionId, 'userId': userId};
  }
}
