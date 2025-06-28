import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ConfidenceLevelWidget extends StatelessWidget {
  final String selectedLevel;
  final Function(String) onLevelChanged;

  const ConfidenceLevelWidget({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Confidence Level',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Tooltip(
              message: 'How confident are you about this transaction details?',
              child: CustomIconWidget(
                iconName: 'info_outline',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        Row(
          children: [
            Expanded(
              child: _buildConfidenceOption(
                theme,
                'low',
                'Low',
                'Uncertain details',
                const Color(0xFFFF6B6B),
                'warning',
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildConfidenceOption(
                theme,
                'medium',
                'Medium',
                'Mostly accurate',
                const Color(0xFFFECA57),
                'schedule',
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildConfidenceOption(
                theme,
                'high',
                'High',
                'Very confident',
                const Color(0xFF4ECDC4),
                'verified',
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        // Confidence level explanation
        _buildConfidenceExplanation(theme),
      ],
    );
  }

  Widget _buildConfidenceOption(
    ThemeData theme,
    String level,
    String title,
    String subtitle,
    Color color,
    String iconName,
  ) {
    final isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onLevelChanged(level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? color
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceExplanation(ThemeData theme) {
    final explanations = {
      'low': {
        'title': 'Low Confidence',
        'description':
            'Transaction details may need verification. Will be flagged for review.',
        'icon': 'warning',
        'color': const Color(0xFFFF6B6B),
      },
      'medium': {
        'title': 'Medium Confidence',
        'description':
            'Standard transaction with typical accuracy. May undergo random verification.',
        'icon': 'schedule',
        'color': const Color(0xFFFECA57),
      },
      'high': {
        'title': 'High Confidence',
        'description':
            'Very accurate transaction details. Higher trust score contribution.',
        'icon': 'verified',
        'color': const Color(0xFF4ECDC4),
      },
    };

    final explanation = explanations[selectedLevel]!;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: (explanation['color'] as Color).withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (explanation['color'] as Color).withAlpha(51),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: explanation['icon'] as String,
            color: explanation['color'] as Color,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation['title'] as String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: explanation['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  explanation['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
