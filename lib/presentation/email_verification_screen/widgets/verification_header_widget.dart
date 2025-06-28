import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VerificationHeaderWidget extends StatelessWidget {
  final String userEmail;

  const VerificationHeaderWidget({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Large mail icon
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'mail',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 12.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Main heading
        Text(
          'Check Your Email',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Description with email
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(
                text: 'We\'ve sent a verification link to\n',
              ),
              TextSpan(
                text: userEmail,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              const TextSpan(
                text:
                    '\n\nClick the link in your email to verify your account and continue to Silent Ledger.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
