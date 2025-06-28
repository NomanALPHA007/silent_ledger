import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEmailSent = false;
  bool _isValidEmail = false;
  bool _showResendOption = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isValidEmail = emailRegex.hasMatch(email);
    });
  }

  Future<void> _sendResetEmail() async {
    if (!_isValidEmail || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Firebase password reset request
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });

      // Start timer for resend option
      _startResendTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() {
          _showResendOption = true;
        });
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _resendCooldown = 60;
      _showResendOption = false;
    });

    try {
      // Simulate resend request
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset email sent again. Please check your inbox.'),
        ),
      );

      // Countdown timer
      for (int i = 60; i > 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _resendCooldown = i - 1;
          });
        }
      }

      if (mounted) {
        setState(() {
          _showResendOption = true;
        });
      }
    } catch (e) {
      setState(() {
        _resendCooldown = 0;
        _showResendOption = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Reset Password',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: _isEmailSent ? _buildSuccessView() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 4.h),

        // Mail icon
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'mail_outline',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Header text
        Text(
          'Forgot Password?',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Helper text
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // Email form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: AppTheme.lightTheme.textTheme.labelLarge,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  suffixIcon: _isValidEmail
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.getSuccessColor(true),
                          size: 20,
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!_isValidEmail) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Send reset email button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isValidEmail && !_isLoading ? _sendResetEmail : null,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Send Reset Email',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 4.h),

        // Back to sign in
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login-screen'),
          child: Text(
            'Back to Sign In',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 4.h),

        // Success checkmark icon
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Success header
        Text(
          'Check Your Email',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Success message
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        Text(
          'Please check your email and follow the instructions to reset your password. The link will expire in 24 hours.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // Resend section
        if (_showResendOption || _resendCooldown > 0) ...[
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Didn\'t receive the email?',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                if (_resendCooldown > 0) ...[
                  Text(
                    'You can resend the email in ${_resendCooldown}s',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resendEmail,
                          child: Text('Resend Email'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Check your spam folder if you don\'t see the email',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],

        // Back to sign in button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/login-screen'),
            child: Text(
              'Back to Sign In',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
