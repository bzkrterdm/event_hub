import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';
import 'package:event_hub_app/features/events/domain/enums/poll_type.dart';

class Poll {
  const Poll({
    required this.id,
    required this.eventId,
    required this.question,
    required this.type,
    required this.options,
  });

  final String id;
  final String eventId;
  final String question;
  final PollType type;
  final List<PollOption> options;

  Poll copyWith({
    String? id,
    String? eventId,
    String? question,
    PollType? type,
    List<PollOption>? options,
  }) {
    return Poll(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}
