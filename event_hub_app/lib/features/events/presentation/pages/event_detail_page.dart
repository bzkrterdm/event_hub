import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:event_hub_app/core/router/app_router.dart';
import 'package:event_hub_app/features/events/domain/enums/event_status.dart';
import 'package:event_hub_app/features/events/domain/enums/event_type.dart';
import 'package:event_hub_app/features/events/domain/enums/participation_status.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_detail_cubit.dart';
import 'package:event_hub_app/features/events/presentation/cubit/event_detail_state.dart';
import 'package:event_hub_app/features/events/presentation/widgets/discussion_section.dart';
import 'package:event_hub_app/features/events/presentation/widgets/event_detail_header.dart';
import 'package:event_hub_app/features/events/presentation/widgets/poll_section.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<EventDetailCubit>();
    Future.microtask(() => cubit.loadEventDetail(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<EventDetailCubit, EventDetailState>(
        builder: (context, state) {
          return switch (state) {
            EventDetailInitial() ||
            EventDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            EventDetailError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<EventDetailCubit>()
                          .loadEventDetail(widget.eventId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            final EventDetailLoaded loaded => _buildContent(context, loaded),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventDetailLoaded state) {
    final event = state.event;
    final cubit = context.read<EventDetailCubit>();

    return Column(
      children: [
        if (event.status == EventStatus.finalized)
          _buildFinalizedBanner(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EventDetailHeader(
                  event: event,
                  participations: state.participations
                      .map((p) => p.participation)
                      .toList(),
                  onUpvote: () => cubit.voteEvent(),
                  onParticipationChanged: (status) {
                    final statusName = switch (status) {
                      ParticipationStatus.going => 'going',
                      ParticipationStatus.maybe => 'maybe',
                      ParticipationStatus.notGoing => 'notGoing',
                    };
                    cubit.participate(statusName);
                  },
                ),
                if (event.type == EventType.poll && state.poll != null) ...[
                  const SizedBox(height: 16),
                  PollSection(
                    poll: state.poll!,
                    selectedOptionIds: state.userVotes.toSet(),
                    onOptionSelected: (optionId) => cubit.votePoll(
                      pollId: state.poll!.id,
                      optionId: optionId,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DiscussionSection(
                  comments: state.comments
                      .map((c) => c.comment)
                      .toList(),
                  onSend: (content) => cubit.addComment(content: content),
                  onCommentUpvote: (commentId) =>
                      cubit.voteComment(commentId),
                  onReply: (parentId) => _showReplyDialog(context, parentId),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showReplyDialog(BuildContext context, String parentId) {
    final controller = TextEditingController();
    final cubit = context.read<EventDetailCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Write a reply...'),
          textInputAction: TextInputAction.send,
          onSubmitted: (text) {
            final trimmed = text.trim();
            if (trimmed.isEmpty) return;
            cubit.addComment(content: trimmed, parentId: parentId);
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              cubit.addComment(content: trimmed, parentId: parentId);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  Widget _buildFinalizedBanner(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => context
            .push(AppRoutes.finalizedEventDetailPath(widget.eventId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'This event has been finalized — tap to view details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
