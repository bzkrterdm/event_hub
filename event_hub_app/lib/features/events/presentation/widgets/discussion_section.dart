import 'package:flutter/material.dart';

import 'package:event_hub_app/features/events/domain/entities/comment.dart';
import 'package:event_hub_app/features/events/presentation/widgets/comment_tile.dart';

class DiscussionSection extends StatelessWidget {
  const DiscussionSection({
    super.key,
    required this.comments,
    this.onSend,
    this.onCommentUpvote,
    this.onReply,
  });

  final List<Comment> comments;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onCommentUpvote;
  final ValueChanged<String>? onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Discussion',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${comments.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CommentInput(onSend: onSend),
            const SizedBox(height: 16),
            if (comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No comments yet. Start the discussion!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (_, __) => Divider(
                  height: 24,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentTile(
                    comment: comment,
                    isReply: comment.parentId != null,
                    onUpvote: () => onCommentUpvote?.call(comment.id),
                    onReply: () => onReply?.call(comment.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  const _CommentInput({this.onSend});

  final ValueChanged<String>? onSend;

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: _handleSend,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () => _handleSend(_controller.text),
          icon: const Icon(Icons.send_rounded, size: 20),
        ),
      ],
    );
  }

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    widget.onSend?.call(trimmed);
    _controller.clear();
  }
}
