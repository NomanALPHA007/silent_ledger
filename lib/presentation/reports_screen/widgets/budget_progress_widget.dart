import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> budgetData;

  const BudgetProgressWidget({
    super.key,
    required this.budgetData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to budget management screen
                },
                child: Text(
                  'Manage',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...budgetData.map((budget) => _buildBudgetItem(context, budget)),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BuildContext context, Map<String, dynamic> budget) {
    final theme = Theme.of(context);
    final spent = budget['spent'] as double;
    final budgetAmount = budget['budget'] as double;
    final progress = spent / budgetAmount;
    final remaining = budgetAmount - spent;

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = theme.colorScheme.error;
    } else if (progress >= 0.8) {
      progressColor =
          AppTheme.getWarningColor(theme.brightness == Brightness.light);
    } else {
      progressColor =
          AppTheme.getSuccessColor(theme.brightness == Brightness.light);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Color(budget['color'] as int).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: budget['icon'] as String,
                    color: Color(budget['color'] as int),
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          budget['category'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${spent.toStringAsFixed(2)} of \$${budgetAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          remaining >= 0
                              ? '\$${remaining.toStringAsFixed(2)} left'
                              : '\$${(-remaining).toStringAsFixed(2)} over',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: remaining >= 0
                                ? AppTheme.getSuccessColor(
                                    theme.brightness == Brightness.light)
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 1.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: (progress.clamp(0.0, 1.0) * 100).w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
