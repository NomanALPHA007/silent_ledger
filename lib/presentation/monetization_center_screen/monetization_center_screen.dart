import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/monetization_service.dart';
import './widgets/referral_program_widget.dart';
import './widgets/subscription_plans_widget.dart';
import './widgets/wallet_overview_widget.dart';

class MonetizationCenterScreen extends StatefulWidget {
  const MonetizationCenterScreen({super.key});

  @override
  State<MonetizationCenterScreen> createState() =>
      _MonetizationCenterScreenState();
}

class _MonetizationCenterScreenState extends State<MonetizationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MonetizationService _monetizationService = MonetizationService();
  final AuthService _authService = AuthService();

  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isMerchant = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Load user profile to determine access level
      _userProfile = await _authService.getUserProfile();

      // Determine if user has merchant access (gold/platinum tiers)
      _isMerchant = _userProfile?['trust_tier'] == 'gold' ||
          _userProfile?['trust_tier'] == 'platinum';

      // Initialize tab controller based on user type
      final tabCount =
          _isMerchant ? 3 : 2; // Merchants see all 3 tabs, users see 2
      _tabController = TabController(length: tabCount, vsync: this);

      // Load dashboard stats
      final stats = await _monetizationService.getDashboardStats(user.id);

      setState(() {
        _dashboardStats = stats;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        // Initialize with minimum tabs on error
        _tabController = TabController(length: 2, vsync: this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Monetization Center',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: _buildTabs(),
              ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildStatsOverview(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _buildTabViews(),
                      ),
                    ),
                  ],
                ),
    );
  }

  List<Tab> _buildTabs() {
    final baseTabs = [
      const Tab(text: 'Wallet Overview'),
      const Tab(text: 'Referral Program'),
    ];

    if (_isMerchant) {
      baseTabs.insert(1, const Tab(text: 'Subscription Plans'));
    }

    return baseTabs;
  }

  List<Widget> _buildTabViews() {
    final baseViews = [
      WalletOverviewWidget(stats: _dashboardStats, onRefresh: _loadInitialData),
      ReferralProgramWidget(onRefresh: _loadInitialData),
    ];

    if (_isMerchant) {
      baseViews.insert(1, SubscriptionPlansWidget(onRefresh: _loadInitialData));
    }

    return baseViews;
  }

  Widget _buildStatsOverview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Silent Coins',
              '${_dashboardStats['wallet_balance']?.toStringAsFixed(0) ?? '0'}',
              Icons.monetization_on,
              Colors.amber,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Total Earned',
              'RM ${_dashboardStats['total_earned']?.toStringAsFixed(2) ?? '0.00'}',
              Icons.trending_up,
              Colors.green[300]!,
            ),
          ),
          if (_isMerchant) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'API Calls',
                '${_dashboardStats['api_calls_used'] ?? 0}',
                Icons.api,
                Colors.blue[300]!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Unable to load monetization data',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadInitialData,
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
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
