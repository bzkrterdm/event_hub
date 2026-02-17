import 'package:event_hub_app/features/events/domain/entities/participation.dart';
import 'package:event_hub_app/features/events/domain/enums/participation_status.dart';
import 'package:event_hub_app/shared/data/models/user_model.dart';
import 'package:event_hub_app/shared/domain/entities/user.dart';

class ParticipationWithUserModel {
  const ParticipationWithUserModel({
    required this.participation,
    required this.user,
  });

  final Participation participation;
  final User user;

  factory ParticipationWithUserModel.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return ParticipationWithUserModel(
      participation: Participation(
        id: json['id'] as String,
        eventId: eventId,
        userId: (json['user'] as Map<String, dynamic>)['id'] as String,
        status: ParticipationStatus.values.byName(json['status'] as String),
      ),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
