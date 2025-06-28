import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionDetailBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const TransactionDetailBottomSheetWidget({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = (transaction['amount'] as double) < 0;
    final amount = (transaction['amount'] as double).abs();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Header
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? theme.colorScheme.error.withAlpha(26)
                            : AppTheme.getSuccessColor(
                                    theme.brightness == Brightness.light)
                                .withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: transaction['categoryIcon'] as String,
                          color: isExpense
                              ? theme.colorScheme.error
                              : AppTheme.getSuccessColor(
                                  theme.brightness == Brightness.light),
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['description'] as String,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            transaction['category'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? '-' : '+'}\$${amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isExpense
                                ? theme.colorScheme.error
                                : AppTheme.getSuccessColor(
                                    theme.brightness == Brightness.light),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatDate(transaction['date'] as DateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Transaction Details
                _buildDetailItem(
                  context,
                  'Account',
                  transaction['account'] as String,
                  Icons.account_balance_wallet,
                ),

                _buildDetailItem(
                  context,
                  'Date & Time',
                  _formatDetailedDate(transaction['date'] as DateTime),
                  Icons.schedule,
                ),

                if (transaction['notes'] != null &&
                    (transaction['notes'] as String).isNotEmpty)
                  _buildDetailItem(
                    context,
                    'Notes',
                    transaction['notes'] as String,
                    Icons.note,
                  ),

                if (transaction['isRecurring'] == true)
                  _buildDetailItem(
                    context,
                    'Recurring',
                    'This is a recurring transaction',
                    Icons.repeat,
                  ),

                SizedBox(height: 3.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onEdit != null) onEdit!();
                        },
                        icon: CustomIconWidget(
                          iconName: 'edit',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: const Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onDuplicate != null) onDuplicate!();
                        },
                        icon: CustomIconWidget(
                          iconName: 'content_copy',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: const Text('Duplicate'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onDelete != null) onDelete!();
                        },
                        icon: CustomIconWidget(
                          iconName: 'delete',
                          color: theme.colorScheme.error,
                          size: 18,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(77),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: 'content_copy',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDetailedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.day} ${months[date.month - 1]} ${date.year} at $formattedTime';
  }
}
