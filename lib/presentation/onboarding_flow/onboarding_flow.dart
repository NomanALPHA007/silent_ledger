import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "id": 1,
      "icon": "security",
      "title": "Your Financial Privacy Matters",
      "description":
          "Keep your financial data secure with local storage and end-to-end encryption. Your sensitive information never leaves your device.",
      "illustration":
          "https://images.unsplash.com/photo-1563013544-824ae1b704d3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJpdmFjeXxlbnwwfHwwfHx8MA%3D%3D"
    },
    {
      "id": 2,
      "icon": "fingerprint",
      "title": "Biometric Security",
      "description":
          "Access your financial ledger with fingerprint or face recognition. Advanced security that's both convenient and secure.",
      "illustration":
          "https://images.unsplash.com/photo-1614064641938-3bbee52942c7?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YmlvbWV0cmljfGVufDB8fDB8fHww"
    },
    {
      "id": 3,
      "icon": "language",
      "title": "Multi-Currency Support",
      "description":
          "Track expenses and income in multiple currencies. Perfect for international transactions and global financial management.",
      "illustration":
          "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y3VycmVuY3l8ZW58MHx8MHx8fDA%3D"
    },
    {
      "id": 4,
      "icon": "offline_bolt",
      "title": "Work Offline",
      "description":
          "Continue managing your finances even without internet connection. All data syncs automatically when you're back online.",
      "illustration":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8b2ZmbGluZXxlbnwwfHwwfHx8MA%3D%3D"
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRegistration();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _navigateToRegistration();
  }

  void _navigateToRegistration() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    icon: data["icon"] as String,
                    title: data["title"] as String,
                    description: data["description"] as String,
                    illustration: data["illustration"] as String,
                  );
                },
              ),
            ),

            // Bottom navigation area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  // Page indicators
                  PageIndicatorWidget(
                    currentPage: _currentPage,
                    totalPages: _onboardingData.length,
                  ),

                  SizedBox(height: 4.h),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                        elevation: 2,
                        shadowColor: AppTheme.lightTheme.colorScheme.shadow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
