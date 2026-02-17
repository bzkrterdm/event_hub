import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_app/features/events/data/models/comment_with_user_model.dart';
import 'package:event_hub_app/features/events/domain/repositories/event_repository.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventDetailInitial());

  final EventRepository _eventRepository;

  Future<void> loadEventDetail(String eventId) async {
    emit(const EventDetailLoading());
    try {
      final detail = await _eventRepository.getEventDetail(eventId);

      emit(EventDetailLoaded(
        event: detail.event,
        creator: detail.creator,
        poll: detail.polls.isEmpty ? null : detail.polls.first,
        participations: detail.participations,
        comments: detail.comments,
      ));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
    }
  }

  Future<void> voteEvent() async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    try {
      final result =
          await _eventRepository.voteEvent(currentState.event.id);
      emit(currentState.copyWith(
        event: currentState.event.copyWith(upvotes: result.upvotes),
      ));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> votePoll({
    required String pollId,
    required String optionId,
  }) async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    try {
      final result = await _eventRepository.votePoll(
        pollId: pollId,
        optionId: optionId,
      );

      final updatedPoll = currentState.poll?.copyWith(options: result.options);
      emit(currentState.copyWith(
        poll: updatedPoll,
        userVotes: result.userVotes,
      ));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> participate(String status) async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    try {
      final result = await _eventRepository.participate(
        eventId: currentState.event.id,
        status: status,
      );

      // Reload full detail to get updated participations list
      final detail =
          await _eventRepository.getEventDetail(currentState.event.id);
      emit(EventDetailLoaded(
        event: detail.event,
        creator: detail.creator,
        poll: detail.polls.isEmpty ? null : detail.polls.first,
        participations: detail.participations,
        comments: detail.comments,
        userVotes: currentState.userVotes,
        userParticipationStatus: result.status,
      ));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> addComment({
    required String content,
    String? parentId,
  }) async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    try {
      final newComment = await _eventRepository.addComment(
        eventId: currentState.event.id,
        content: content,
        parentId: parentId,
      );

      List<CommentWithUserModel> updatedComments;
      if (parentId == null) {
        updatedComments = [newComment, ...currentState.comments];
      } else {
        updatedComments = _insertReply(currentState.comments, parentId, newComment);
      }

      emit(currentState.copyWith(
        event: currentState.event.copyWith(
          commentCount: currentState.event.commentCount + 1,
        ),
        comments: updatedComments,
      ));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> voteComment(String commentId) async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    try {
      final result = await _eventRepository.voteComment(commentId);
      final updatedComments =
          _updateCommentUpvotes(currentState.comments, commentId, result.upvotes);
      emit(currentState.copyWith(comments: updatedComments));
    } on Exception catch (e) {
      emit(EventDetailError(e.toString()));
      emit(currentState);
    }
  }

  List<CommentWithUserModel> _insertReply(
    List<CommentWithUserModel> comments,
    String parentId,
    CommentWithUserModel reply,
  ) {
    return comments.map((c) {
      if (c.comment.id == parentId) {
        return c.copyWith(replies: [...c.replies, reply]);
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(replies: _insertReply(c.replies, parentId, reply));
      }
      return c;
    }).toList();
  }

  List<CommentWithUserModel> _updateCommentUpvotes(
    List<CommentWithUserModel> comments,
    String commentId,
    int upvotes,
  ) {
    return comments.map((c) {
      if (c.comment.id == commentId) {
        return c.copyWith(comment: c.comment.copyWith(upvotes: upvotes));
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(
          replies: _updateCommentUpvotes(c.replies, commentId, upvotes),
        );
      }
      return c;
    }).toList();
  }
}
