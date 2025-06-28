import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatelessWidget {
  final double totalBalance;
  final double monthlyChange;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool isRefreshing;

  const BalanceCardWidget({
    super.key,
    required this.totalBalance,
    required this.monthlyChange,
    required this.isVisible,
    required this.onToggleVisibility,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositiveChange = monthlyChange >= 0;
    final Color changeColor = isPositiveChange
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and visibility toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary
                      .withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: isVisible ? 'visibility' : 'visibility_off',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Balance amount
          Row(
            children: [
              if (isRefreshing)
                Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(right: 2.w),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  isVisible ? '\$${totalBalance.toStringAsFixed(2)}' : '••••••',
                  style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 32.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Monthly change indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onPrimary
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: isPositiveChange ? 'trending_up' : 'trending_down',
                  color: changeColor,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${isPositiveChange ? '+' : ''}${monthlyChange.toStringAsFixed(1)}%',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'this month',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.8),
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
