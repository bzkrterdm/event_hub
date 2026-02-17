import 'package:flutter/material.dart';

import 'package:event_hub_app/features/events/domain/entities/poll.dart';
import 'package:event_hub_app/features/events/domain/entities/poll_option.dart';
import 'package:event_hub_app/features/events/domain/enums/poll_type.dart';

class PollSection extends StatelessWidget {
  const PollSection({
    super.key,
    required this.poll,
    this.selectedOptionIds = const {},
    this.onOptionSelected,
  });

  final Poll poll;
  final Set<String> selectedOptionIds;
  final ValueChanged<String>? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalVotes =
        poll.options.fold<int>(0, (sum, opt) => sum + opt.voteCount);

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
                  Icons.poll_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Poll',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _PollTypeBadge(type: poll.type),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              poll.question,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...poll.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PollOptionBar(
                  option: option,
                  totalVotes: totalVotes,
                  isSelected: selectedOptionIds.contains(option.id),
                  onTap: () => onOptionSelected?.call(option.id),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalVotes vote${totalVotes == 1 ? '' : 's'} total',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PollTypeBadge extends StatelessWidget {
  const _PollTypeBadge({required this.type});

  final PollType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label =
        type == PollType.single ? 'Single choice' : 'Multiple choice';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PollOptionBar extends StatelessWidget {
  const _PollOptionBar({
    required this.option,
    required this.totalVotes,
    required this.isSelected,
    this.onTap,
  });

  final PollOption option;
  final int totalVotes;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fraction = totalVotes > 0 ? option.voteCount / totalVotes : 0.0;
    final percentage = (fraction * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        option.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${option.voteCount})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
