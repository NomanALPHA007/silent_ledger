import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/verification_actions_widget.dart';
import './widgets/verification_header_widget.dart';
import './widgets/verification_timer_widget.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  bool _isVerifying = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  Timer? _verificationCheckTimer;
  final String _userEmail = "user@example.com"; // Mock email

  // Mock verification state
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startResendCountdown();
    _startPeriodicVerificationCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerificationStatus();
    }
  }

  void _startResendCountdown() {
    _canResend = false;
    _resendCountdown = 60;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _startPeriodicVerificationCheck() {
    _verificationCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && !_isVerifying) {
        _checkVerificationStatus(showLoading: false);
      }
    });
  }

  Future<void> _checkVerificationStatus({bool showLoading = true}) async {
    if (_isVerifying) return;

    if (showLoading) {
      setState(() {
        _isVerifying = true;
      });
    }

    try {
      // Simulate Firebase auth state check
      await Future.delayed(const Duration(seconds: 2));

      // Mock verification check - randomly verify after some attempts
      if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
        _isEmailVerified = true;
      }

      if (_isEmailVerified) {
        _onVerificationSuccess();
        return;
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
            'Failed to check verification status. Please try again.');
      }
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _onVerificationSuccess() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Email verified successfully!',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to dashboard after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard-screen',
          (route) => false,
        );
      }
    });
  }

  Future<void> _openEmailApp() async {
    try {
      // Mock opening email app
      HapticFeedback.selectionClick();

      // Show feedback that email app would open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Opening email app...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      _showErrorSnackBar(
          'Could not open email app. Please check your email manually.');
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    try {
      setState(() {
        _isVerifying = true;
      });

      // Simulate resending verification email
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification email sent to $_userEmail',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );

        _startResendCountdown();
      }
    } catch (e) {
      _showErrorSnackBar(
          'Failed to resend verification email. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _changeEmailAddress() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.onError,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // Header with back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Email Verification',
                        textAlign: TextAlign.center,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w), // Balance the back button
                  ],
                ),

                SizedBox(height: 6.h),

                // Verification header
                VerificationHeaderWidget(userEmail: _userEmail),

                SizedBox(height: 6.h),

                // Main action buttons
                VerificationActionsWidget(
                  isVerifying: _isVerifying,
                  onOpenEmailApp: _openEmailApp,
                  onManualCheck: () => _checkVerificationStatus(),
                ),

                SizedBox(height: 4.h),

                // Resend timer and button
                VerificationTimerWidget(
                  canResend: _canResend,
                  countdown: _resendCountdown,
                  isVerifying: _isVerifying,
                  onResend: _resendVerificationEmail,
                ),

                SizedBox(height: 6.h),

                // Change email link
                TextButton(
                  onPressed: _changeEmailAddress,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                  child: Text(
                    'Change Email Address',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Help text
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Helpful Tips',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      _buildHelpTip('Check your spam or junk folder'),
                      SizedBox(height: 1.h),
                      _buildHelpTip('Verification link expires in 24 hours'),
                      SizedBox(height: 1.h),
                      _buildHelpTip('Contact support if you need assistance'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
