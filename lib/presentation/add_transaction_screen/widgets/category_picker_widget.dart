import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryPickerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategoryPickerWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPickerWidget> createState() => _CategoryPickerWidgetState();
}

class _CategoryPickerWidgetState extends State<CategoryPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchController.text.isEmpty) {
      // Show frequent categories first
      final frequent =
          widget.categories.where((cat) => cat['isFrequent'] == true).toList();
      final others =
          widget.categories.where((cat) => cat['isFrequent'] != true).toList();
      return [...frequent, ...others];
    }

    final query = _searchController.text.toLowerCase();
    return widget.categories
        .where((cat) => (cat['name'] as String).toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = widget.categories.firstWhere(
      (cat) => cat['id'] == widget.selectedCategoryId,
      orElse: () => widget.categories.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                  }
                });
                HapticFeedback.lightImpact();
              },
              icon: CustomIconWidget(
                iconName: _showSearch ? 'close' : 'search',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ),

        if (_showSearch) ...[
          SizedBox(height: 1.h),
          TextFormField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],

        SizedBox(height: 1.h),

        // Selected Category Display
        if (!_showSearch)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color:
                        Color(selectedCategory['color']).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: selectedCategory['icon'],
                      color: Color(selectedCategory['color']),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    selectedCategory['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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

        SizedBox(height: 2.h),

        // Categories Grid
        Container(
          constraints: BoxConstraints(maxHeight: 30.h),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 3.5,
            ),
            itemCount:
                _filteredCategories.length + 1, // +1 for "Add New" option
            itemBuilder: (context, index) {
              if (index == _filteredCategories.length) {
                return _buildAddNewCategoryTile(theme);
              }

              final category = _filteredCategories[index];
              final isSelected = category['id'] == widget.selectedCategoryId;

              return GestureDetector(
                onTap: () {
                  widget.onCategorySelected(category['id']);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color:
                              Color(category['color']).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: category['icon'],
                            color: Color(category['color']),
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['name'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category['isFrequent'] == true)
                              Text(
                                'Frequent',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewCategoryTile(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _showAddNewCategoryDialog(theme);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'add',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Add New',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNewCategoryDialog(ThemeData theme) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // In a real app, this would add to the categories list
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Category "${nameController.text}" would be added'),
                  ),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
