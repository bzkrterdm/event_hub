import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/event_model.dart';
import 'package:event_hub_app/features/events/data/models/participation_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/poll_model.dart';
import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/shared/data/models/user_model.dart';
import 'package:event_hub_app/shared/domain/entities/user.dart';

class EventDetailModel {
  const EventDetailModel({
    required this.event,
    required this.creator,
    required this.polls,
    required this.participations,
    required this.comments,
  });

  final Event event;
  final User creator;
  final List<Poll> polls;
  final List<ParticipationWithUserModel> participations;
  final List<CommentWithUserModel> comments;

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final eventId = json['id'] as String;
    final event = EventModel.fromJson(json);
    final creator =
        UserModel.fromJson(json['creator'] as Map<String, dynamic>);

    final polls = (json['polls'] as List<dynamic>?)
            ?.map(
              (e) => PollModel.fromJson(
                e as Map<String, dynamic>,
                eventId: eventId,
              ),
            )
            .toList() ??
        [];

    final participations = (json['participations'] as List<dynamic>?)
            ?.map(
              (e) => ParticipationWithUserModel.fromJson(
                e as Map<String, dynamic>,
                eventId: eventId,
              ),
            )
            .toList() ??
        [];

    final comments = (json['comments'] as List<dynamic>?)
            ?.map(
              (e) => CommentWithUserModel.fromJson(
                e as Map<String, dynamic>,
                eventId: eventId,
              ),
            )
            .toList() ??
        [];

    return EventDetailModel(
      event: event,
      creator: creator,
      polls: polls,
      participations: participations,
      comments: comments,
    );
  }
}
