import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/registration_form_widget.dart';
import './widgets/social_registration_widget.dart';
import './widgets/terms_privacy_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _acceptTerms = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    setState(() {
      if (email.isEmpty) {
        _isEmailValid = false;
        _emailError = null;
      } else if (emailRegex.hasMatch(email)) {
        _isEmailValid = true;
        _emailError = null;
      } else {
        _isEmailValid = false;
        _emailError = 'Please enter a valid email address';
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      if (password.isEmpty) {
        _isPasswordValid = false;
        _passwordError = null;
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
      } else {
        _calculatePasswordStrength(password);
        if (password.length >= 8) {
          _isPasswordValid = true;
          _passwordError = null;
        } else {
          _isPasswordValid = false;
          _passwordError = 'Password must be at least 8 characters';
        }
      }
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    final password = _passwordController.text;

    setState(() {
      if (confirmPassword.isEmpty) {
        _isConfirmPasswordValid = false;
        _confirmPasswordError = null;
      } else if (confirmPassword == password) {
        _isConfirmPasswordValid = true;
        _confirmPasswordError = null;
      } else {
        _isConfirmPasswordValid = false;
        _confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    if (strength <= 0.25) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 0.5) {
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else if (strength <= 0.75) {
      strengthText = 'Good';
      strengthColor = Colors.yellow;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }

    _passwordStrength = strength > 1.0 ? 1.0 : strength;
    _passwordStrengthText = strengthText;
    _passwordStrengthColor = strengthColor;
  }

  bool get _isFormValid {
    return _isEmailValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        _acceptTerms;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Firebase registration
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration scenarios
      final email = _emailController.text.toLowerCase();

      if (email == 'existing@test.com') {
        throw Exception(
            'The email address is already in use by another account.');
      } else if (email == 'network@error.com') {
        throw Exception(
            'A network error occurred. Please check your connection.');
      } else if (_passwordController.text == 'weakpass') {
        throw Exception(
            'The password is too weak. Please choose a stronger password.');
      }

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushNamed(context, '/email-verification-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Google Sign-In
      await Future.delayed(const Duration(seconds: 1));
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Sign-In failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Apple Sign-In
      await Future.delayed(const Duration(seconds: 1));
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Apple Sign-In failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: KeyboardAwareScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),

                // App Logo
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'account_balance_wallet',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 10.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  'Silent Ledger',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  'Create your secure account',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 4.h),

                // Registration Form
                RegistrationFormWidget(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isPasswordVisible: _isPasswordVisible,
                  isConfirmPasswordVisible: _isConfirmPasswordVisible,
                  isEmailValid: _isEmailValid,
                  isPasswordValid: _isPasswordValid,
                  isConfirmPasswordValid: _isConfirmPasswordValid,
                  emailError: _emailError,
                  passwordError: _passwordError,
                  confirmPasswordError: _confirmPasswordError,
                  passwordStrength: _passwordStrength,
                  passwordStrengthText: _passwordStrengthText,
                  passwordStrengthColor: _passwordStrengthColor,
                  isLoading: _isLoading,
                  onPasswordVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onConfirmPasswordVisibilityToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Terms and Privacy
                TermsPrivacyWidget(
                  acceptTerms: _acceptTerms,
                  onTermsChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),

                SizedBox(height: 4.h),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !_isLoading
                        ? _handleRegistration
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      elevation: _isFormValid ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.dividerColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'or',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Social Registration
                SocialRegistrationWidget(
                  isLoading: _isLoading,
                  onGoogleSignUp: _handleGoogleSignUp,
                  onAppleSignUp: _handleAppleSignUp,
                ),

                SizedBox(height: 4.h),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/login-screen');
                            },
                      child: Text(
                        'Sign In',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KeyboardAwareScrollView extends StatelessWidget {
  final Widget child;

  const KeyboardAwareScrollView({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
