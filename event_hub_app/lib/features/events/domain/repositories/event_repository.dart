import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/data/models/event_detail_model.dart';
import 'package:event_hub_app/features/events/domain/entities/comment.dart';
import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/participation.dart';
import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';
import 'package:event_hub_app/features/events/domain/enums/event_category.dart';

abstract interface class EventRepository {
  Future<List<Event>> getEvents({String? status, String? category});

  Future<Event> getEventById(String id);

  Future<Event> createEvent({
    required String title,
    required EventCategory category,
    required String description,
    List<String>? pollOptions,
  });

  Future<Poll?> getPollByEventId(String eventId);

  Future<List<Participation>> getParticipationsByEventId(String eventId);

  Future<List<Comment>> getCommentsByEventId(String eventId);

  Future<CommentWithUserModel> addComment({
    required String eventId,
    required String content,
    String? parentId,
  });

  Future<EventDetailModel> getEventDetail(String eventId);

  Future<({bool voted, int upvotes})> voteEvent(String eventId);

  Future<({List<PollOption> options, List<String> userVotes})> votePoll({
    required String pollId,
    required String optionId,
  });

  Future<({bool participating, String? status, Map<String, int> counts})>
      participate({
    required String eventId,
    required String status,
  });

  Future<({bool voted, int upvotes})> voteComment(String commentId);
}
