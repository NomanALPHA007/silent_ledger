import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class MerchantQuickActionsWidget extends StatelessWidget {
  final VoidCallback onConfirmTransaction;
  final VoidCallback onViewAnalytics;
  final VoidCallback onManageSubscription;
  final VoidCallback onGenerateReports;
  final AnimationController animation;

  const MerchantQuickActionsWidget({
    super.key,
    required this.onConfirmTransaction,
    required this.onViewAnalytics,
    required this.onManageSubscription,
    required this.onGenerateReports,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuart),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 3.h),

              // Actions Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 3.w,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    'Confirm Transaction',
                    Icons.check_circle_outline,
                    Colors.green[600]!,
                    onConfirmTransaction,
                  ),
                  _buildActionCard(
                    'View Analytics',
                    Icons.analytics_outlined,
                    Colors.blue[600]!,
                    onViewAnalytics,
                  ),
                  _buildActionCard(
                    'Manage Subscription',
                    Icons.subscriptions_outlined,
                    Colors.orange[600]!,
                    onManageSubscription,
                  ),
                  _buildActionCard(
                    'Generate Reports',
                    Icons.description_outlined,
                    Colors.purple[600]!,
                    onGenerateReports,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 8.w,
              color: color,
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
