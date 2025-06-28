import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class QuickAmountWidget extends StatelessWidget {
  final Function(double) onAmountSelected;
  final bool isExpense;

  const QuickAmountWidget({
    super.key,
    required this.onAmountSelected,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Different quick amounts based on transaction type
    final List<double> quickAmounts = isExpense
        ? [5.0, 10.0, 20.0, 50.0, 100.0, 200.0]
        : [100.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Tap to quickly select common amounts',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: quickAmounts
              .map((amount) => _buildQuickAmountChip(
                    context,
                    amount,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChip(BuildContext context, double amount) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onAmountSelected(amount);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.5.h,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(77),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(128),
            width: 1,
          ),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
