import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AdminHeaderWidget extends StatelessWidget {
  final AnimationController animation;
  final String systemStatus;
  final double totalRevenue;
  final int totalUsers;
  final int activeApiClients;

  const AdminHeaderWidget({
    super.key,
    required this.animation,
    required this.systemStatus,
    required this.totalRevenue,
    required this.totalUsers,
    required this.activeApiClients,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1976D2),
                const Color(0xFF1565C0),
                const Color(0xFF0D47A1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin badge and system health
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.white.withAlpha(77)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildSystemHealthIndicator(),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Main title
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'Comprehensive system oversight and analytics',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Key metrics cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.attach_money,
                          title: 'Total Revenue',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          color: Colors.green[400]!,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.people,
                          title: 'Users',
                          value: totalUsers.toString(),
                          color: Colors.orange[400]!,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.api,
                          title: 'API Clients',
                          value: activeApiClients.toString(),
                          color: Colors.purple[400]!,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealthIndicator() {
    Color statusColor;
    IconData statusIcon;

    switch (systemStatus) {
      case 'Healthy':
        statusColor = Colors.green[400]!;
        statusIcon = Icons.check_circle;
        break;
      case 'Warning':
        statusColor = Colors.orange[400]!;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.blue[400]!;
        statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 16.sp,
          ),
          SizedBox(width: 2.w),
          Text(
            systemStatus,
            style: TextStyle(
              color: statusColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withAlpha(204),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
