import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../services/trust_service.dart';
import '../../services/transaction_service.dart';
import './widgets/trust_score_card_widget.dart';
import './widgets/wallet_balance_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/earnings_overview_widget.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final AuthService _authService = AuthService();
  final WalletService _walletService = WalletService();
  final TrustService _trustService = TrustService();
  final TransactionService _transactionService = TransactionService();

  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _walletData = {};
  Map<String, dynamic> _trustData = {};
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Load data in parallel
      final results = await Future.wait<dynamic>([
        _authService.getUserProfile(),
        _walletService.getWalletBalance(user.id),
        _trustService.getTrustScore(user.id),
        _transactionService.getUserTransactions(limit: 10),
      ]);

      setState(() {
        _userProfile = results[0] as Map<String, dynamic>? ?? {};
        _walletData = results[1] as Map<String, dynamic>? ?? {};
        _trustData = results[2] as Map<String, dynamic>? ?? {};
        _recentTransactions =
            List<Map<String, dynamic>>.from(results[3] as List? ?? []);
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

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF2E7D32),
                  child: _buildDashboardContent(),
                ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}!',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          Text(
            _userProfile['full_name'] ?? 'User',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/settings-screen');
          },
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header gradient section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Trust Score Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: TrustScoreCardWidget(
                    trustData: _trustData,
                    animation: _animationController,
                  ),
                ),

                SizedBox(height: 3.h),

                // Wallet Balance
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: WalletBalanceWidget(
                    walletData: _walletData,
                    animation: _animationController,
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),

          // Main content section
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions
                QuickActionsWidget(
                  onLogTransaction: () {
                    Navigator.pushNamed(context, '/add-transaction-screen');
                  },
                  onCheckLoanEligibility: () {
                    Navigator.pushNamed(context, '/loan-eligibility-screen');
                  },
                  onReferralProgram: () {
                    Navigator.pushNamed(context, '/monetization-center-screen');
                  },
                  animation: _animationController,
                ),

                SizedBox(height: 4.h),

                // Earnings Overview
                EarningsOverviewWidget(
                  walletData: _walletData,
                  animation: _animationController,
                ),

                SizedBox(height: 4.h),

                // Recent Activity
                RecentActivityWidget(
                  transactions: _recentTransactions,
                  onViewAll: () {
                    Navigator.pushNamed(context, '/transaction-list-screen');
                  },
                  animation: _animationController,
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/add-transaction-screen');
      },
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Log Transaction',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20.w,
              color: Colors.red[400],
            ),
            SizedBox(height: 3.h),
            Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
