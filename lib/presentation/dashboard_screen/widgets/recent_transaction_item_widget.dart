import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentTransactionItemWidget extends StatelessWidget {
  final String description;
  final String category;
  final double amount;
  final String date;
  final String time;
  final String iconName;
  final bool isVisible;

  const RecentTransactionItemWidget({
    super.key,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.time,
    required this.iconName,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = amount > 0;
    final Color amountColor = isIncome
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: _getCategoryColor(),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      category,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 1.w,
                      height: 1.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      time,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isVisible
                    ? '${isIncome ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}'
                    : '••••',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                date,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return const Color(0xFFFF6B6B);
      case 'transportation':
        return const Color(0xFF4ECDC4);
      case 'utilities':
        return const Color(0xFFFFE66D);
      case 'entertainment':
        return const Color(0xFFA8E6CF);
      case 'shopping':
        return const Color(0xFFFFB3BA);
      case 'income':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
