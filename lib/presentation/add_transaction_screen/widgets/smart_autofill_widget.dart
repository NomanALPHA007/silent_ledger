import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SmartAutofillWidget extends StatelessWidget {
  final Function(Map<String, String>) onAutofillData;
  final String? currentLocation;
  final TimeOfDay? currentTime;

  const SmartAutofillWidget({
    super.key,
    required this.onAutofillData,
    this.currentLocation,
    this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Smart Suggestions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Smart suggestions based on time/location
          _buildSmartSuggestions(theme),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(ThemeData theme) {
    final suggestions = _generateSmartSuggestions();

    if (suggestions.isEmpty) {
      return Text(
        'No suggestions available',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: suggestions
          .map((suggestion) => _buildSuggestionItem(theme, suggestion))
          .toList(),
    );
  }

  Widget _buildSuggestionItem(ThemeData theme, Map<String, String> suggestion) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: InkWell(
        onTap: () => onAutofillData(suggestion),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(51),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: _getCategoryColor(suggestion['category'] ?? '')
                      .withAlpha(51),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomIconWidget(
                  iconName: suggestion['icon'] ?? 'receipt',
                  color: _getCategoryColor(suggestion['category'] ?? ''),
                  size: 16,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['description'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (suggestion['reason'] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        suggestion['reason']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (suggestion['amount'] != null) ...[
                SizedBox(width: 2.w),
                Text(
                  '\$${suggestion['amount']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _generateSmartSuggestions() {
    final suggestions = <Map<String, String>>[];
    final now = DateTime.now();
    final timeOfDay = TimeOfDay.now();

    // Time-based suggestions
    if (timeOfDay.hour >= 7 && timeOfDay.hour <= 10) {
      suggestions.add({
        'description': 'Coffee Shop',
        'category': 'Food & Dining',
        'amount': '4.50',
        'icon': 'local_cafe',
        'reason': 'Morning coffee time',
        'confidence': 'high',
      });
    }

    if (timeOfDay.hour >= 12 && timeOfDay.hour <= 14) {
      suggestions.add({
        'description': 'Lunch',
        'category': 'Food & Dining',
        'amount': '12.50',
        'icon': 'restaurant',
        'reason': 'Lunch time',
        'confidence': 'medium',
      });
    }

    if (timeOfDay.hour >= 17 && timeOfDay.hour <= 20) {
      suggestions.add({
        'description': 'Dinner',
        'category': 'Food & Dining',
        'amount': '25.00',
        'icon': 'dinner_dining',
        'reason': 'Dinner time',
        'confidence': 'medium',
      });
    }

    // Weekend suggestions
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      suggestions.add({
        'description': 'Grocery Shopping',
        'category': 'Shopping',
        'amount': '85.00',
        'icon': 'shopping_cart',
        'reason': 'Weekend shopping',
        'confidence': 'medium',
      });
    }

    // Weekday suggestions
    if (now.weekday >= DateTime.monday && now.weekday <= DateTime.friday) {
      if (timeOfDay.hour >= 7 && timeOfDay.hour <= 9) {
        suggestions.add({
          'description': 'Commute',
          'category': 'Transportation',
          'amount': '3.50',
          'icon': 'directions_transit',
          'reason': 'Morning commute',
          'confidence': 'high',
        });
      }

      if (timeOfDay.hour >= 17 && timeOfDay.hour <= 19) {
        suggestions.add({
          'description': 'Gas Station',
          'category': 'Transportation',
          'amount': '45.00',
          'icon': 'local_gas_station',
          'reason': 'Evening commute',
          'confidence': 'medium',
        });
      }
    }

    // Monthly recurring suggestions (first few days of month)
    if (now.day <= 5) {
      suggestions.add({
        'description': 'Rent Payment',
        'category': 'Bills & Utilities',
        'amount': '1200.00',
        'icon': 'home',
        'reason': 'Monthly rent due',
        'confidence': 'low',
      });

      suggestions.add({
        'description': 'Internet Bill',
        'category': 'Bills & Utilities',
        'amount': '79.99',
        'icon': 'wifi',
        'reason': 'Monthly bill',
        'confidence': 'medium',
      });
    }

    // Location-based suggestions (mock)
    if (currentLocation != null) {
      if (currentLocation!.toLowerCase().contains('mall') ||
          currentLocation!.toLowerCase().contains('shopping')) {
        suggestions.add({
          'description': 'Shopping',
          'category': 'Shopping',
          'amount': '50.00',
          'icon': 'shopping_bag',
          'reason': 'At shopping location',
          'confidence': 'high',
        });
      }

      if (currentLocation!.toLowerCase().contains('gas') ||
          currentLocation!.toLowerCase().contains('fuel')) {
        suggestions.add({
          'description': 'Fuel',
          'category': 'Transportation',
          'amount': '45.00',
          'icon': 'local_gas_station',
          'reason': 'At gas station',
          'confidence': 'high',
        });
      }
    }

    // Limit to top 3 suggestions
    return suggestions.take(3).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return const Color(0xFFFF6B6B);
      case 'transportation':
        return const Color(0xFF4ECDC4);
      case 'shopping':
        return const Color(0xFF45B7D1);
      case 'bills & utilities':
        return const Color(0xFFFECA57);
      case 'entertainment':
        return const Color(0xFF96CEB4);
      case 'healthcare':
        return const Color(0xFFFF9FF3);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}
