import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/priority.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateText = DateFormat.yMMMd().format(task.dueDate);
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        gradient: task.isCompleted
            ? LinearGradient(
                colors: [
                  colorScheme.surfaceContainerHighest.withAlpha(50),
                  colorScheme.surfaceContainer.withAlpha(50),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isOverdue
                ? LinearGradient(
                    colors: [
                      Colors.red.withAlpha(50),
                      Colors.red.withAlpha(10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceContainerLowest,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted
              ? colorScheme.outline.withAlpha(30)
              : isOverdue
                  ? Colors.red.withAlpha(30)
                  : priorityColor(context, task.priority).withAlpha(20),
          width: 1.5,
        ),
        boxShadow: [
          if (!task.isCompleted)
            BoxShadow(
              color: priorityColor(context, task.priority).withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: onToggleCompleted,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? priorityColor(context, task.priority)
                          : Colors.transparent,
                      border: Border.all(
                        color: priorityColor(context, task.priority),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: task.isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? colorScheme.onSurfaceVariant.withAlpha(70)
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Date and Category Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? Colors.red.withAlpha(60)
                                  : colorScheme.primaryContainer.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOverdue
                                      ? Icons.schedule_rounded
                                      : Icons.calendar_today_rounded,
                                  size: 12,
                                  color: isOverdue
                                      ? Colors.red
                                      : colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOverdue ? 'Overdue' : dateText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isOverdue
                                        ? Colors.red
                                        : colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.category != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer
                                    .withAlpha(70),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_rounded,
                                    size: 12,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.category!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Priority Badge
                _PriorityBadge(
                    priority: task.priority, isCompleted: task.isCompleted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompleted;

  const _PriorityBadge({
    required this.priority,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityData = _getPriorityData(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted
                ? colorScheme.outline.withAlpha(80)
                : priorityData['color'],
            shape: BoxShape.circle,
            boxShadow: isCompleted
                ? null
                : [
                    BoxShadow(
                      color: priorityData['color'].withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          priorityData['emoji'],
          style: TextStyle(
            fontSize: 16,
            color: isCompleted ? colorScheme.outline.withAlpha(50) : null,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          priorityData['label'],
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isCompleted
                ? colorScheme.outline.withAlpha(60)
                : priorityData['color'],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getPriorityData(BuildContext context) {
    switch (priority) {
      case TaskPriority.low:
        return {
          'color': Colors.green,
          'emoji': '🟢',
          'label': 'LOW',
        };
      case TaskPriority.medium:
        return {
          'color': Colors.orange,
          'emoji': '🟡',
          'label': 'MED',
        };
      case TaskPriority.high:
        return {
          'color': Colors.red,
          'emoji': '🔴',
          'label': 'HIGH',
        };
    }
  }
}
