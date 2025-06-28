import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FinancialSummaryCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const FinancialSummaryCardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.cardColor;
    final primaryTextColor = textColor ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: cardColor,
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
              children: [
                if (icon != null) ...[
                  CustomIconWidget(
                    iconName: icon
                        .toString()
                        .split('.')
                        .last
                        .replaceAll('IconData(U+', '')
                        .replaceAll(')', ''),
                    color: primaryTextColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primaryTextColor.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              amount,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primaryTextColor.withAlpha(153),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
