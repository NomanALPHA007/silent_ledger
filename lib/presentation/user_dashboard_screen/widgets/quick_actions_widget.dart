import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onLogTransaction;
  final VoidCallback onCheckLoanEligibility;
  final VoidCallback onReferralProgram;
  final AnimationController animation;

  const QuickActionsWidget({
    super.key,
    required this.onLogTransaction,
    required this.onCheckLoanEligibility,
    required this.onReferralProgram,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: _buildActionsContent(),
          ),
        );
      },
    );
  }

  Widget _buildActionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
        SizedBox(height: 3.h),

        // Primary action - Log Transaction
        _buildPrimaryAction(),

        SizedBox(height: 3.h),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                'Check Loan\nEligibility',
                Icons.account_balance_rounded,
                const Color(0xFF1976D2),
                onCheckLoanEligibility,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSecondaryAction(
                'Referral\nProgram',
                Icons.people_rounded,
                const Color(0xFFE65100),
                onReferralProgram,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogTransaction,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Transaction',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Record your daily expenses and earn Silent Coins',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha(230),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 6.w,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
