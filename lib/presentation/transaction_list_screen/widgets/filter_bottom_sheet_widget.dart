import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> filterOptions;
  final Function(Map<String, dynamic>, List<String>) onFiltersApplied;

  const FilterBottomSheetWidget({
    super.key,
    required this.filterOptions,
    required this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _tempFilters;
  DateTimeRange? _selectedDateRange;
  RangeValues _amountRange = RangeValues(0, 10000);

  final List<String> _availableCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Utilities',
    'Entertainment',
    'Healthcare',
    'Salary',
    'Investment',
  ];

  final List<String> _availableAccounts = [
    'Chase Checking',
    'Main Checking',
    'Credit Card',
    'Investment Account',
    'HSA Account',
  ];

  @override
  void initState() {
    super.initState();
    _tempFilters = Map.from(widget.filterOptions);
    _selectedDateRange = _tempFilters['dateRange'] as DateTimeRange?;
    final amountRangeMap = _tempFilters['amountRange'] as Map<String, dynamic>;
    _amountRange = RangeValues(
      amountRangeMap['min'] as double,
      amountRangeMap['max'] as double,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Transactions',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  _buildFilterSection(
                    title: 'Date Range',
                    child: _buildDateRangeFilter(),
                  ),

                  SizedBox(height: 3.h),

                  // Category Section
                  _buildFilterSection(
                    title: 'Categories',
                    child: _buildCategoryFilter(),
                  ),

                  SizedBox(height: 3.h),

                  // Amount Range Section
                  _buildFilterSection(
                    title: 'Amount Range',
                    child: _buildAmountRangeFilter(),
                  ),

                  SizedBox(height: 3.h),

                  // Account Section
                  _buildFilterSection(
                    title: 'Accounts',
                    child: _buildAccountFilter(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: AppTheme.lightTheme.elevatedButtonTheme.style,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        child,
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'date_range',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                    : 'Select date range',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: _selectedDateRange != null
                      ? AppTheme.lightTheme.colorScheme.onSurface
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_selectedDateRange != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final selectedCategories = _tempFilters['categories'] as List<String>;

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _availableCategories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
          labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountRangeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '\$${_amountRange.start.round()}',
            '\$${_amountRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _amountRange = values;
            });
          },
          activeColor: AppTheme.lightTheme.colorScheme.primary,
          inactiveColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_amountRange.start.round()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            Text(
              '\$${_amountRange.end.round()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountFilter() {
    final selectedAccounts = _tempFilters['accounts'] as List<String>;

    return Column(
      children: _availableAccounts.map((account) {
        final isSelected = selectedAccounts.contains(account);
        return CheckboxListTile(
          title: Text(
            account,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          value: isSelected,
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                selectedAccounts.add(account);
              } else {
                selectedAccounts.remove(account);
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _tempFilters = {
        'dateRange': null,
        'categories': <String>[],
        'amountRange': {'min': 0.0, 'max': 10000.0},
        'accounts': <String>[],
      };
      _selectedDateRange = null;
      _amountRange = RangeValues(0, 10000);
    });
  }

  void _applyFilters() {
    _tempFilters['dateRange'] = _selectedDateRange;
    _tempFilters['amountRange'] = {
      'min': _amountRange.start,
      'max': _amountRange.end,
    };

    final List<String> activeFilters = [];

    if (_selectedDateRange != null) {
      activeFilters.add('Date Range');
    }

    final categories = _tempFilters['categories'] as List<String>;
    for (final category in categories) {
      activeFilters.add('Category: $category');
    }

    if (_amountRange.start > 0 || _amountRange.end < 10000) {
      activeFilters.add('Amount Range');
    }

    final accounts = _tempFilters['accounts'] as List<String>;
    for (final account in accounts) {
      activeFilters.add('Account: $account');
    }

    widget.onFiltersApplied(_tempFilters, activeFilters);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
