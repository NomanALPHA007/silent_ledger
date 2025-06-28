import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;
  final Function(String) onSocialLogin;

  const SocialLoginWidget({
    super.key,
    required this.isLoading,
    required this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Continue with',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            // Google Login Button
            Expanded(
              child: _buildSocialButton(
                label: 'Google',
                iconName: 'g_translate',
                onTap: () => onSocialLogin('Google'),
              ),
            ),

            SizedBox(width: 4.w),

            // Apple Login Button
            Expanded(
              child: _buildSocialButton(
                label: 'Apple',
                iconName: 'apple',
                onTap: () => onSocialLogin('Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 7.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow
                  .withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
