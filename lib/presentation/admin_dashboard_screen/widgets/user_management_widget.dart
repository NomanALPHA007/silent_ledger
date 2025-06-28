import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserManagementWidget extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final AnimationController animation;

  const UserManagementWidget({
    super.key,
    required this.userStats,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
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
                        color: const Color(0xFF2196F3).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_alt,
                        color: const Color(0xFF2196F3),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Management',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Active users and trust score distribution',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDrillDownButton(),
                  ],
                ),

                SizedBox(height: 4.h),

                // Total users and transaction volume
                _buildUserOverviewCards(),

                SizedBox(height: 3.h),

                // Trust tier distribution
                _buildTrustTierDistribution(),

                SizedBox(height: 3.h),

                // Growth metrics
                _buildGrowthMetrics(),

                SizedBox(height: 3.h),

                // Recent user registrations
                _buildRecentUsers(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrillDownButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          // TODO: Navigate to detailed user management
        },
        icon: Icon(
          Icons.analytics,
          color: const Color(0xFF2196F3),
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildUserOverviewCards() {
    final totalUsers = userStats['total_users'] ?? 0;
    final totalVolume =
        userStats['total_transaction_volume']?.toDouble() ?? 0.0;
    final verifiedTransactions = userStats['verified_transactions'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Users',
            value: totalUsers.toString(),
            subtitle: 'Registered accounts',
            icon: Icons.person_add,
            color: const Color(0xFF4CAF50),
            trend: '+12%',
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            title: 'Transaction Volume',
            value: '\$${_formatNumber(totalVolume)}',
            subtitle: 'Total verified',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF2196F3),
            trend: '+8%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              if (trend != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustTierDistribution() {
    final usersByTier = Map<String, int>.from(userStats['users_by_tier'] ?? {});
    final totalUsers = userStats['total_users'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trust Score Distribution',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        ...['platinum', 'gold', 'silver', 'bronze'].map((tier) {
          final count = usersByTier[tier] ?? 0;
          final percentage = totalUsers > 0 ? (count / totalUsers) * 100 : 0.0;

          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: _getTierColor(tier),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _formatTierName(tier),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$count users (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getTierColor(tier)),
                  minHeight: 0.8.h,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGrowthMetrics() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withAlpha(26),
            const Color(0xFF1976D2).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withAlpha(51)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth Insights',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.green[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '+15% user growth this month',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Colors.blue[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '73% trust score improvement',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.insights,
              color: const Color(0xFF2196F3),
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers() {
    final recentUsers = List<Map<String, dynamic>>.from(
      userStats['recent_users'] ?? [],
    );

    if (recentUsers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No recent user registrations',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Registrations',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all users
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...recentUsers.take(5).map((user) {
          return Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundColor:
                      _getTierColor(user['trust_tier'] ?? 'bronze'),
                  child: Text(
                    (user['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        user['email'] ?? 'no-email',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getTierColor(user['trust_tier'] ?? 'bronze')
                            .withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTierName(user['trust_tier'] ?? 'bronze'),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getTierColor(user['trust_tier'] ?? 'bronze'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Score: ${double.tryParse(user['trust_score']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'platinum':
        return const Color(0xFF9C27B0);
      case 'gold':
        return const Color(0xFFFF9800);
      case 'silver':
        return const Color(0xFF607D8B);
      case 'bronze':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }

  String _formatTierName(String tier) {
    return tier.substring(0, 1).toUpperCase() + tier.substring(1);
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}
