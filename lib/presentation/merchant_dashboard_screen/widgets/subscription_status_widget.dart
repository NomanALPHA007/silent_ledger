import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final Map<String, dynamic> subscriptionData;
  final AnimationController animation;
  final VoidCallback onUpgrade;

  const SubscriptionStatusWidget({
    super.key,
    required this.subscriptionData,
    required this.animation,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final tier = subscriptionData['tier']?.toString().toLowerCase() ?? 'free';
    final usagePercentage = _calculateUsagePercentage();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutQuart),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.1, 0.7, curve: Curves.easeIn),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Status',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getTierColor(tier).withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _getTierColor(tier).withAlpha(77)),
                        ),
                        child: Text(
                          '${tier.toUpperCase()} PLAN',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: _getTierColor(tier),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tier == 'free')
                    ElevatedButton(
                      onPressed: onUpgrade,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Upgrade',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 3.h),

              // Usage Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildUsageCard(
                      'Transactions',
                      '${subscriptionData['transactions_used'] ?? 0}',
                      '${subscriptionData['transaction_limit'] ?? 100}',
                      Icons.receipt_long,
                      Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildUsageCard(
                      'API Calls',
                      '${subscriptionData['api_calls_used'] ?? 0}',
                      '${subscriptionData['api_calls_limit'] ?? 1000}',
                      Icons.api,
                      Colors.green[600]!,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Usage Progress Bar
              Text(
                'Monthly Usage',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 1.h),

              LinearProgressIndicator(
                value: usagePercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercentage > 0.8 ? Colors.red[400]! : Colors.blue[600]!,
                ),
                minHeight: 1.h,
              ),
              SizedBox(height: 1.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(usagePercentage * 100).toInt()}% used',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (usagePercentage > 0.8)
                    Text(
                      'Consider upgrading',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 3.h),

              // Benefits Section
              _buildBenefitsSection(tier),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateUsagePercentage() {
    final transactionsUsed = subscriptionData['transactions_used'] ?? 0;
    final transactionLimit = subscriptionData['transaction_limit'] ?? 100;
    final apiCallsUsed = subscriptionData['api_calls_used'] ?? 0;
    final apiCallsLimit = subscriptionData['api_calls_limit'] ?? 1000;

    final transactionUsage =
        transactionLimit > 0 ? transactionsUsed / transactionLimit : 0.0;
    final apiUsage = apiCallsLimit > 0 ? apiCallsUsed / apiCallsLimit : 0.0;

    return ((transactionUsage + apiUsage) / 2).clamp(0.0, 1.0);
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'pro':
        return Colors.orange[600]!;
      case 'elite':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildUsageCard(
      String title, String used, String limit, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 18.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            '$used / $limit',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(String tier) {
    final benefits = _getTierBenefits(tier);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Benefits',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2.h),
          ...benefits.map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    Icon(
                      benefit['included'] ? Icons.check_circle : Icons.cancel,
                      color: benefit['included']
                          ? Colors.green[600]
                          : Colors.grey[400],
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        benefit['title'],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: benefit['included']
                              ? Colors.grey[700]
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTierBenefits(String tier) {
    switch (tier.toLowerCase()) {
      case 'pro':
        return [
          {'title': 'Enhanced Analytics', 'included': true},
          {'title': 'Priority Support', 'included': false},
          {'title': 'Custom Branding', 'included': false},
          {'title': 'Advanced API Access', 'included': true},
        ];
      case 'elite':
        return [
          {'title': 'Enhanced Analytics', 'included': true},
          {'title': 'Priority Support', 'included': true},
          {'title': 'Custom Branding', 'included': true},
          {'title': 'Advanced API Access', 'included': true},
        ];
      default:
        return [
          {'title': 'Enhanced Analytics', 'included': false},
          {'title': 'Priority Support', 'included': false},
          {'title': 'Custom Branding', 'included': false},
          {'title': 'Advanced API Access', 'included': false},
        ];
    }
  }
}
