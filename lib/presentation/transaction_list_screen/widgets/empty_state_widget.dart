import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const EmptyStateWidget({
    super.key,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'receipt_long',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 60,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Transactions Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Start tracking your finances by adding your first transaction. Keep all your income and expenses organized in one place.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Add Transaction Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddTransaction,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text('Add Your First Transaction'),
                style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary Action
            TextButton(
              onPressed: () {
                // Navigate to help or tutorial
              },
              child: Text(
                'Learn how to get started',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
