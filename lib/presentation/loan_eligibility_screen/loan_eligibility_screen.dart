import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/trust_service.dart';
import '../../services/monetization_service.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final AuthService _authService = AuthService();
  final TrustService _trustService = TrustService();
  final MonetizationService _monetizationService = MonetizationService();

  Map<String, dynamic> _creditProfile = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _applicationSubmitted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _loadCreditProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCreditProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final profile = await _trustService.getCreditProfile(user.id);

      setState(() {
        _creditProfile = profile;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitLoanApplication(double amount, String partner) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return;

      await _monetizationService.createLoanReferral(
          loanAmount: amount, partnerName: partner);

      setState(() {
        _applicationSubmitted = true;
      });

      // Show success dialog
      _showSuccessDialog();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit application: $error'),
          backgroundColor: Colors.red));
    }
  }

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 6.w),
                  SizedBox(width: 3.w),
                  Text('Application Submitted!',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ]),
                content: Text(
                    'Your loan application has been submitted to our partner. You will receive a response within 24-48 hours.',
                    style: GoogleFonts.inter(fontSize: 14.sp, height: 1.4)),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Go back to dashboard
                      },
                      child: Text('OK',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32)))),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: Text('Loan Eligibility',
                style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context))),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : _errorMessage != null
                ? _buildErrorWidget()
                : _buildContent());
  }

  Widget _buildContent() {
    return SingleChildScrollView(
        child: Column(children: [
      // Header section
      Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)])),
          child: Padding(
              padding: EdgeInsets.all(6.w),
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.3), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.0, 0.6,
                                    curve: Curves.easeOutBack))),
                        child: _buildCreditScoreCard());
                  }))),

      // Main content
      Padding(
          padding: EdgeInsets.all(6.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0.3, 0), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 0.8,
                                  curve: Curves.easeOutBack))),
                      child: _buildEligibilitySection());
                }),
            SizedBox(height: 4.h),
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(-0.3, 0), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 1.0,
                                  curve: Curves.easeOutBack))),
                      child: _buildLoanOptionsSection());
                }),
          ])),
    ]));
  }

  Widget _buildCreditScoreCard() {
    final trustScore = (_creditProfile['trust_score'] ?? 0.0).toDouble();
    final tier = _creditProfile['trust_tier'] ?? 'bronze';
    final verifiedIncome =
        (_creditProfile['verified_income'] ?? 0.0).toDouble();

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ]),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Credit Profile',
                  style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32))),
              SizedBox(height: 1.h),
              _buildTierBadge(tier),
            ]),
            _buildScoreCircle(trustScore),
          ]),
          SizedBox(height: 4.h),
          Row(children: [
            Expanded(
                child: _buildProfileStat(
                    'Trust Score',
                    '${trustScore.toInt()}/100',
                    Icons.verified_user_rounded,
                    Colors.blue)),
            SizedBox(width: 4.w),
            Expanded(
                child: _buildProfileStat(
                    'Verified Income',
                    'RM ${verifiedIncome.toStringAsFixed(0)}',
                    Icons.account_balance_rounded,
                    Colors.green)),
          ]),
        ]));
  }

  Widget _buildTierBadge(String tier) {
    Color badgeColor;
    IconData icon;

    switch (tier.toLowerCase()) {
      case 'platinum':
        badgeColor = const Color(0xFFE5E7EB);
        icon = Icons.workspace_premium_rounded;
        break;
      case 'gold':
        badgeColor = const Color(0xFFFFD700);
        icon = Icons.star_rounded;
        break;
      case 'silver':
        badgeColor = const Color(0xFFC0C0C0);
        icon = Icons.star_half_rounded;
        break;
      default:
        badgeColor = const Color(0xFFCD7F32);
        icon = Icons.star_border_rounded;
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withAlpha(77), width: 1)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 4.w, color: Colors.grey[800]),
          SizedBox(width: 1.w),
          Text(tier.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  letterSpacing: 0.5)),
        ]));
  }

  Widget _buildScoreCircle(double score) {
    return SizedBox(
        width: 20.w,
        height: 20.w,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getScoreColor(score)))),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${score.toInt()}',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: _getScoreColor(score))),
            Text('/100',
                style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600])),
          ]),
        ]));
  }

  Widget _buildProfileStat(
      String label, String value, IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color, size: 6.w),
          SizedBox(height: 1.h),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]),
              textAlign: TextAlign.center),
          SizedBox(height: 0.5.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, fontWeight: FontWeight.w700, color: color),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildEligibilitySection() {
    final trustScore = (_creditProfile['trust_score'] ?? 0.0).toDouble();
    final isEligible = trustScore >= 40; // Minimum score for loan eligibility

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isEligible
                    ? Colors.green.withAlpha(77)
                    : Colors.orange.withAlpha(77),
                width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(isEligible ? Icons.check_circle : Icons.info,
                color: isEligible ? Colors.green : Colors.orange, size: 6.w),
            SizedBox(width: 3.w),
            Text(isEligible ? 'You\'re Eligible!' : 'Improve Your Score',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isEligible ? Colors.green : Colors.orange)),
          ]),
          SizedBox(height: 3.h),
          Text(
              isEligible
                  ? 'Based on your trust score and transaction history, you qualify for personal loans up to the amounts shown below.'
                  : 'Your current trust score is below the minimum requirement (40). Continue logging transactions and verifying them to improve your eligibility.',
              style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                  height: 1.4)),
          if (!isEligible) ...[
            SizedBox(height: 3.h),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to Improve:',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue)),
                      SizedBox(height: 2.h),
                      _buildImprovementTip('Log more transactions daily'),
                      _buildImprovementTip('Get merchant verifications'),
                      _buildImprovementTip('Complete your profile'),
                      _buildImprovementTip('Use the app consistently'),
                    ])),
          ],
        ]));
  }

  Widget _buildImprovementTip(String tip) {
    return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Row(children: [
          Icon(Icons.arrow_right_rounded, color: Colors.blue, size: 4.w),
          SizedBox(width: 2.w),
          Text(tip,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700])),
        ]));
  }

  Widget _buildLoanOptionsSection() {
    final trustScore = (_creditProfile['trust_score'] ?? 0.0).toDouble();
    final isEligible = trustScore >= 40;

    if (!isEligible) {
      return const SizedBox.shrink();
    }

    final loanOptions = _getLoanOptions(trustScore);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Available Loan Options',
          style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32))),
      SizedBox(height: 3.h),
      ...loanOptions.map((option) => _buildLoanOptionCard(option)),
    ]);
  }

  List<Map<String, dynamic>> _getLoanOptions(double trustScore) {
    if (trustScore >= 80) {
      return [
        {
          'partner': 'Islamic Bank Solutions',
          'amount': 50000.0,
          'rate': '3.5% - 5.8%',
          'term': '1-7 years',
          'features': [
            'No collateral required',
            'Quick approval',
            'Flexible terms'
          ],
          'color': const Color(0xFF1976D2),
        },
        {
          'partner': 'Maybank Personal Loan',
          'amount': 30000.0,
          'rate': '4.2% - 6.5%',
          'term': '1-5 years',
          'features': [
            'Instant approval',
            'Competitive rates',
            'Online application'
          ],
          'color': const Color(0xFFE65100),
        },
      ];
    } else if (trustScore >= 60) {
      return [
        {
          'partner': 'FinTech Partner Malaysia',
          'amount': 25000.0,
          'rate': '5.5% - 8.2%',
          'term': '1-5 years',
          'features': [
            'Fast processing',
            'Digital application',
            'Reasonable rates'
          ],
          'color': const Color(0xFF7B1FA2),
        },
      ];
    } else {
      return [
        {
          'partner': 'Micro Finance Plus',
          'amount': 10000.0,
          'rate': '7.8% - 12.5%',
          'term': '6 months - 3 years',
          'features': ['Small loans', 'Build credit history', 'Easy approval'],
          'color': const Color(0xFF388E3C),
        },
      ];
    }
  }

  Widget _buildLoanOptionCard(Map<String, dynamic> option) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 3.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: (option['color'] as Color).withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(children: [
          // Header
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                  color: (option['color'] as Color).withAlpha(26),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Row(children: [
                Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                        color: option['color'],
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.account_balance,
                        color: Colors.white, size: 6.w)),
                SizedBox(width: 4.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(option['partner'],
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: option['color'])),
                      Text(
                          'Up to RM ${(option['amount'] as double).toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600])),
                    ])),
              ])),

          // Content
          Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: _buildLoanDetail('Interest Rate', option['rate'])),
                  Expanded(
                      child: _buildLoanDetail('Loan Term', option['term'])),
                ]),

                SizedBox(height: 3.h),

                // Features
                ...((option['features'] as List<String>)
                    .map((feature) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 4.w),
                          SizedBox(width: 3.w),
                          Text(feature,
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700])),
                        ])))),

                SizedBox(height: 3.h),

                // Apply button
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _applicationSubmitted
                            ? null
                            : () {
                                _submitLoanApplication(
                                    option['amount'], option['partner']);
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: option['color'],
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0),
                        child: Text(
                            _applicationSubmitted
                                ? 'Application Submitted'
                                : 'Apply Now',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600)))),
              ])),
        ]));
  }

  Widget _buildLoanDetail(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600])),
      SizedBox(height: 0.5.h),
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800])),
    ]);
  }

  Widget _buildErrorWidget() {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(6.w),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline_rounded,
                  size: 20.w, color: Colors.red[400]),
              SizedBox(height: 3.h),
              Text('Unable to load credit profile',
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  textAlign: TextAlign.center),
              SizedBox(height: 2.h),
              Text(_errorMessage ?? 'Unknown error occurred',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              ElevatedButton(
                  onPressed: _loadCreditProfile,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text('Retry',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w600))),
            ])));
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
