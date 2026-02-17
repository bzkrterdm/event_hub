import 'package:event_hub_app/features/events/domain/enums/participation_status.dart';

class Participation {
  const Participation({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
  });

  final String id;
  final String eventId;
  final String userId;
  final ParticipationStatus status;

  Participation copyWith({
    String? id,
    String? eventId,
    String? userId,
    ParticipationStatus? status,
  }) {
    return Participation(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}
