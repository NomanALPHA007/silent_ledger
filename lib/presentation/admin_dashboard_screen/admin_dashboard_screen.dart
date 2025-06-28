import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import './widgets/revenue_dashboard_widget.dart';
import './widgets/user_management_widget.dart';
import './widgets/api_monitoring_widget.dart';
import './widgets/system_insights_widget.dart';
import './widgets/admin_header_widget.dart';
import './widgets/admin_quick_actions_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  Map<String, dynamic> _revenueMetrics = {};
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _apiMonitoring = {};
  Map<String, dynamic> _systemInsights = {};
  List<Map<String, dynamic>> _flaggedTransactions = [];

  bool _isLoading = true;
  bool _isAuthorized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _initializeAdminDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeAdminDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check admin authorization first
      final isAdmin = await _adminService.isAdmin();
      if (!isAdmin) {
        setState(() {
          _isAuthorized = false;
          _isLoading = false;
          _errorMessage = 'Access denied: Admin privileges required';
        });
        return;
      }

      setState(() {
        _isAuthorized = true;
      });

      // Load all admin dashboard data
      await _loadDashboardData();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load data in parallel for better performance
      final results = await Future.wait([
        _adminService.getRevenueMetrics(),
        _adminService.getUserManagementStats(),
        _adminService.getApiMonitoring(),
        _adminService.getSystemInsights(),
        _adminService.getFlaggedTransactions(),
      ]);

      setState(() {
        _revenueMetrics = results[0] as Map<String, dynamic>;
        _userStats = results[1] as Map<String, dynamic>;
        _apiMonitoring = results[2] as Map<String, dynamic>;
        _systemInsights = results[3] as Map<String, dynamic>;
        _flaggedTransactions =
            List<Map<String, dynamic>>.from(results[4] as Iterable<dynamic>);
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

  Future<void> _refreshDashboard() async {
    _animationController.reset();
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : !_isAuthorized
              ? _buildUnauthorizedView()
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _buildAdminDashboard(),
    );
  }

  Widget _buildUnauthorizedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 25.w,
              color: Colors.red[400],
            ),
            SizedBox(height: 4.h),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Admin privileges required to access this dashboard',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/dashboard-screen');
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      color: const Color(0xFF1976D2),
      child: CustomScrollView(
        slivers: [
          // Admin Header with system health
          SliverToBoxAdapter(
            child: AdminHeaderWidget(
              animation: _animationController,
              systemStatus: _getSystemHealthStatus(),
              totalRevenue: _revenueMetrics['total_revenue']?.toDouble() ?? 0,
              totalUsers: _userStats['total_users'] ?? 0,
              activeApiClients: _apiMonitoring['active_clients'] ?? 0,
            ),
          ),

          // Quick Admin Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: AdminQuickActionsWidget(
                animation: _animationController,
                onGenerateReport: _generateSystemReport,
                onManageApiKeys: _showApiKeysDialog,
                onReviewTransactions: _showFlaggedTransactionsDialog,
                onSystemConfig: _showSystemConfigDialog,
                pendingAnomalies: _systemInsights['pending_anomalies'] ?? 0,
              ),
            ),
          ),

          // Revenue Dashboard
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: RevenueDashboardWidget(
                revenueData: _revenueMetrics,
                animation: _animationController,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 3.h)),

          // User Management Statistics
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: UserManagementWidget(
                userStats: _userStats,
                animation: _animationController,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 3.h)),

          // API Access Monitoring
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ApiMonitoringWidget(
                apiData: _apiMonitoring,
                animation: _animationController,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 3.h)),

          // System Insights
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SystemInsightsWidget(
                systemData: _systemInsights,
                animation: _animationController,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 4.h)),
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
              'Unable to load admin dashboard',
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
              onPressed: _initializeAdminDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
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

  String _getSystemHealthStatus() {
    final pendingAnomalies = _systemInsights['pending_anomalies'] ?? 0;
    final activeClients = _apiMonitoring['active_clients'] ?? 0;
    final totalUsers = _userStats['total_users'] ?? 0;

    if (pendingAnomalies > 10) return 'Warning';
    if (activeClients > 0 && totalUsers > 0) return 'Healthy';
    return 'Normal';
  }

  void _generateSystemReport() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1976D2)),
        ),
      );

      final report = await _adminService.generateSystemReport();
      Navigator.pop(context);

      // Show report generated success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('System report generated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showApiKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Keys Management'),
        content: const Text(
            'API key management interface would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFlaggedTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Flagged Transactions (${_flaggedTransactions.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 60.h,
          child: ListView.builder(
            itemCount: _flaggedTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _flaggedTransactions[index];
              return ListTile(
                title: Text(transaction['description'] ?? 'Unknown'),
                subtitle: Text('Amount: \$${transaction['amount']}'),
                trailing: Text(transaction['status'] ?? 'pending'),
                onTap: () {
                  // TODO: Show transaction details
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSystemConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Configuration'),
        content: const Text(
            'System configuration interface would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
