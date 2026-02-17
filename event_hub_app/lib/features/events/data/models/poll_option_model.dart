import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';

class PollOptionModel extends PollOption {
  const PollOptionModel({
    required super.id,
    required super.text,
    required super.voteCount,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: (json['vote_count'] ?? json['voteCount']) as int,
    );
  }

  factory PollOptionModel.fromDomain(PollOption option) {
    return PollOptionModel(
      id: option.id,
      text: option.text,
      voteCount: option.voteCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'voteCount': voteCount};
  }
}
