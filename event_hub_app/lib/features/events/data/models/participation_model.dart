import 'package:event_hub_app/features/events/domain/entities/participation.dart';
import 'package:event_hub_app/features/events/domain/enums/participation_status.dart';

class ParticipationModel extends Participation {
  const ParticipationModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.status,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    return ParticipationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      status: ParticipationStatus.values.byName(json['status'] as String),
    );
  }

  factory ParticipationModel.fromDomain(Participation participation) {
    return ParticipationModel(
      id: participation.id,
      eventId: participation.eventId,
      userId: participation.userId,
      status: participation.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'status': status.name,
    };
  }
}
