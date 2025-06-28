import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VerificationActionsWidget extends StatelessWidget {
  final bool isVerifying;
  final VoidCallback onOpenEmailApp;
  final VoidCallback onManualCheck;

  const VerificationActionsWidget({
    super.key,
    required this.isVerifying,
    required this.onOpenEmailApp,
    required this.onManualCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary action - Open Email App
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: ElevatedButton.icon(
            onPressed: isVerifying ? null : onOpenEmailApp,
            icon: CustomIconWidget(
              iconName: 'open_in_new',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
            label: Text(
              'Open Email App',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              elevation: 2,
              shadowColor: AppTheme.lightTheme.colorScheme.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Secondary action - Manual verification check
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: OutlinedButton.icon(
            onPressed: isVerifying ? null : onManualCheck,
            icon: isVerifying
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
            label: Text(
              isVerifying ? 'Checking...' : 'I\'ve Verified',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
