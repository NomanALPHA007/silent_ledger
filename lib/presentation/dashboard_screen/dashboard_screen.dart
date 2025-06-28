import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../reports_screen/widgets/budget_progress_widget.dart';
import '../reports_screen/widgets/category_breakdown_widget.dart';
import '../reports_screen/widgets/expense_chart_widget.dart';
import '../reports_screen/widgets/financial_summary_card_widget.dart';
import '../reports_screen/widgets/income_expense_trend_widget.dart';
import '../settings_screen/widgets/settings_item_widget.dart';
import '../settings_screen/widgets/settings_section_widget.dart';
import '../settings_screen/widgets/settings_toggle_widget.dart';
import '../transaction_list_screen/widgets/empty_state_widget.dart';
import '../transaction_list_screen/widgets/filter_bottom_sheet_widget.dart';
import '../transaction_list_screen/widgets/filter_chip_widget.dart';
import '../transaction_list_screen/widgets/search_header_widget.dart';
import '../transaction_list_screen/widgets/transaction_detail_bottom_sheet_widget.dart';
import '../transaction_list_screen/widgets/transaction_item_widget.dart';
import './widgets/account_card_widget.dart';
import './widgets/balance_card_widget.dart';
import './widgets/quick_action_widget.dart';
import './widgets/recent_transaction_item_widget.dart';
import './widgets/spending_insights_widget.dart';

// Transaction screen imports

// Reports screen imports

// Settings screen imports

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();

  // Auth service for user role checking
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isMerchant = false;
  bool _isLoadingProfile = true;

  // Transaction tab controllers and state
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String _sortBy = 'Date';
  List<String> _activeFilters = [];
  Map<String, dynamic> _filterOptions = {
    'dateRange': null,
    'categories': <String>[],
    'amountRange': {'min': 0.0, 'max': 10000.0},
    'accounts': <String>[],
  };

  // Reports tab state
  late TabController _reportsTabController;
  String _selectedTimeframe = 'This Month';
  final List<String> _timeframes = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year'
  ];

  // Settings state
  bool biometricEnabled = true;
  bool twoFactorEnabled = false;
  bool transactionAlerts = true;
  bool securityNotifications = true;
  bool weeklyReports = false;
  bool budgetReminders = true;
  bool analyticsEnabled = false;
  String selectedCurrency = "USD";
  String selectedDateFormat = "MM/DD/YYYY";
  String selectedNumberFormat = "1,000.00";
  String selectedTheme = "System";
  String selectedLanguage = "English";

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "emailVerified": true,
    "subscriptionType": "Premium",
    "profileImage":
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
    "totalBalance": 15420.50,
    "monthlyChange": 8.5,
    "lastSync": "2 minutes ago"
  };

  // Mock accounts data
  final List<Map<String, dynamic>> _accountsData = [
    {
      "id": 1,
      "name": "Main Checking",
      "type": "Checking",
      "balance": 8420.50,
      "accountNumber": "****1234",
      "color": 0xFF4A90A4
    },
    {
      "id": 2,
      "name": "Savings Account",
      "type": "Savings",
      "balance": 5000.00,
      "accountNumber": "****5678",
      "color": 0xFF0F7B0F
    },
    {
      "id": 3,
      "name": "Credit Card",
      "type": "Credit",
      "balance": -2000.00,
      "accountNumber": "****9012",
      "color": 0xFFC5282F
    }
  ];

  // Mock recent transactions
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": 1,
      "description": "Grocery Store",
      "category": "Food & Dining",
      "amount": -85.50,
      "date": "Today",
      "icon": "shopping_cart",
      "time": "2:30 PM"
    },
    {
      "id": 2,
      "description": "Salary Deposit",
      "category": "Income",
      "amount": 3200.00,
      "date": "Yesterday",
      "icon": "account_balance_wallet",
      "time": "9:00 AM"
    },
    {
      "id": 3,
      "description": "Electric Bill",
      "category": "Utilities",
      "amount": -120.00,
      "date": "Dec 15",
      "icon": "flash_on",
      "time": "11:45 AM"
    },
    {
      "id": 4,
      "description": "Coffee Shop",
      "category": "Food & Dining",
      "amount": -4.50,
      "date": "Dec 14",
      "icon": "local_cafe",
      "time": "8:15 AM"
    },
    {
      "id": 5,
      "description": "Gas Station",
      "category": "Transportation",
      "amount": -45.00,
      "date": "Dec 13",
      "icon": "local_gas_station",
      "time": "6:30 PM"
    }
  ];

  // Mock spending insights data
  final List<Map<String, dynamic>> _spendingData = [
    {"category": "Food & Dining", "amount": 450.00, "percentage": 35},
    {"category": "Transportation", "amount": 280.00, "percentage": 22},
    {"category": "Utilities", "amount": 220.00, "percentage": 17},
    {"category": "Entertainment", "amount": 180.00, "percentage": 14},
    {"category": "Shopping", "amount": 150.00, "percentage": 12}
  ];

  // Mock transaction data for Transactions tab
  final List<Map<String, dynamic>> _allTransactions = [
    {
      "id": "1",
      "date": DateTime.now().subtract(Duration(hours: 2)),
      "category": "Food & Dining",
      "categoryIcon": "restaurant",
      "description": "Lunch at Cafe Central",
      "account": "Chase Checking",
      "amount": -25.50,
      "type": "expense",
      "notes": "Business lunch with client",
      "isRecurring": false,
    },
    {
      "id": "2",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "category": "Salary",
      "categoryIcon": "work",
      "description": "Monthly Salary",
      "account": "Main Checking",
      "amount": 4500.00,
      "type": "income",
      "notes": "",
      "isRecurring": true,
    },
    {
      "id": "3",
      "date": DateTime.now().subtract(Duration(days: 1, hours: 5)),
      "category": "Transportation",
      "categoryIcon": "directions_car",
      "description": "Gas Station",
      "account": "Credit Card",
      "amount": -45.20,
      "type": "expense",
      "notes": "",
      "isRecurring": false,
    },
    {
      "id": "4",
      "date": DateTime.now().subtract(Duration(days: 2)),
      "category": "Shopping",
      "categoryIcon": "shopping_bag",
      "description": "Amazon Purchase",
      "account": "Credit Card",
      "amount": -89.99,
      "type": "expense",
      "notes": "Office supplies",
      "isRecurring": false,
    },
    {
      "id": "5",
      "date": DateTime.now().subtract(Duration(days: 3)),
      "category": "Utilities",
      "categoryIcon": "electrical_services",
      "description": "Electricity Bill",
      "account": "Main Checking",
      "amount": -120.00,
      "type": "expense",
      "notes": "",
      "isRecurring": true,
    },
    {
      "id": "6",
      "date": DateTime.now().subtract(Duration(days: 4)),
      "category": "Entertainment",
      "categoryIcon": "movie",
      "description": "Netflix Subscription",
      "account": "Credit Card",
      "amount": -15.99,
      "type": "expense",
      "notes": "",
      "isRecurring": true,
    },
    {
      "id": "7",
      "date": DateTime.now().subtract(Duration(days: 5)),
      "category": "Investment",
      "categoryIcon": "trending_up",
      "description": "Stock Dividend",
      "account": "Investment Account",
      "amount": 125.00,
      "type": "income",
      "notes": "AAPL dividend",
      "isRecurring": false,
    },
    {
      "id": "8",
      "date": DateTime.now().subtract(Duration(days: 6)),
      "category": "Healthcare",
      "categoryIcon": "local_hospital",
      "description": "Doctor Visit",
      "account": "HSA Account",
      "amount": -150.00,
      "type": "expense",
      "notes": "Annual checkup",
      "isRecurring": false,
    }
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  // Mock data for reports
  final List<Map<String, dynamic>> _expenseCategories = [
    {
      "category": "Food & Dining",
      "amount": 450.75,
      "color": 0xFFFF6B6B,
      "icon": "restaurant",
      "transactions": 15,
    },
    {
      "category": "Transportation",
      "amount": 280.50,
      "color": 0xFF4ECDC4,
      "icon": "directions_car",
      "transactions": 8,
    },
    {
      "category": "Shopping",
      "amount": 320.99,
      "color": 0xFF45B7D1,
      "icon": "shopping_bag",
      "transactions": 12,
    },
    {
      "category": "Bills & Utilities",
      "amount": 180.00,
      "color": 0xFFFECA57,
      "icon": "receipt",
      "transactions": 4,
    },
    {
      "category": "Entertainment",
      "amount": 95.50,
      "color": 0xFF96CEB4,
      "icon": "movie",
      "transactions": 6,
    }
  ];

  final List<Map<String, dynamic>> _trendData = [
    {"label": "Week 1", "income": 1200.0, "expense": 800.0},
    {"label": "Week 2", "income": 1500.0, "expense": 950.0},
    {"label": "Week 3", "income": 1100.0, "expense": 750.0},
    {"label": "Week 4", "income": 1800.0, "expense": 1100.0}
  ];

  final List<Map<String, dynamic>> _budgetData = [
    {
      "category": "Food & Dining",
      "budget": 500.0,
      "spent": 450.75,
      "color": 0xFFFF6B6B,
      "icon": "restaurant",
    },
    {
      "category": "Transportation",
      "budget": 300.0,
      "spent": 280.50,
      "color": 0xFF4ECDC4,
      "icon": "directions_car",
    },
    {
      "category": "Shopping",
      "budget": 250.0,
      "spent": 320.99,
      "color": 0xFF45B7D1,
      "icon": "shopping_bag",
    },
    {
      "category": "Entertainment",
      "budget": 150.0,
      "spent": 95.50,
      "color": 0xFF96CEB4,
      "icon": "movie",
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _reportsTabController = TabController(length: 3, vsync: this);
    _filteredTransactions = List.from(_allTransactions);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportsTabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });

    // Success haptic feedback
    HapticFeedback.selectionClick();
  }

  void _toggleBalanceVisibility() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  void _navigateToTransactions() {
    Navigator.pushNamed(context, '/transaction-list-screen');
  }

  void _navigateToAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction-screen');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  void _navigateToMonetizationCenter() {
    Navigator.pushNamed(context, '/monetization-center-screen');
  }

  // Transaction tab methods
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
    _filterTransactions();
  }

  void _loadMoreTransactions() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final description =
              (transaction['description'] as String).toLowerCase();
          final category = (transaction['category'] as String).toLowerCase();
          if (!description.contains(query) && !category.contains(query)) {
            return false;
          }
        }

        // Category filter
        if ((_filterOptions['categories'] as List).isNotEmpty) {
          if (!(_filterOptions['categories'] as List)
              .contains(transaction['category'])) {
            return false;
          }
        }

        // Amount range filter
        final amount = (transaction['amount'] as double).abs();
        final minAmount = _filterOptions['amountRange']['min'] as double;
        final maxAmount = _filterOptions['amountRange']['max'] as double;
        if (amount < minAmount || amount > maxAmount) {
          return false;
        }

        // Account filter
        if ((_filterOptions['accounts'] as List).isNotEmpty) {
          if (!(_filterOptions['accounts'] as List)
              .contains(transaction['account'])) {
            return false;
          }
        }

        return true;
      }).toList();

      // Sort transactions
      _sortTransactions();
    });
  }

  void _sortTransactions() {
    switch (_sortBy) {
      case 'Date':
        _filteredTransactions.sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'Amount':
        _filteredTransactions.sort((a, b) => (b['amount'] as double)
            .abs()
            .compareTo((a['amount'] as double).abs()));
        break;
      case 'Category':
        _filteredTransactions.sort((a, b) =>
            (a['category'] as String).compareTo(b['category'] as String));
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        filterOptions: _filterOptions,
        onFiltersApplied: (filters, activeFilters) {
          setState(() {
            _filterOptions = filters;
            _activeFilters = activeFilters;
          });
          _filterTransactions();
        },
      ),
    );
  }

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);

      // Reset specific filter option
      if (filter.contains('Category:')) {
        final category = filter.split(': ')[1];
        (_filterOptions['categories'] as List).remove(category);
      } else if (filter.contains('Account:')) {
        final account = filter.split(': ')[1];
        (_filterOptions['accounts'] as List).remove(account);
      } else if (filter == 'Date Range') {
        _filterOptions['dateRange'] = null;
      } else if (filter == 'Amount Range') {
        _filterOptions['amountRange'] = {'min': 0.0, 'max': 10000.0};
      }
    });
    _filterTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _filteredTransactions = List.from(_allTransactions);
    });
  }

  void _onTransactionTap(Map<String, dynamic> transaction) {
    // Show transaction detail bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheetWidget(
        transaction: transaction,
        onEdit: () => _onTransactionEdit(transaction),
        onDuplicate: () => _onTransactionDuplicate(transaction),
        onDelete: () => _onTransactionDelete(transaction),
      ),
    );
  }

  void _onTransactionEdit(Map<String, dynamic> transaction) {
    Navigator.pushNamed(context, '/add-transaction-screen');
  }

  void _onTransactionDuplicate(Map<String, dynamic> transaction) {
    // Duplicate transaction logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction duplicated')),
    );
  }

  void _onTransactionDelete(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
                _filteredTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = '${date.day}/${date.month}/${date.year}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: Column(
                children: [
                  // Greeting header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning,',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _userData["name"] as String,
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'security',
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Secure',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Last sync: ${_userData["lastSync"]}',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Transactions'),
                      Tab(text: 'Reports'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildTransactionsTab(),
                  _buildReportsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _tabController.index == 0 || _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: _navigateToAddTransaction,
                  child: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 24,
                  ),
                )
              : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            BalanceCardWidget(
              totalBalance: _userData["totalBalance"] as double,
              monthlyChange: _userData["monthlyChange"] as double,
              isVisible: _isBalanceVisible,
              onToggleVisibility: _toggleBalanceVisibility,
              isRefreshing: _isRefreshing,
            ),
            SizedBox(height: 3.h),

            // Monetization Center Card - Role-aware
            _buildMonetizationCenterCard(),
            SizedBox(height: 3.h),

            // Account summary section
            Text(
              'Accounts',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 20.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _accountsData.length,
                itemBuilder: (context, index) {
                  final account = _accountsData[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: AccountCardWidget(
                      accountName: account["name"] as String,
                      accountType: account["type"] as String,
                      balance: account["balance"] as double,
                      accountNumber: account["accountNumber"] as String,
                      color: Color(account["color"] as int),
                      isVisible: _isBalanceVisible,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),

            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToTransactions,
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _recentTransactions[index];
                return RecentTransactionItemWidget(
                  description: transaction["description"] as String,
                  category: transaction["category"] as String,
                  amount: transaction["amount"] as double,
                  date: transaction["date"] as String,
                  time: transaction["time"] as String,
                  iconName: transaction["icon"] as String,
                  isVisible: _isBalanceVisible,
                );
              },
            ),
            SizedBox(height: 3.h),

            // Quick actions
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: QuickActionWidget(
                    title: 'Add Transaction',
                    iconName: 'add_circle_outline',
                    onTap: _navigateToAddTransaction,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: QuickActionWidget(
                    title: 'Transfer Money',
                    iconName: 'swap_horiz',
                    onTap: () {
                      // Handle transfer
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: QuickActionWidget(
                    title: 'Scan Receipt',
                    iconName: 'camera_alt',
                    onTap: () {
                      // Handle scan receipt
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Spending insights
            SpendingInsightsWidget(
              spendingData: _spendingData,
            ),
            SizedBox(height: 10.h), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMonetizationCenterCard() {
    if (_isLoadingProfile) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _isMerchant
                ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(4.w),
          leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isMerchant ? Icons.business_center : Icons.monetization_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            'Monetization Center',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          subtitle: Text(
            _isMerchant
                ? 'Manage your subscription, API access, and revenue'
                : 'Manage coins, referrals, and rewards',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: Colors.white.withAlpha(230),
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isMerchant && _userProfile != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Plan: ${(_userProfile?['trust_tier'] ?? 'bronze').toString().toUpperCase()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  ),
                ),
              SizedBox(width: 2.w),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
          onTap: _navigateToMonetizationCenter,
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final groupedTransactions = _groupTransactionsByDate();
    final hasTransactions = _filteredTransactions.isNotEmpty;

    return Column(
      children: [
        // Search Header
        SearchHeaderWidget(
          controller: _searchController,
          onFilterTap: _showFilterBottomSheet,
          isSearching: _isSearching,
        ),

        // Active Filters
        if (_activeFilters.isNotEmpty)
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activeFilters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChipWidget(
                    label: _activeFilters[index],
                    onRemove: () => _removeFilter(_activeFilters[index]),
                  ),
                );
              },
            ),
          ),

        // Sort options
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              PopupMenuButton<String>(
                child: Row(
                  children: [
                    Text(
                      _sortBy,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'arrow_drop_down',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                  _filterTransactions();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Date', child: Text('Sort by Date')),
                  PopupMenuItem(value: 'Amount', child: Text('Sort by Amount')),
                  PopupMenuItem(
                      value: 'Category', child: Text('Sort by Category')),
                ],
              ),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: hasTransactions
              ? RefreshIndicator(
                  onRefresh: _refreshTransactions,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount:
                        groupedTransactions.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == groupedTransactions.length) {
                        return Container(
                          padding: EdgeInsets.all(4.w),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        );
                      }

                      final dateKey = groupedTransactions.keys.elementAt(index);
                      final transactions = groupedTransactions[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 2.w,
                            ),
                            child: Text(
                              _formatDateHeader(
                                  transactions.first['date'] as DateTime),
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),

                          // Transactions for this date
                          ...transactions
                              .map((transaction) => TransactionItemWidget(
                                    transaction: transaction,
                                    onTap: () => _onTransactionTap(transaction),
                                    onEdit: () =>
                                        _onTransactionEdit(transaction),
                                    onDuplicate: () =>
                                        _onTransactionDuplicate(transaction),
                                    onDelete: () =>
                                        _onTransactionDelete(transaction),
                                  )),
                        ],
                      );
                    },
                  ),
                )
              : EmptyStateWidget(
                  onAddTransaction: () =>
                      Navigator.pushNamed(context, '/add-transaction-screen'),
                ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final theme = Theme.of(context);
    final totalIncome = _trendData.fold<double>(
        0, (sum, item) => sum + (item['income'] as double));
    final totalExpense = _trendData.fold<double>(
        0, (sum, item) => sum + (item['expense'] as double));
    final netIncome = totalIncome - totalExpense;

    return Column(
      children: [
        // Reports header with timeframe selector
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Reports',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                child: Row(
                  children: [
                    Text(
                      _selectedTimeframe,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                onSelected: (value) {
                  setState(() {
                    _selectedTimeframe = value;
                  });
                },
                itemBuilder: (context) => _timeframes
                    .map((timeframe) => PopupMenuItem(
                          value: timeframe,
                          child: Text(timeframe),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        // Reports Tab Bar
        TabBar(
          controller: _reportsTabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Budget'),
          ],
        ),

        // Reports Tab Content
        Expanded(
          child: TabBarView(
            controller: _reportsTabController,
            children: [
              // Overview Tab
              _buildReportsOverviewTab(
                  theme, totalIncome, totalExpense, netIncome),

              // Categories Tab
              _buildReportsCategoriesTab(theme),

              // Budget Tab
              _buildReportsBudgetTab(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsOverviewTab(
    ThemeData theme,
    double totalIncome,
    double totalExpense,
    double netIncome,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Financial Summary Cards
          Row(
            children: [
              Expanded(
                child: FinancialSummaryCardWidget(
                  title: 'Total Income',
                  amount: '\$${totalIncome.toStringAsFixed(2)}',
                  subtitle: _selectedTimeframe,
                  backgroundColor: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withAlpha(26),
                  textColor: AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: FinancialSummaryCardWidget(
                  title: 'Total Expense',
                  amount: '\$${totalExpense.toStringAsFixed(2)}',
                  subtitle: _selectedTimeframe,
                  backgroundColor: theme.colorScheme.error.withAlpha(26),
                  textColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          FinancialSummaryCardWidget(
            title: 'Net Income',
            amount: '\$${netIncome.toStringAsFixed(2)}',
            subtitle: netIncome >= 0 ? 'Profit' : 'Loss',
            backgroundColor: netIncome >= 0
                ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                    .withAlpha(26)
                : theme.colorScheme.error.withAlpha(26),
            textColor: netIncome >= 0
                ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                : theme.colorScheme.error,
          ),
          SizedBox(height: 3.h),

          // Income vs Expense Trend Chart
          IncomeExpenseTrendWidget(
            trendData: _trendData,
            timeframe: _selectedTimeframe,
          ),
          SizedBox(height: 3.h),

          // Expense Distribution Chart
          ExpenseChartWidget(categoryData: _expenseCategories),
        ],
      ),
    );
  }

  Widget _buildReportsCategoriesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Top spending summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Highest Spending',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _expenseCategories.first['category'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(_expenseCategories.first['amount'] as double).toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.dividerColor,
                ),
                Column(
                  children: [
                    Text(
                      'Total Categories',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_expenseCategories.length}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Active',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Category Breakdown
          CategoryBreakdownWidget(
            categoryData: _expenseCategories,
            timeframe: _selectedTimeframe,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsBudgetTab(ThemeData theme) {
    final totalBudget = _budgetData.fold<double>(
        0, (sum, item) => sum + (item['budget'] as double));
    final totalSpent = _budgetData.fold<double>(
        0, (sum, item) => sum + (item['spent'] as double));
    final remainingBudget = totalBudget - totalSpent;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Budget Overview Cards
          Row(
            children: [
              Expanded(
                child: FinancialSummaryCardWidget(
                  title: 'Total Budget',
                  amount: '\$${totalBudget.toStringAsFixed(2)}',
                  subtitle: _selectedTimeframe,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  textColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: FinancialSummaryCardWidget(
                  title: 'Total Spent',
                  amount: '\$${totalSpent.toStringAsFixed(2)}',
                  subtitle:
                      '${((totalSpent / totalBudget) * 100).toStringAsFixed(1)}% used',
                  backgroundColor: theme.colorScheme.error.withAlpha(26),
                  textColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          FinancialSummaryCardWidget(
            title: 'Remaining Budget',
            amount: '\$${remainingBudget.toStringAsFixed(2)}',
            subtitle: remainingBudget >= 0 ? 'Available' : 'Over Budget',
            backgroundColor: remainingBudget >= 0
                ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                    .withAlpha(26)
                : theme.colorScheme.error.withAlpha(26),
            textColor: remainingBudget >= 0
                ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                : theme.colorScheme.error,
          ),
          SizedBox(height: 3.h),

          // Budget Progress
          BudgetProgressWidget(budgetData: _budgetData),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          _buildProfileHeader(),
          SizedBox(height: 3.h),
          _buildSecuritySection(),
          SizedBox(height: 2.h),
          _buildPrivacySection(),
          SizedBox(height: 2.h),
          _buildAppPreferencesSection(),
          SizedBox(height: 2.h),
          _buildNotificationSection(),
          SizedBox(height: 2.h),
          _buildAccountSection(),
          SizedBox(height: 2.h),
          _buildDangerZone(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: _userData["profileImage"] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData["name"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      _userData["email"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 2.w),
                    _userData["emailVerified"] == true
                        ? CustomIconWidget(
                            iconName: 'verified',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 16,
                          )
                        : Container(),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _userData["subscriptionType"] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'edit',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return SettingsSectionWidget(
      title: 'Security',
      children: [
        SettingsToggleWidget(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint or face ID to unlock',
          value: biometricEnabled,
          onChanged: (value) {
            setState(() {
              biometricEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'fingerprint',
        ),
        SettingsItemWidget(
          title: 'Change Password',
          subtitle: 'Update your account password',
          iconName: 'lock',
          onTap: () => _showChangePasswordDialog(),
        ),
        SettingsToggleWidget(
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          value: twoFactorEnabled,
          onChanged: (value) {
            setState(() {
              twoFactorEnabled = value;
            });
            HapticFeedback.lightImpact();
            if (value) {
              _showTwoFactorSetupDialog();
            }
          },
          iconName: 'security',
        ),
        SettingsItemWidget(
          title: 'Session Management',
          subtitle: 'Manage active sessions',
          iconName: 'devices',
          onTap: () => _showSessionManagementDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return SettingsSectionWidget(
      title: 'Privacy',
      children: [
        SettingsItemWidget(
          title: 'Data Export',
          subtitle: 'Download your data as encrypted file',
          iconName: 'download',
          onTap: () => _exportData(),
        ),
        SettingsToggleWidget(
          title: 'Analytics Preferences',
          subtitle: 'Help improve the app with usage data',
          value: analyticsEnabled,
          onChanged: (value) {
            setState(() {
              analyticsEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'analytics',
        ),
        SettingsItemWidget(
          title: 'Local Storage Management',
          subtitle: 'Manage cached data and storage',
          iconName: 'storage',
          onTap: () => _showStorageManagementDialog(),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return SettingsSectionWidget(
      title: 'App Preferences',
      children: [
        SettingsItemWidget(
          title: 'Currency Selection',
          subtitle: selectedCurrency,
          iconName: 'attach_money',
          onTap: () => _showCurrencySelector(),
        ),
        SettingsItemWidget(
          title: 'Date Format',
          subtitle: selectedDateFormat,
          iconName: 'calendar_today',
          onTap: () => _showDateFormatSelector(),
        ),
        SettingsItemWidget(
          title: 'Number Format',
          subtitle: selectedNumberFormat,
          iconName: 'format_list_numbered',
          onTap: () => _showNumberFormatSelector(),
        ),
        SettingsItemWidget(
          title: 'Theme Selection',
          subtitle: selectedTheme,
          iconName: 'palette',
          onTap: () => _showThemeSelector(),
        ),
        SettingsItemWidget(
          title: 'Language Settings',
          subtitle: selectedLanguage,
          iconName: 'language',
          onTap: () => _showLanguageSelector(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return SettingsSectionWidget(
      title: 'Notifications',
      children: [
        SettingsToggleWidget(
          title: 'Transaction Alerts',
          subtitle: 'Get notified of new transactions',
          value: transactionAlerts,
          onChanged: (value) {
            setState(() {
              transactionAlerts = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'notifications',
        ),
        SettingsToggleWidget(
          title: 'Security Notifications',
          subtitle: 'Important security updates',
          value: securityNotifications,
          onChanged: (value) {
            setState(() {
              securityNotifications = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'security',
        ),
        SettingsToggleWidget(
          title: 'Weekly Reports',
          subtitle: 'Summary of your financial activity',
          value: weeklyReports,
          onChanged: (value) {
            setState(() {
              weeklyReports = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'assessment',
        ),
        SettingsToggleWidget(
          title: 'Budget Reminders',
          subtitle: 'Alerts when approaching budget limits',
          value: budgetReminders,
          onChanged: (value) {
            setState(() {
              budgetReminders = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'account_balance_wallet',
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSectionWidget(
      title: 'Account',
      children: [
        SettingsItemWidget(
          title: 'Profile Information',
          subtitle: 'Update your personal details',
          iconName: 'person',
          onTap: () => Navigator.pushNamed(context, '/profile-screen'),
        ),
        SettingsItemWidget(
          title: 'Email Verification',
          subtitle: _userData["emailVerified"] == true
              ? 'Verified'
              : 'Pending verification',
          iconName: 'email',
          onTap: () =>
              Navigator.pushNamed(context, '/email-verification-screen'),
          trailing: _userData["emailVerified"] == true
              ? CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 20,
                )
              : CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
        ),
        SettingsItemWidget(
          title: 'Linked Accounts',
          subtitle: 'Manage connected bank accounts',
          iconName: 'account_balance',
          onTap: () => _showLinkedAccountsDialog(),
        ),
        SettingsItemWidget(
          title: 'Subscription Details',
          subtitle: 'Manage your subscription',
          iconName: 'card_membership',
          onTap: () => _showSubscriptionDialog(),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return SettingsSectionWidget(
      title: 'Danger Zone',
      children: [
        SettingsItemWidget(
          title: 'Sign Out',
          subtitle: 'Sign out from this device',
          iconName: 'logout',
          onTap: () => _showSignOutDialog(),
          isDestructive: true,
        ),
        SettingsItemWidget(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          iconName: 'delete_forever',
          onTap: () => _showDeleteAccountDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
        await _checkMerchantStatus();
      }
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _checkMerchantStatus() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        // Check if user has merchant-level access based on trust tier
        setState(() {
          _isMerchant = _userProfile?['trust_tier'] == 'gold' ||
              _userProfile?['trust_tier'] == 'platinum';
        });
      }
    } catch (e) {
      // Default to regular user if check fails
      setState(() {
        _isMerchant = false;
      });
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Text('This will redirect you to the password change screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/password-reset-screen');
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Two-Factor Authentication'),
        content: Text(
            'Setting up 2FA will require you to use an authenticator app or SMS verification.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                twoFactorEnabled = false;
              });
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Setup'),
          ),
        ],
      ),
    );
  }

  void _showSessionManagementDialog() {
    final List<Map<String, dynamic>> sessions = [
      {
        "device": "iPhone 14 Pro",
        "location": "New York, NY",
        "lastActive": "Active now",
        "current": true,
      },
      {
        "device": "MacBook Pro",
        "location": "New York, NY",
        "lastActive": "2 hours ago",
        "current": false,
      }
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Active Sessions'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sessions.map((session) {
              return ListTile(
                leading: CustomIconWidget(
                  iconName:
                      session["current"] == true ? 'smartphone' : 'laptop',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(session["device"] as String),
                subtitle:
                    Text('${session["location"]} • ${session["lastActive"]}'),
                trailing: session["current"] == true
                    ? Chip(
                        label: Text('Current'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.tertiaryContainer,
                      )
                    : TextButton(
                        onPressed: () {},
                        child: Text('Revoke'),
                      ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text(
            'Your data will be exported as an encrypted file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Data export started. You will be notified when ready.'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showStorageManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Cache Size'),
              subtitle: Text('45.2 MB'),
              trailing: TextButton(
                onPressed: () {},
                child: Text('Clear'),
              ),
            ),
            ListTile(
              title: Text('Offline Data'),
              subtitle: Text('128.5 MB'),
              trailing: TextButton(
                onPressed: () {},
                child: Text('Manage'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySelector() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Currency'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDateFormatSelector() {
    final formats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Date Format'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formats.map((format) {
              return RadioListTile<String>(
                title: Text(format),
                value: format,
                groupValue: selectedDateFormat,
                onChanged: (value) {
                  setState(() {
                    selectedDateFormat = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showNumberFormatSelector() {
    final formats = ['1,000.00', '1.000,00', '1 000.00'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Number Format'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formats.map((format) {
              return RadioListTile<String>(
                title: Text(format),
                value: format,
                groupValue: selectedNumberFormat,
                onChanged: (value) {
                  setState(() {
                    selectedNumberFormat = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    final themes = ['Light', 'Dark', 'System'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: themes.map((theme) {
              return RadioListTile<String>(
                title: Text(theme),
                value: theme,
                groupValue: selectedTheme,
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLinkedAccountsDialog() {
    final List<Map<String, dynamic>> accounts = [
      {
        "bankName": "Chase Bank",
        "accountType": "Checking",
        "lastFour": "1234",
        "connected": true,
      },
      {
        "bankName": "Bank of America",
        "accountType": "Savings",
        "lastFour": "5678",
        "connected": false,
      }
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Linked Accounts'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: accounts.map((account) {
              return ListTile(
                leading: CustomIconWidget(
                  iconName: 'account_balance',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(account["bankName"] as String),
                subtitle: Text(
                    '${account["accountType"]} •••• ${account["lastFour"]}'),
                trailing: account["connected"] == true
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 20,
                      )
                    : TextButton(
                        onPressed: () {},
                        child: Text('Connect'),
                      ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Add Account'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: ${_userData["subscriptionType"]}'),
            SizedBox(height: 1.h),
            Text('Next Billing: January 15, 2024'),
            SizedBox(height: 1.h),
            Text('Amount: \$9.99/month'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text(
            'Are you sure you want to sign out? You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Final Confirmation',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type "DELETE" to confirm account deletion:'),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Account deletion initiated. You will receive a confirmation email.'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
