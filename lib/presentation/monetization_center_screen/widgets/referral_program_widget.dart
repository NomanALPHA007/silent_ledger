import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/monetization_service.dart';
import '../../../services/auth_service.dart';

class ReferralProgramWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const ReferralProgramWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<ReferralProgramWidget> createState() => _ReferralProgramWidgetState();
}

class _ReferralProgramWidgetState extends State<ReferralProgramWidget> {
  final MonetizationService _monetizationService = MonetizationService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _referralProgram;
  List<dynamic> _referralHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) return;

      final program = await _monetizationService.getReferralProgram();
      final history = await _monetizationService.getReferralHistory();

      setState(() {
        _referralProgram = program;
        _referralHistory = history;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createReferralCode() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return;

      final code = await _monetizationService.createReferralCode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Referral code created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadReferralData();
        widget.onRefresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create referral code: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareReferralCode(String code) {
    final shareText =
        'Join Silent Ledger with my referral code: $code\n\nEarn Silent Coins for verifying your transactions and build your trust score for better loan opportunities!';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    // Share via native share intent
    Share.share(shareText, subject: 'Join Silent Ledger');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral message copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReferralOverview(),
          SizedBox(height: 20.h),
          _buildEarningsBreakdown(),
          SizedBox(height: 20.h),
          _buildReferralHistory(),
          SizedBox(height: 20.h),
          _buildHowItWorks(),
        ],
      ),
    );
  }

  Widget _buildReferralOverview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_referralProgram == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.group_add,
              size: 48.sp,
              color: const Color(0xFF2E7D32),
            ),
            SizedBox(height: 16.h),
            Text(
              'Start Earning with Referrals',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Invite friends and earn 10 Silent Coins for each successful referral',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _createReferralCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create Referral Code',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalReferrals = _referralProgram!['total_referrals'] ?? 0;
    final successfulReferrals = _referralProgram!['successful_referrals'] ?? 0;
    final totalEarned = _referralProgram!['total_coins_earned'] ?? 0.0;
    final referralCode = _referralProgram!['referral_code'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 8,
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
              Text(
                'Your Referral Code',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.share, color: Colors.white, size: 20.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: GoogleFonts.firaCode(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shareReferralCode(referralCode),
                  icon: const Icon(Icons.copy, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildReferralMetric(
                  'Total Invites',
                  totalReferrals.toString(),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildReferralMetric(
                  'Successful',
                  successfulReferrals.toString(),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildReferralMetric(
                  'Coins Earned',
                  totalEarned.toStringAsFixed(0),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _shareReferralCode(referralCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Share Referral Code',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsBreakdown() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral Rewards',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          _buildEarningItem(
            'User Signs Up',
            '10 coins',
            'Friend creates account',
            Icons.person_add,
            Colors.blue,
          ),
          _buildEarningItem(
            'First Transaction',
            '15 coins',
            'Friend logs first transaction',
            Icons.receipt,
            Colors.green,
          ),
          _buildEarningItem(
            'Trust Score Bronze',
            '20 coins',
            'Friend reaches Bronze tier',
            Icons.military_tech,
            Colors.orange,
          ),
          _buildEarningItem(
            'Monthly Bonus',
            '5 coins',
            'For each active referral',
            Icons.calendar_month,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(
    String title,
    String amount,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.sp),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHistory() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral History',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          if (_referralHistory.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.group, size: 48.sp, color: Colors.grey[400]),
                  SizedBox(height: 12.h),
                  Text(
                    'No referrals yet',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Share your referral code to start earning!',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _referralHistory.length,
              itemBuilder: (context, index) {
                final referral = _referralHistory[index];
                return _buildReferralHistoryItem(referral);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReferralHistoryItem(Map<String, dynamic> referral) {
    final coinsAwarded = referral['coins_awarded'] ?? 0.0;
    final signupCompleted = referral['signup_completed'] ?? false;
    final firstTransactionCompleted =
        referral['first_transaction_completed'] ?? false;
    final bonusPaid = referral['bonus_paid'] ?? false;
    final createdAt = DateTime.parse(
      referral['created_at'] ?? DateTime.now().toIso8601String(),
    );

    Color statusColor = Colors.orange;
    String statusText = 'Pending';
    IconData statusIcon = Icons.pending;

    if (bonusPaid) {
      statusColor = Colors.green;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (firstTransactionCompleted) {
      statusColor = Colors.blue;
      statusText = 'Active';
      statusIcon = Icons.verified;
    } else if (signupCompleted) {
      statusColor = Colors.orange;
      statusText = 'Signed Up';
      statusIcon = Icons.person_add;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.sp),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral #${referral['id'].toString().substring(0, 8)}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${coinsAwarded.toStringAsFixed(0)} coins',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: bonusPaid ? Colors.green : Colors.grey[600],
                ),
              ),
              if (!bonusPaid)
                Text(
                  'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Referrals Work',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          _buildHowItWorksStep(
            '1',
            'Share Code',
            'Send your referral code to friends and family',
          ),
          _buildHowItWorksStep(
            '2',
            'Friend Signs Up',
            'They create account using your code',
          ),
          _buildHowItWorksStep(
            '3',
            'Earn Coins',
            'Get rewarded when they complete actions',
          ),
          _buildHowItWorksStep(
            '4',
            'Keep Earning',
            'Monthly bonuses for active referrals',
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(String number, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
