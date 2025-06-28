import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerInsightsWidget extends StatelessWidget {
  final Map<String, dynamic> analyticsData;
  final AnimationController animation;

  const CustomerInsightsWidget({
    super.key,
    required this.analyticsData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final recentTransactions =
        analyticsData['recent_transactions'] as List<dynamic>? ?? [];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutQuart),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
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
                'Customer Insights',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 3.h),

              // Top Customers Section
              _buildTopCustomersSection(recentTransactions),

              SizedBox(height: 4.h),

              // Peak Hours Section
              _buildPeakHoursSection(),

              SizedBox(height: 4.h),

              // Relationship Building Suggestions
              _buildSuggestionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection(List<dynamic> transactions) {
    // Group transactions by customer and calculate totals
    final Map<String, Map<String, dynamic>> customerData = {};

    for (final transaction in transactions) {
      final userProfile = transaction['user_profiles'] as Map<String, dynamic>?;
      if (userProfile != null) {
        final userId = userProfile['id'] ?? '';
        final amount = (transaction['amount'] as num?)?.abs() ?? 0.0;

        if (customerData.containsKey(userId)) {
          customerData[userId]!['total_amount'] += amount;
          customerData[userId]!['transaction_count']++;
        } else {
          customerData[userId] = {
            'profile': userProfile,
            'total_amount': amount,
            'transaction_count': 1,
          };
        }
      }
    }

    // Sort by total amount and take top 3
    final topCustomers = customerData.values.toList()
      ..sort((a, b) =>
          (b['total_amount'] as double).compareTo(a['total_amount'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Customers by Volume',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        if (topCustomers.isEmpty)
          _buildEmptyCustomersState()
        else
          Column(
            children: topCustomers.take(3).map<Widget>((customer) {
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: _buildCustomerItem(customer),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyCustomersState() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 12.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No customer data yet',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Start getting transactions to see insights',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(Map<String, dynamic> customer) {
    final profile = customer['profile'] as Map<String, dynamic>;
    final totalAmount = customer['total_amount'] as double;
    final transactionCount = customer['transaction_count'] as int;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6.w,
            backgroundColor: Colors.blue[100],
            child: Text(
              (profile['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['full_name'] ?? 'Unknown Customer',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getTrustTierColor(profile['trust_tier']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (profile['trust_tier'] ?? 'bronze')
                            .toString()
                            .toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '$transactionCount transactions',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'RM ${totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrustTierColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'platinum':
        return Colors.purple[600]!;
      case 'gold':
        return Colors.yellow[700]!;
      case 'silver':
        return Colors.grey[500]!;
      default:
        return Colors.orange[600]!;
    }
  }

  Widget _buildPeakHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peak Business Hours',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.green[600],
                size: 18.sp,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Active: 12:00 PM - 2:00 PM',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      '65% of daily transactions occur during lunch hours',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    final suggestions = [
      {
        'title': 'Loyalty Program',
        'description': 'Create rewards for repeat customers',
        'icon': Icons.star_outline,
        'color': Colors.orange[600]!,
      },
      {
        'title': 'Peak Hour Promotions',
        'description': 'Offer discounts during slower periods',
        'icon': Icons.trending_up,
        'color': Colors.blue[600]!,
      },
      {
        'title': 'Trust Score Incentives',
        'description': 'Special offers for high-trust customers',
        'icon': Icons.verified_user,
        'color': Colors.green[600]!,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship Building Suggestions',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: suggestions.map((suggestion) {
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: (suggestion['color'] as Color).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (suggestion['color'] as Color).withAlpha(51)),
                ),
                child: Row(
                  children: [
                    Icon(
                      suggestion['icon'] as IconData,
                      color: suggestion['color'] as Color,
                      size: 18.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            suggestion['description'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
