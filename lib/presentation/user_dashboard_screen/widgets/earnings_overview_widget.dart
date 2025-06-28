import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class EarningsOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> walletData;
  final AnimationController animation;

  const EarningsOverviewWidget({
    super.key,
    required this.walletData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: _buildEarningsContent(),
          ),
        );
      },
    );
  }

  Widget _buildEarningsContent() {
    final totalEarned = (walletData['total_earned'] ?? 0.0).toDouble();
    final silentCoins = (walletData['silent_coins'] ?? 0.0).toDouble();
    final royaltyBalance = (walletData['royalty_balance'] ?? 0.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings Overview',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),

        SizedBox(height: 3.h),

        Row(
          children: [
            Expanded(
              child: _buildEarningCard(
                'Silent Coins',
                '${silentCoins.toInt()}',
                'SC',
                Icons.monetization_on_rounded,
                const Color(0xFFFFB300),
                'From transactions',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildEarningCard(
                'Royalty',
                'RM ${royaltyBalance.toStringAsFixed(2)}',
                '',
                Icons.diamond_rounded,
                const Color(0xFF7B1FA2),
                'From referrals',
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Total earnings summary
        _buildTotalEarningsSummary(totalEarned),
      ],
    );
  }

  Widget _buildEarningCard(
    String title,
    String amount,
    String suffix,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 5.w,
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: Colors.green[600],
                size: 4.w,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(
                    begin: 0.0,
                    end: double.tryParse(
                            amount.replaceAll(RegExp(r'[^\d.]'), '')) ??
                        0.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    amount.contains('RM')
                        ? 'RM ${value.toStringAsFixed(2)}'
                        : '${value.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  );
                },
              ),
              if (suffix.isNotEmpty) ...[
                SizedBox(width: 1.w),
                Text(
                  suffix,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(179),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsSummary(double totalEarned) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32).withAlpha(26),
            const Color(0xFF4CAF50).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF2E7D32),
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Lifetime Earnings',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      'All your earnings combined',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.0, end: totalEarned),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                  ),
                  Text(
                    'Silent Coins',
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

          SizedBox(height: 3.h),

          // Progress towards next milestone
          _buildMilestoneProgress(totalEarned),
        ],
      ),
    );
  }

  Widget _buildMilestoneProgress(double totalEarned) {
    final milestones = [100, 500, 1000, 2500, 5000, 10000];
    final nextMilestone = milestones.firstWhere(
      (milestone) => milestone > totalEarned,
      orElse: () => milestones.last,
    );
    final progress = totalEarned / nextMilestone;
    final remaining = nextMilestone - totalEarned;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next Milestone',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${remaining.toInt()} SC to go',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          minHeight: 1.h,
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${totalEarned.toInt()} SC',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$nextMilestone SC',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
