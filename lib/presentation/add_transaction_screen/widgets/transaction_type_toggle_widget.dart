import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionTypeToggleWidget extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TransactionTypeToggleWidget({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isExpense) {
                  onChanged(true);
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color:
                      isExpense ? theme.colorScheme.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'remove',
                      color: isExpense
                          ? theme.colorScheme.onError
                          : theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Expense',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isExpense
                            ? theme.colorScheme.onError
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Income Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isExpense) {
                  onChanged(false);
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: !isExpense
                      ? AppTheme.getSuccessColor(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: !isExpense
                          ? Colors.white
                          : AppTheme.getSuccessColor(isDark),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Income',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: !isExpense
                            ? Colors.white
                            : AppTheme.getSuccessColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
