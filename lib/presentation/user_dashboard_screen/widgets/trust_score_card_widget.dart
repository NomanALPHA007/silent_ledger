import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TrustScoreCardWidget extends StatelessWidget {
  final Map<String, dynamic> trustData;
  final AnimationController animation;

  const TrustScoreCardWidget({
    super.key,
    required this.trustData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final score = (trustData['trust_score'] ?? 0.0).toDouble();
    final tier = trustData['trust_tier'] ?? 'bronze';
    final completeness =
        (trustData['completeness_percentage'] ?? 0.0).toDouble();
    final confirmations =
        (trustData['confirmation_percentage'] ?? 0.0).toDouble();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            ),
            child: _buildCard(score, tier, completeness, confirmations),
          ),
        );
      },
    );
  }

  Widget _buildCard(
      double score, String tier, double completeness, double confirmations) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withAlpha(242),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust Score',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  _buildTierBadge(tier),
                ],
              ),
              _buildScoreDisplay(score),
            ],
          ),

          SizedBox(height: 4.h),

          // Progress breakdown
          _buildProgressSection(completeness, confirmations),

          SizedBox(height: 3.h),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to trust score details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 2.w),
                  Text(
                    'Send to Lender',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    Color badgeColor;
    IconData icon;

    switch (tier.toLowerCase()) {
      case 'platinum':
        badgeColor = const Color(0xFFE5E7EB);
        icon = Icons.workspace_premium_rounded;
        break;
      case 'gold':
        badgeColor = const Color(0xFFFFD700);
        icon = Icons.star_rounded;
        break;
      case 'silver':
        badgeColor = const Color(0xFFC0C0C0);
        icon = Icons.star_half_rounded;
        break;
      default:
        badgeColor = const Color(0xFFCD7F32);
        icon = Icons.star_border_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 4.w,
            color: Colors.grey[800],
          ),
          SizedBox(width: 1.w),
          Text(
            tier.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(double score) {
    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
          ),

          // Progress circle
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: score / 100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                );
              },
            ),
          ),

          // Score text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: score),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${value.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _getScoreColor(score),
                    ),
                  );
                },
              ),
              Text(
                '/100',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double completeness, double confirmations) {
    return Column(
      children: [
        _buildProgressItem(
          'Profile Completeness',
          completeness,
          Icons.person_rounded,
          const Color(0xFF4CAF50),
        ),
        SizedBox(height: 2.h),
        _buildProgressItem(
          'Transaction Confirmations',
          confirmations,
          Icons.verified_rounded,
          const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildProgressItem(
      String label, double progress, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 5.w,
            color: color,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${progress.toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 1.h,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
