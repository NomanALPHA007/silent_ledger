import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricAuthWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onBiometricAuth;

  const BiometricAuthWidget({
    super.key,
    required this.isLoading,
    required this.onBiometricAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Quick Access',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 2.h),

        // Biometric Button
        GestureDetector(
          onTap: isLoading ? null : onBiometricAuth,
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'fingerprint',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 8.w,
                    ),
            ),
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Use Biometric',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
