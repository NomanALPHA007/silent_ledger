import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AdminQuickActionsWidget extends StatelessWidget {
  final AnimationController animation;
  final VoidCallback onGenerateReport;
  final VoidCallback onManageApiKeys;
  final VoidCallback onReviewTransactions;
  final VoidCallback onSystemConfig;
  final int pendingAnomalies;

  const AdminQuickActionsWidget({
    super.key,
    required this.animation,
    required this.onGenerateReport,
    required this.onManageApiKeys,
    required this.onReviewTransactions,
    required this.onSystemConfig,
    required this.pendingAnomalies,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flash_on,
                        color: const Color(0xFF1976D2),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Admin Actions',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Fast access to critical admin functions',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pendingAnomalies > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingAnomalies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Action buttons grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionCard(
                      icon: Icons.assessment,
                      title: 'Generate Reports',
                      subtitle: 'System analytics',
                      color: const Color(0xFF4CAF50),
                      onTap: onGenerateReport,
                    ),
                    _buildActionCard(
                      icon: Icons.vpn_key,
                      title: 'Manage API Keys',
                      subtitle: 'Access control',
                      color: const Color(0xFF2196F3),
                      onTap: onManageApiKeys,
                    ),
                    _buildActionCard(
                      icon: Icons.flag,
                      title: 'Review Flagged',
                      subtitle: 'Transactions',
                      color: const Color(0xFFFF9800),
                      onTap: onReviewTransactions,
                      hasAlert: pendingAnomalies > 0,
                    ),
                    _buildActionCard(
                      icon: Icons.settings,
                      title: 'System Config',
                      subtitle: 'Platform settings',
                      color: const Color(0xFF9C27B0),
                      onTap: onSystemConfig,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool hasAlert = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: color.withAlpha(13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(51)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: color.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20.sp,
                    ),
                  ),
                  if (hasAlert)
                    Container(
                      width: 2.5.w,
                      height: 2.5.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
