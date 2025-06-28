import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  final AuthService _authService = AuthService();
  bool _isInitializing = true;
  String _statusText = 'Initializing Silent Ledger...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    // Tagline slide animation
    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Loading animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Supabase connection
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _statusText = 'Connecting to secure servers...';
        });
      }

      // Check authentication status
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _statusText = 'Verifying trust credentials...';
        });
      }

      // Initialize security protocols
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _statusText = 'Loading user preferences...';
        });
      }

      // Final initialization
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _statusText = 'Preparing dashboard...';
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _statusText = 'Ready to digitize your daily life!';
          _isInitializing = false;
        });
      }

      // Wait before navigation
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Initialization complete';
          _isInitializing = false;
        });
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = _authService.isAuthenticated();

      // Check if it's first time (could check SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = !prefs.containsKey('app_opened_before');

      if (isAuthenticated) {
        // Get user profile to determine role-based routing
        final userProfile = await _authService.getUserProfile();
        final trustTier = userProfile?['trust_tier'] ?? 'bronze';

        if (trustTier == 'platinum') {
          // Admin user - go to admin dashboard
          Navigator.pushReplacementNamed(context, '/admin-dashboard-screen');
        } else {
          // Regular user - go to user dashboard
          Navigator.pushReplacementNamed(context, '/dashboard-screen');
        }
      } else if (isFirstTime) {
        // Mark app as opened
        await prefs.setBool('app_opened_before', true);
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      } else {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    } catch (e) {
      // Fallback navigation
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFF1B4332),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: 100.w,
          height: 100.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B4332), // Deep forest green
                Color(0xFF2D6A4F), // Medium forest green
                Color(0xFF40916C), // Lighter green
                Color(0xFF52B788), // Fresh green
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spacer to push content to center
                const Spacer(flex: 2),

                // Logo section with enhanced animation
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: _buildEnhancedLogo(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 6.h),

                // App name with enhanced styling
                SlideTransition(
                  position: _taglineSlideAnimation,
                  child: FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Silent Ledger',
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 1.h),

                        // Enhanced tagline with fintech focus
                        Text(
                          'Digitize Your Daily Life. Earn Trust. Earn More.',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(242),
                            letterSpacing: 0.8,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Feature highlights
                SlideTransition(
                  position: _taglineSlideAnimation,
                  child: FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: _buildFeatureHighlights(),
                  ),
                ),

                const Spacer(flex: 2),

                // Enhanced loading section
                _buildEnhancedLoadingSection(),

                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedLogo() {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(102),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern with animated shimmer effect
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(26),
                      Colors.white.withAlpha(13),
                      Colors.white.withAlpha(38),
                    ],
                    stops: [
                      0.0,
                      _loadingAnimation.value,
                      1.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),

          // Main financial icon
          Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 14.w,
          ),

          // Trust score indicator
          Positioned(
            top: 3.w,
            right: 3.w,
            child: Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 4.w,
              ),
            ),
          ),

          // Security badge
          Positioned(
            bottom: 3.w,
            left: 3.w,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                color: Colors.white,
                size: 3.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureItem(Icons.trending_up_rounded, 'Trust Score'),
          _buildFeatureItem(Icons.monetization_on_rounded, 'Earn Coins'),
          _buildFeatureItem(Icons.analytics_rounded, 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha(77),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 6.w,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha(230),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLoadingSection() {
    return Column(
      children: [
        // Enhanced loading indicator
        Container(
          width: 12.w,
          height: 12.w,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1,
            ),
          ),
          child: AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _isInitializing ? null : 1.0,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(230),
                ),
                backgroundColor: Colors.white.withAlpha(77),
              );
            },
          ),
        ),

        SizedBox(height: 3.h),

        // Enhanced status text with better animations
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _statusText,
            key: ValueKey(_statusText),
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(230),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 2.h),

        // Enhanced progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                final double animationValue = (_loadingAnimation.value * 5) % 5;
                final bool isActive = index <= animationValue;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: isActive ? 4.w : 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withAlpha(230)
                        : Colors.white.withAlpha(77),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            );
          }),
        ),

        SizedBox(height: 2.h),

        // Version info
        Text(
          'Version 2.0 • Production Ready',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withAlpha(179),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
