import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

/// Displays the last updated timestamp with a clock icon.
class LastUpdatedText extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool isMock;

  const LastUpdatedText({super.key, this.lastUpdated, this.isMock = false});

  @override
  Widget build(BuildContext context) {
    final text = lastUpdated != null
        ? 'Last updated: ${AppDateUtils.timeAgo(lastUpdated!)}'
        : 'Waiting for data...';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMock ? Icons.science_rounded : Icons.access_time_rounded,
          size: 14,
          color: isMock ? AppColors.warning : AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          isMock ? 'Demo mode — $text' : text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMock ? AppColors.warning : AppColors.textMuted,
              ),
        ),
      ],
    );
  }
}
