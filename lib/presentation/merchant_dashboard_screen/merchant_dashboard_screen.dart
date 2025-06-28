import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/merchant_service.dart';
import '../../services/monetization_service.dart';
import '../../services/transaction_service.dart';
import './widgets/revenue_overview_widget.dart';
import './widgets/transaction_confirmation_widget.dart';
import './widgets/analytics_dashboard_widget.dart';
import './widgets/subscription_status_widget.dart';
import './widgets/customer_insights_widget.dart';
import './widgets/merchant_quick_actions_widget.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final AuthService _authService = AuthService();
  final MerchantService _merchantService = MerchantService();
  final MonetizationService _monetizationService = MonetizationService();
  final TransactionService _transactionService = TransactionService();

  Map<String, dynamic> _merchantProfile = {};
  Map<String, dynamic> _revenueData = {};
  Map<String, dynamic> _subscriptionData = {};
  List<Map<String, dynamic>> _pendingTransactions = [];
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;
  String? _errorMessage;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadMerchantData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMerchantData() async {
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
        _merchantService.getUserMerchants(),
        _monetizationService.getRevenueOverview(),
        _monetizationService.getUserSubscription(),
        _transactionService.getPendingMerchantTransactions(),
        _merchantService.getMerchantAnalytics(user.id),
      ]);

      final merchants = results[0] as List<Map<String, dynamic>>;

      setState(() {
        _merchantProfile = merchants.isNotEmpty ? merchants.first : {};
        _revenueData = results[1] as Map<String, dynamic>? ?? {};
        _subscriptionData = results[2] as Map<String, dynamic>? ?? {};
        _pendingTransactions =
            List<Map<String, dynamic>>.from(results[3] as List? ?? []);
        _analyticsData = results[4] as Map<String, dynamic>? ?? {};
        _pendingCount = _pendingTransactions.length;
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
    await _loadMerchantData();
  }

  void _handleTransactionAction(String transactionId, String action) async {
    try {
      await _transactionService.updateTransactionStatus(transactionId, action);
      _refreshData(); // Refresh data after action

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Transaction ${action == 'verified' ? 'approved' : 'rejected'} successfully'),
          backgroundColor: action == 'verified' ? Colors.green : Colors.red,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update transaction: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF1565C0),
                  child: _buildDashboardContent(),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1565C0),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _merchantProfile['name'] ?? 'Merchant Dashboard',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (_subscriptionData['tier'] != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _getTierColor(_subscriptionData['tier']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_subscriptionData['tier']?.toString().toUpperCase() ?? 'FREE'} PLAN',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
            if (_pendingCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'pro':
        return Colors.orange;
      case 'elite':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Revenue Overview
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: RevenueOverviewWidget(
                    revenueData: _revenueData,
                    animation: _animationController,
                  ),
                ),

                SizedBox(height: 3.h),

                // Subscription Status
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: SubscriptionStatusWidget(
                    subscriptionData: _subscriptionData,
                    animation: _animationController,
                    onUpgrade: () {
                      Navigator.pushNamed(
                          context, '/monetization-center-screen');
                    },
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
                // Transaction Confirmation Queue
                TransactionConfirmationWidget(
                  pendingTransactions: _pendingTransactions,
                  onTransactionAction: _handleTransactionAction,
                  animation: _animationController,
                ),

                SizedBox(height: 4.h),

                // Quick Actions
                MerchantQuickActionsWidget(
                  onConfirmTransaction: () {
                    // Handle confirm transaction
                  },
                  onViewAnalytics: () {
                    // Handle view analytics
                  },
                  onManageSubscription: () {
                    Navigator.pushNamed(context, '/monetization-center-screen');
                  },
                  onGenerateReports: () {
                    Navigator.pushNamed(context, '/reports-screen');
                  },
                  animation: _animationController,
                ),

                SizedBox(height: 4.h),

                // Analytics Dashboard
                AnalyticsDashboardWidget(
                  analyticsData: _analyticsData,
                  animation: _animationController,
                ),

                SizedBox(height: 4.h),

                // Customer Insights
                CustomerInsightsWidget(
                  analyticsData: _analyticsData,
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
              'Unable to load merchant dashboard',
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
              onPressed: _loadMerchantData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
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
