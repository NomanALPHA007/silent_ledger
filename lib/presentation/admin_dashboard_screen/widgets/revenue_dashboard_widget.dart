import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueDashboardWidget extends StatelessWidget {
  final Map<String, dynamic> revenueData;
  final AnimationController animation;

  const RevenueDashboardWidget({
    super.key,
    required this.revenueData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
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
                        color: const Color(0xFF4CAF50).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: const Color(0xFF4CAF50),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revenue Analytics',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Platform earnings and subscription metrics',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildExportButton(),
                  ],
                ),

                SizedBox(height: 4.h),

                // Total revenue display
                _buildTotalRevenueCard(),

                SizedBox(height: 3.h),

                // Revenue breakdown by source
                _buildRevenueBreakdown(),

                SizedBox(height: 3.h),

                // Subscription metrics
                _buildSubscriptionMetrics(),

                SizedBox(height: 3.h),

                // Recent revenue transactions
                _buildRecentTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          // TODO: Export revenue data
        },
        icon: Icon(
          Icons.file_download,
          color: const Color(0xFF1976D2),
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard() {
    final totalRevenue = revenueData['total_revenue']?.toDouble() ?? 0.0;
    final monthlySubscriptionRevenue =
        revenueData['monthly_subscription_revenue']?.toDouble() ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Platform Revenue',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withAlpha(230),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.monetization_on,
                color: Colors.white.withAlpha(204),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '\$${totalRevenue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.autorenew,
                color: Colors.white.withAlpha(204),
                size: 16.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Monthly Recurring: \$${monthlySubscriptionRevenue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withAlpha(230),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final revenueBySource = Map<String, double>.from(
      revenueData['revenue_by_source'] ?? {},
    );

    if (revenueBySource.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No revenue data available',
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
        Text(
          'Revenue by Source',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
          child: PieChart(
            PieChartData(
              sections: _generatePieChartSections(revenueBySource),
              centerSpaceRadius: 8.w,
              sectionsSpace: 2,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        _buildRevenueLegend(revenueBySource),
      ],
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, double> revenueBySource) {
    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
    ];

    final total =
        revenueBySource.values.fold<double>(0, (sum, value) => sum + value);
    if (total == 0) return [];

    int colorIndex = 0;
    return revenueBySource.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 8.w,
        titleStyle: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildRevenueLegend(Map<String, double> revenueBySource) {
    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
    ];

    int colorIndex = 0;
    return Wrap(
      spacing: 4.w,
      runSpacing: 1.h,
      children: revenueBySource.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '${_formatSourceName(entry.key)}: \$${entry.value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionMetrics() {
    final subscriptionCounts = Map<String, int>.from(
      revenueData['subscription_counts'] ?? {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Tiers',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildSubscriptionTierCard(
                tier: 'Free',
                count: subscriptionCounts['free'] ?? 0,
                color: Colors.grey[600]!,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSubscriptionTierCard(
                tier: 'Pro',
                count: subscriptionCounts['pro'] ?? 0,
                color: const Color(0xFF1976D2),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSubscriptionTierCard(
                tier: 'Elite',
                count: subscriptionCounts['elite'] ?? 0,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionTierCard({
    required String tier,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            tier,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = List<Map<String, dynamic>>.from(
      revenueData['recent_transactions'] ?? [],
    );

    if (recentTransactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No recent transactions',
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
              'Recent Revenue',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all revenue transactions
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...recentTransactions.take(5).map((transaction) {
          return Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: const Color(0xFF4CAF50),
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatSourceName(transaction['source'] ?? 'Unknown'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        _formatDateTime(transaction['created_at']),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${double.tryParse(transaction['amount'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatSourceName(String source) {
    switch (source) {
      case 'subscription':
        return 'Subscription';
      case 'api_usage':
        return 'API Usage';
      case 'coin_store':
        return 'Coin Store';
      case 'loan_referral':
        return 'Loan Referral';
      case 'data_export':
        return 'Data Export';
      default:
        return source.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateTime.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
