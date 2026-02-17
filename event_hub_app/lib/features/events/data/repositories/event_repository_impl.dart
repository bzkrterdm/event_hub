import 'package:event_hub_app/features/events/data/datasources/event_remote_service.dart';
import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/event_detail_model.dart';
import 'package:event_hub_app/features/events/domain/entities/comment.dart';
import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/participation.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';
import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({required EventRemoteService remoteService})
      : _remoteService = remoteService;

  final EventRemoteService _remoteService;

  @override
  Future<List<Event>> getEvents({String? status, String? category}) {
    return _remoteService.getEvents(status: status, category: category);
  }

  @override
  Future<Event> getEventById(String id) async {
    final detail = await _remoteService.getEventDetail(id);
    return detail.event;
  }

  @override
  Future<EventDetailModel> getEventDetail(String eventId) {
    return _remoteService.getEventDetail(eventId);
  }

  @override
  Future<Event> createEvent({
    required String title,
    required EventCategory category,
    required String description,
    List<String>? pollOptions,
  }) async {
    final hasPoll = pollOptions != null && pollOptions.isNotEmpty;
    final type = hasPoll ? 'poll' : 'discussion';

    final event = await _remoteService.createEvent(
      title: title,
      description: description,
      type: type,
      category: category.name,
      creatorId: EventRemoteService.currentUserId,
    );

    if (hasPoll) {
      await _remoteService.createPoll(
        eventId: event.id,
        question: title,
        type: 'single',
        options: pollOptions,
      );
    }

    return event;
  }

  @override
  Future<Poll?> getPollByEventId(String eventId) async {
    final detail = await _remoteService.getEventDetail(eventId);
    return detail.polls.isEmpty ? null : detail.polls.first;
  }

  @override
  Future<List<Participation>> getParticipationsByEventId(
    String eventId,
  ) async {
    final detail = await _remoteService.getEventDetail(eventId);
    return detail.participations.map((p) => p.participation).toList();
  }

  @override
  Future<List<Comment>> getCommentsByEventId(String eventId) async {
    final detail = await _remoteService.getEventDetail(eventId);
    return detail.comments.map((c) => c.comment).toList();
  }

  @override
  Future<({bool voted, int upvotes})> voteEvent(String eventId) {
    return _remoteService.voteEvent(eventId, EventRemoteService.currentUserId);
  }

  @override
  Future<({List<PollOption> options, List<String> userVotes})> votePoll({
    required String pollId,
    required String optionId,
  }) {
    return _remoteService.votePoll(
      pollId: pollId,
      optionId: optionId,
      userId: EventRemoteService.currentUserId,
    );
  }

  @override
  Future<({bool participating, String? status, Map<String, int> counts})>
      participate({
    required String eventId,
    required String status,
  }) {
    return _remoteService.participate(
      eventId: eventId,
      userId: EventRemoteService.currentUserId,
      status: status,
    );
  }

  @override
  Future<CommentWithUserModel> addComment({
    required String eventId,
    required String content,
    String? parentId,
  }) {
    return _remoteService.addComment(
      eventId: eventId,
      userId: EventRemoteService.currentUserId,
      content: content,
      parentId: parentId,
    );
  }

  @override
  Future<({bool voted, int upvotes})> voteComment(String commentId) {
    return _remoteService.voteComment(
      commentId,
      EventRemoteService.currentUserId,
    );
  }
}
