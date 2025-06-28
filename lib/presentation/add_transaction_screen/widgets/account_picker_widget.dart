import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountPickerWidget extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  final String selectedAccountId;
  final ValueChanged<String> onAccountSelected;

  const AccountPickerWidget({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedAccount = accounts.firstWhere(
      (acc) => acc['id'] == selectedAccountId,
      orElse: () => accounts.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),

        // Selected Account Display
        GestureDetector(
          onTap: () {
            _showAccountPicker(context, theme);
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
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
                // Account Icon
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: _getAccountColor(selectedAccount['type'], isDark)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getAccountIcon(selectedAccount['type']),
                      color: _getAccountColor(selectedAccount['type'], isDark),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Account Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAccount['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatBalance(selectedAccount['balance']),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selectedAccount['balance'] >= 0
                              ? AppTheme.getSuccessColor(isDark)
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAccountPicker(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            Text(
              'Select Account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),

            // Accounts List
            ...accounts.map((account) {
              final isSelected = account['id'] == selectedAccountId;

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  tileColor: isSelected
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3)
                      : null,
                  leading: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _getAccountColor(account['type'], isDark)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getAccountIcon(account['type']),
                        color: _getAccountColor(account['type'], isDark),
                        size: 24,
                      ),
                    ),
                  ),
                  title: Text(
                    account['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _formatBalance(account['balance']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: account['balance'] >= 0
                          ? AppTheme.getSuccessColor(isDark)
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: theme.colorScheme.primary,
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    onAccountSelected(account['id']);
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                  },
                ),
              );
            }),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getAccountIcon(String type) {
    switch (type) {
      case 'checking':
        return 'account_balance';
      case 'savings':
        return 'savings';
      case 'credit':
        return 'credit_card';
      case 'cash':
        return 'payments';
      default:
        return 'account_balance_wallet';
    }
  }

  Color _getAccountColor(String type, bool isDark) {
    switch (type) {
      case 'checking':
        return isDark ? const Color(0xFF4ECDC4) : const Color(0xFF1B365D);
      case 'savings':
        return isDark ? const Color(0xFF96CEB4) : const Color(0xFF0F7B0F);
      case 'credit':
        return isDark ? const Color(0xFFE85A61) : const Color(0xFFC5282F);
      case 'cash':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFB7791F);
      default:
        return isDark ? const Color(0xFF6BA5B8) : const Color(0xFF4A90A4);
    }
  }

  String _formatBalance(double balance) {
    if (balance >= 0) {
      return '\$${balance.toStringAsFixed(2)}';
    } else {
      return '-\$${balance.abs().toStringAsFixed(2)}';
    }
  }
}
