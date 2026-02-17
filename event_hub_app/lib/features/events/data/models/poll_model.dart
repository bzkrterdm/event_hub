import 'package:event_hub_app/features/events/data/models/poll_option_model.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/features/events/domain/enums/poll_type.dart';

class PollModel extends Poll {
  const PollModel({
    required super.id,
    required super.eventId,
    required super.question,
    required super.type,
    required super.options,
  });

  factory PollModel.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return PollModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String? ?? eventId,
      question: json['question'] as String,
      type: PollType.values.byName(json['type'] as String),
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory PollModel.fromDomain(Poll poll) {
    return PollModel(
      id: poll.id,
      eventId: poll.eventId,
      question: poll.question,
      type: poll.type,
      options: poll.options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'question': question,
      'type': type.name,
      'options': options
          .map((o) => PollOptionModel.fromDomain(o).toJson())
          .toList(),
    };
  }
}
