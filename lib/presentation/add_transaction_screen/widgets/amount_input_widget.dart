import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpense;
  final ValueChanged<String>? onChanged;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.isExpense,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency Symbol
              Text(
                '\$',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: isExpense
                      ? theme.colorScheme.error
                      : AppTheme.getSuccessColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              // Amount Input
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: isExpense
                        ? theme.colorScheme.error
                        : AppTheme.getSuccessColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: onChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Quick Amount Buttons
          _buildQuickAmountButtons(theme),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(ThemeData theme) {
    final quickAmounts = ['10', '25', '50', '100'];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: quickAmounts.map((amount) {
        return InkWell(
          onTap: () {
            controller.text = amount;
            onChanged?.call(amount);
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '\$$amount',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
