import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReceiptScannerWidget extends StatelessWidget {
  final String receiptImagePath;
  final Function(String imagePath, Map<String, String> extractedData)
      onReceiptScanned;

  const ReceiptScannerWidget({
    super.key,
    required this.receiptImagePath,
    required this.onReceiptScanned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Receipt',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Optional',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        receiptImagePath.isEmpty
            ? _buildScanButton(theme)
            : _buildReceiptPreview(theme),
      ],
    );
  }

  Widget _buildScanButton(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _showScanOptions(theme);
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: double.infinity,
        height: 12.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'Scan Receipt',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Auto-fill transaction details',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Receipt Thumbnail
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'receipt',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // Receipt Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Attached',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Data extracted successfully',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.dark),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _showReceiptPreview(theme);
                  HapticFeedback.lightImpact();
                },
                icon: CustomIconWidget(
                  iconName: 'visibility',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  _removeReceipt();
                  HapticFeedback.lightImpact();
                },
                icon: CustomIconWidget(
                  iconName: 'delete',
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScanOptions(ThemeData theme) {
    // In a real app, this would show camera/gallery options
    // For demo purposes, we'll simulate scanning
    _simulateReceiptScan();
  }

  void _simulateReceiptScan() {
    // Simulate OCR extraction
    final mockExtractedData = {
      'amount': '24.99',
      'description': 'Grocery Store Purchase',
      'merchant': 'SuperMart',
      'date': DateTime.now().toIso8601String(),
    };

    // Simulate image path
    const mockImagePath = '/mock/receipt/path.jpg';

    onReceiptScanned(mockImagePath, mockExtractedData);
  }

  void _showReceiptPreview(ThemeData theme) {
    // In a real app, this would show the full receipt image
    // For demo purposes, we'll show a placeholder dialog
    // This would typically use a full-screen image viewer
  }

  void _removeReceipt() {
    onReceiptScanned('', {});
  }
}
