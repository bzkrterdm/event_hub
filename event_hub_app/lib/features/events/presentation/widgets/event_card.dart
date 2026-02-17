import 'package:flutter/material.dart';

import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/enums/event_status.dart';
import 'package:event_hub_app/features/events/domain/enums/event_type.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

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
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                event.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _CategoryChip(category: event.category),
        const SizedBox(width: 8),
        _TypeChip(type: event.type),
        const Spacer(),
        _StatusBadge(status: event.status),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Icon(
          Icons.arrow_upward_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text('${event.upvotes}', style: secondaryStyle),
        const SizedBox(width: 16),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text('${event.commentCount}', style: secondaryStyle),
        const Spacer(),
        Text(
          _formatDate(event.createdAt),
          style: secondaryStyle,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color(context)),
          const SizedBox(width: 4),
          Text(
            category.name[0].toUpperCase() + category.name.substring(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _color(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (category) {
        EventCategory.cinema => Icons.movie_outlined,
        EventCategory.food => Icons.restaurant_outlined,
        EventCategory.games => Icons.sports_esports_outlined,
        EventCategory.sports => Icons.sports_soccer_outlined,
        EventCategory.other => Icons.category_outlined,
      };

  Color _color(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (category) {
      EventCategory.cinema => Colors.purple,
      EventCategory.food => Colors.orange,
      EventCategory.games => Colors.blue,
      EventCategory.sports => Colors.green,
      EventCategory.other => colorScheme.secondary,
    };
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final EventType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.name[0].toUpperCase() + type.name.substring(1),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Color get _color => switch (status) {
        EventStatus.open => Colors.green,
        EventStatus.finalized => Colors.blue,
        EventStatus.cancelled => Colors.red,
      };
}
