import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/monetization_service.dart';
import '../../../services/auth_service.dart';

class SubscriptionPlansWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const SubscriptionPlansWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<SubscriptionPlansWidget> createState() =>
      _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
  final MonetizationService _monetizationService = MonetizationService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _currentPlan;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) return;

      final plan = await _monetizationService.getUserSubscriptionPlan(user.id);

      setState(() {
        _currentPlan = plan;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _upgradePlan(String tier) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return;

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Upgrade Subscription'),
                  content:
                      Text('Are you sure you want to upgrade to $tier plan?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32)),
                        child: const Text('Upgrade')),
                  ]));

      if (confirmed == true) {
        // In a real app, integrate with Stripe here
        await _monetizationService.updateSubscriptionTier(user.id, tier);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Successfully upgraded to $tier plan!'),
              backgroundColor: Colors.green));

          await _loadCurrentPlan();
          widget.onRefresh();
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upgrade plan: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_currentPlan != null) _buildCurrentPlanCard(),
          SizedBox(height: .20.h),
          Text('Available Plans',
              style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          _buildPlanCard(
              'Free',
              'RM 0.00',
              'Basic features for getting started',
              [
                '100 transactions/month',
                '1,000 API calls',
                'Basic analytics',
                'Email support',
              ],
              Colors.grey,
              'free'),
          _buildPlanCard(
              'Pro',
              'RM 29.99',
              'Perfect for growing businesses',
              [
                '1,000 transactions/month',
                '10,000 API calls',
                'Advanced analytics',
                'Priority support',
                'Custom reports',
              ],
              const Color(0xFF2E7D32),
              'pro'),
          _buildPlanCard(
              'Elite',
              'RM 99.99',
              'For enterprise-level operations',
              [
                'Unlimited transactions',
                '100,000 API calls',
                'Premium analytics',
                '24/7 phone support',
                'Custom branding',
                'Dedicated account manager',
              ],
              Colors.amber[600]!,
              'elite'),
        ]));
  }

  Widget _buildCurrentPlanCard() {
    final tier = _currentPlan!['tier'] ?? 'free';
    final price = _currentPlan!['monthly_price'] ?? 0.0;

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withAlpha(26),
            border: Border.all(color: const Color(0xFF2E7D32)),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.verified, color: const Color(0xFF2E7D32), size: 20.sp),
            SizedBox(width: 8.w),
            Text('Current Plan',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32))),
          ]),
          SizedBox(height: 12.h),
          Text(tier.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800])),
          Text('RM ${price.toStringAsFixed(2)}/month',
              style:
                  GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600])),
        ]));
  }

  Widget _buildPlanCard(String title, String price, String description,
      List<String> features, Color accentColor, String tier) {
    final isCurrentPlan = _currentPlan?['tier'] == tier;
    final canUpgrade = _shouldShowUpgradeButton(tier);

    return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: isCurrentPlan ? accentColor : Colors.grey[300]!,
                width: isCurrentPlan ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800])),
              Text('$price/month',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: accentColor,
                      fontWeight: FontWeight.w600)),
            ]),
            if (isCurrentPlan)
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('Current',
                      style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 8.h),
          Text(description,
              style:
                  GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 16.h),
          ...features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(children: [
                Icon(Icons.check, color: accentColor, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                    child: Text(feature,
                        style: GoogleFonts.inter(
                            fontSize: 13.sp, color: Colors.grey[700]))),
              ]))),
          SizedBox(height: 20.h),
          if (canUpgrade)
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => _upgradePlan(tier),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text('Upgrade to $title',
                        style: GoogleFonts.inter(
                            fontSize: 14.sp, fontWeight: FontWeight.w600))))
          else if (isCurrentPlan)
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text('Current Plan',
                        style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)))),
        ]));
  }

  bool _shouldShowUpgradeButton(String tier) {
    final currentTier = _currentPlan?['tier'] ?? 'free';

    switch (currentTier) {
      case 'free':
        return tier == 'pro' || tier == 'elite';
      case 'pro':
        return tier == 'elite';
      case 'elite':
        return false;
      default:
        return true;
    }
  }
}
