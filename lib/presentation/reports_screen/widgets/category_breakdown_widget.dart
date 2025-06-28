import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categoryData;
  final String timeframe;

  const CategoryBreakdownWidget({
    super.key,
    required this.categoryData,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = categoryData.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );

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
                'Category Breakdown',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeframe,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...categoryData.map((data) => _buildCategoryItem(
                context,
                data,
                totalAmount,
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Map<String, dynamic> data,
    double totalAmount,
  ) {
    final theme = Theme.of(context);
    final percentage = (data['amount'] as double) / totalAmount;
    final percentageText = '${(percentage * 100).toStringAsFixed(1)}%';

    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Color(data['color'] as int).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: data['icon'] as String,
                    color: Color(data['color'] as int),
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
                          data['category'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          percentageText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${(data['amount'] as double).toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${data['transactions']} transactions',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: theme.colorScheme.outline.withAlpha(51),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(data['color'] as int),
            ),
            minHeight: 1.h,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
