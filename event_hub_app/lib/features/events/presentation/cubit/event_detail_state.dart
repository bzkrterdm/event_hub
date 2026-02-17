import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/participation_with_user_model.dart';
import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/shared/domain/entities/user.dart';

sealed class EventDetailState {
  const EventDetailState();
}

final class EventDetailInitial extends EventDetailState {
  const EventDetailInitial();
}

final class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();
}

final class EventDetailLoaded extends EventDetailState {
  const EventDetailLoaded({
    required this.event,
    required this.creator,
    required this.participations,
    required this.comments,
    this.poll,
    this.userVotes = const [],
    this.userParticipationStatus,
  });

  final Event event;
  final User creator;
  final Poll? poll;
  final List<ParticipationWithUserModel> participations;
  final List<CommentWithUserModel> comments;
  final List<String> userVotes;
  final String? userParticipationStatus;

  EventDetailLoaded copyWith({
    Event? event,
    User? creator,
    Poll? poll,
    Object? pollSentinel = _sentinel,
    List<ParticipationWithUserModel>? participations,
    List<CommentWithUserModel>? comments,
    List<String>? userVotes,
    Object? userParticipationStatus = _sentinel,
  }) {
    return EventDetailLoaded(
      event: event ?? this.event,
      creator: creator ?? this.creator,
      poll: pollSentinel == _sentinel ? (poll ?? this.poll) : poll,
      participations: participations ?? this.participations,
      comments: comments ?? this.comments,
      userVotes: userVotes ?? this.userVotes,
      userParticipationStatus: userParticipationStatus == _sentinel
          ? this.userParticipationStatus
          : userParticipationStatus as String?,
    );
  }

  static const _sentinel = Object();
}

final class EventDetailError extends EventDetailState {
  const EventDetailError(this.message);

  final String message;
}
