import 'package:flutter/material.dart';

import 'package:event_hub_app/features/events/domain/entities/event.dart';
import 'package:event_hub_app/features/events/domain/entities/participation.dart';
import 'package:event_hub_app/features/events/domain/enums/event_category.dart';
import 'package:event_hub_app/features/events/domain/enums/event_status.dart';
import 'package:event_hub_app/features/events/domain/enums/event_type.dart';
import 'package:event_hub_app/features/events/domain/enums/participation_status.dart';

class EventDetailHeader extends StatelessWidget {
  const EventDetailHeader({
    super.key,
    required this.event,
    required this.participations,
    this.onUpvote,
    this.onParticipationChanged,
  });

  final Event event;
  final List<Participation> participations;
  final VoidCallback? onUpvote;
  final ValueChanged<ParticipationStatus>? onParticipationChanged;

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
            _buildChips(context),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetaInfo(context),
            if (event.status == EventStatus.finalized) ...[
              const SizedBox(height: 16),
              _buildFinalizedInfo(context),
            ],
            const SizedBox(height: 16),
            _buildActions(context),
            const SizedBox(height: 16),
            _buildParticipationBar(context),
          ],
        ),
      ),
    );
  }

  // Helpers

  Widget _buildChips(BuildContext context) {
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

  Widget _buildMetaInfo(BuildContext context) {
    final theme = Theme.of(context);
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(event.creatorId, style: metaStyle),
        const SizedBox(width: 16),
        Icon(
          Icons.schedule_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(_formatDate(event.createdAt), style: metaStyle),
      ],
    );
  }

  Widget _buildFinalizedInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finalized Details',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (event.finalDate != null)
            _FinalizedRow(
              icon: Icons.calendar_today_rounded,
              label: _formatFullDate(event.finalDate!),
            ),
          if (event.finalLocation != null) ...[
            const SizedBox(height: 4),
            _FinalizedRow(
              icon: Icons.location_on_outlined,
              label: event.finalLocation!,
            ),
          ],
          if (event.finalDetails != null) ...[
            const SizedBox(height: 4),
            _FinalizedRow(
              icon: Icons.info_outline_rounded,
              label: event.finalDetails!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: '${event.upvotes}',
          onTap: onUpvote,
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${event.commentCount} comments',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.share_outlined,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildParticipationBar(BuildContext context) {
    final goingCount = participations
        .where((p) => p.status == ParticipationStatus.going)
        .length;
    final maybeCount = participations
        .where((p) => p.status == ParticipationStatus.maybe)
        .length;
    final notGoingCount = participations
        .where((p) => p.status == ParticipationStatus.notGoing)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participation',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ParticipationButton(
                label: 'Going',
                count: goingCount,
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
                onTap: () =>
                    onParticipationChanged?.call(ParticipationStatus.going),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ParticipationButton(
                label: 'Maybe',
                count: maybeCount,
                icon: Icons.help_outline_rounded,
                color: Colors.orange,
                onTap: () =>
                    onParticipationChanged?.call(ParticipationStatus.maybe),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ParticipationButton(
                label: 'Not Going',
                count: notGoingCount,
                icon: Icons.cancel_outlined,
                color: Colors.red,
                onTap: () =>
                    onParticipationChanged?.call(ParticipationStatus.notGoing),
              ),
            ),
          ],
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

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute';
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _FinalizedRow extends StatelessWidget {
  const _FinalizedRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipationButton extends StatelessWidget {
  const _ParticipationButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              '$count $label',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
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
