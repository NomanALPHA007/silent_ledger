import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String illustration;

  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero illustration (top third)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: 30.h,
                maxWidth: 80.w,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large icon
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: icon,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 10.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Illustration image
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 25.h,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomImageWidget(
                          imageUrl: illustration,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Content area (center)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 2.h),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
