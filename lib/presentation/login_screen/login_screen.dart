import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  // Mock user data for authentication
  final Map<String, dynamic> _mockUsers = {
    "admin@silentledger.com": {
      "password": "Admin123!",
      "name": "Admin User",
      "hasBiometric": true,
    },
    "user@silentledger.com": {
      "password": "User123!",
      "name": "Regular User",
      "hasBiometric": false,
    },
    "demo@silentledger.com": {
      "password": "Demo123!",
      "name": "Demo User",
      "hasBiometric": true,
    }
  };

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadSavedCredentials() {
    // Simulate loading saved credentials
    if (_rememberMe) {
      _emailController.text = "demo@silentledger.com";
    }
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;

      if (_emailController.text.isEmpty) {
        _emailError = "Email is required";
      } else if (!_validateEmail(_emailController.text)) {
        _emailError = "Please enter a valid email";
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = "Password is required";
      } else if (!_validatePassword(_passwordController.text)) {
        _passwordError = "Password must be at least 6 characters";
      }
    });
  }

  Future<void> _handleLogin() async {
    _validateForm();

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Check mock credentials
      if (_mockUsers.containsKey(email)) {
        final userData = _mockUsers[email] as Map<String, dynamic>;
        if (userData["password"] == password) {
          // Success - trigger haptic feedback
          HapticFeedback.lightImpact();

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard-screen');
          }
        } else {
          _showErrorMessage("Invalid password. Please try again.");
        }
      } else {
        _showErrorMessage(
            "Account not found. Please check your email or sign up.");
      }
    } catch (e) {
      _showErrorMessage(
          "Network error. Please check your connection and try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/password-reset-screen');
  }

  void _handleSignUp() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  void _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      _showErrorMessage(
          "Biometric authentication failed. Please try again or use password.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate social login
      await Future.delayed(const Duration(seconds: 2));

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      _showErrorMessage("$provider login failed. Please try again.");
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
        child: KeyboardAvoidingBehavior(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 6.h),

                // App Logo
                _buildLogo(),

                SizedBox(height: 6.h),

                // Welcome Text
                _buildWelcomeText(),

                SizedBox(height: 4.h),

                // Login Form
                LoginFormWidget(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isPasswordVisible: _isPasswordVisible,
                  emailError: _emailError,
                  passwordError: _passwordError,
                  rememberMe: _rememberMe,
                  isLoading: _isLoading,
                  onPasswordVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onRememberMeChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  onForgotPassword: _handleForgotPassword,
                  onLogin: _handleLogin,
                ),

                SizedBox(height: 3.h),

                // Biometric Authentication
                BiometricAuthWidget(
                  isLoading: _isLoading,
                  onBiometricAuth: _handleBiometricAuth,
                ),

                SizedBox(height: 4.h),

                // Divider
                _buildDivider(),

                SizedBox(height: 4.h),

                // Social Login
                SocialLoginWidget(
                  isLoading: _isLoading,
                  onSocialLogin: _handleSocialLogin,
                ),

                SizedBox(height: 6.h),

                // Sign Up Link
                _buildSignUpLink(),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'account_balance_wallet',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 8.w,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign in to access your secure financial ledger',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
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
            'OR',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New user? ',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _handleSignUp,
          child: Text(
            'Sign Up',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class KeyboardAvoidingBehavior extends StatelessWidget {
  final Widget child;

  const KeyboardAvoidingBehavior({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: child,
          ),
        );
      },
    );
  }
}
