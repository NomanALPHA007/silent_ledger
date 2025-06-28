import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/wallet_service.dart';
import '../../../services/auth_service.dart';

class WalletOverviewWidget extends StatefulWidget {
  final Map<String, dynamic> stats;
  final VoidCallback onRefresh;

  const WalletOverviewWidget({
    super.key,
    required this.stats,
    required this.onRefresh,
  });

  @override
  State<WalletOverviewWidget> createState() => _WalletOverviewWidgetState();
}

class _WalletOverviewWidgetState extends State<WalletOverviewWidget> {
  final WalletService _walletService = WalletService();
  final AuthService _authService = AuthService();

  List<dynamic> _activityLog = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWalletActivity();
  }

  Future<void> _loadWalletActivity() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) return;

      final history = await _walletService.getWalletTransactionHistory(user.id);

      setState(() {
        _activityLog = history;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showRedeemDialog() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    final selectedType = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildRedeemBottomSheet(),
    );

    if (selectedType != null) {
      await _processRedemption(user.id, selectedType);
    }
  }

  Widget _buildRedeemBottomSheet() {
    return Container(
      padding: EdgeInsets.all(20.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem Silent Coins',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          _buildRedeemOption(
            'cash',
            'Cash Transfer',
            'Convert to bank transfer',
            Icons.account_balance,
            '100 coins = RM 10',
          ),
          _buildRedeemOption(
            'gift_card',
            'Gift Cards',
            'Popular retail vouchers',
            Icons.card_giftcard,
            '50 coins = RM 5',
          ),
          _buildRedeemOption(
            'loan_interest_reduction',
            'Loan Benefits',
            'Reduce loan interest rates',
            Icons.trending_down,
            '200 coins = 0.5% reduction',
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildRedeemOption(
    String type,
    String title,
    String subtitle,
    IconData icon,
    String rate,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, type),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 20.sp,
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
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    rate,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processRedemption(String userId, String type) async {
    try {
      double coinsToRedeem = 50.0; // Default amount
      Map<String, dynamic> redemptionDetails = {};

      switch (type) {
        case 'cash':
          coinsToRedeem = 100.0;
          redemptionDetails = {
            'payment_method': 'bank_transfer',
            'notes': 'Cash redemption request'
          };
          break;
        case 'gift_card':
          coinsToRedeem = 50.0;
          redemptionDetails = {
            'payment_method': 'gift_card',
            'notes': 'Gift card redemption request'
          };
          break;
        case 'loan_interest_reduction':
          coinsToRedeem = 200.0;
          redemptionDetails = {
            'payment_method': 'loan_benefit',
            'notes': 'Loan interest reduction request'
          };
          break;
      }

      await _walletService.redeemSilentCoins(
        userId,
        coinsToRedeem,
        type,
        redemptionDetails,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redemption request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadWalletActivity();
        widget.onRefresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process redemption: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWalletCard(),
          SizedBox(height: 20.h),
          _buildEarningsBreakdown(),
          SizedBox(height: 20.h),
          _buildActivityHistory(),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
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
                'Silent Coin Wallet',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '${widget.stats['wallet_balance']?.toStringAsFixed(0) ?? '0'} Coins',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '≈ RM ${((widget.stats['wallet_balance'] ?? 0) * 0.1).toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showRedeemDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Redeem Coins',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              OutlinedButton(
                onPressed: () {
                  // Navigate to earning more coins
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Earn More',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            'Earnings Breakdown',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          _buildEarningItem(
            'Transaction Confirmations',
            '45 coins',
            Icons.verified,
            Colors.green,
          ),
          _buildEarningItem(
            'Loan Referrals',
            '250 coins',
            Icons.trending_up,
            Colors.blue,
          ),
          _buildEarningItem(
            'Data Verification',
            '30 coins',
            Icons.fact_check,
            Colors.orange,
          ),
          _buildEarningItem(
            'Community Voting',
            '15 coins',
            Icons.how_to_vote,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(
    String title,
    String amount,
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
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHistory() {
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
            'Coin History',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_activityLog.isEmpty)
            Text(
              'No activity yet',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activityLog.length > 5 ? 5 : _activityLog.length,
              itemBuilder: (context, index) {
                final activity = _activityLog[index];
                return _buildActivityItem(activity);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final amount = (activity['amount'] as num).toDouble();
    final isPositive = amount > 0;

    Color statusColor = isPositive ? Colors.green : Colors.orange;
    IconData statusIcon = isPositive ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] ?? 'Transaction',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  activity['type']
                          ?.toString()
                          .replaceAll('_', ' ')
                          .toUpperCase() ??
                      'ACTIVITY',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${amount.toStringAsFixed(0)} coins',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
