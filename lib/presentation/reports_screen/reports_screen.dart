import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/budget_progress_widget.dart';
import './widgets/category_breakdown_widget.dart';
import './widgets/expense_chart_widget.dart';
import './widgets/financial_summary_card_widget.dart';
import './widgets/income_expense_trend_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'This Month';
  final List<String> _timeframes = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year'
  ];

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
    },
  ];

  final List<Map<String, dynamic>> _trendData = [
    {"label": "Week 1", "income": 1200.0, "expense": 800.0},
    {"label": "Week 2", "income": 1500.0, "expense": 950.0},
    {"label": "Week 3", "income": 1100.0, "expense": 750.0},
    {"label": "Week 4", "income": 1800.0, "expense": 1100.0},
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
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalIncome = _trendData.fold<double>(
        0, (sum, item) => sum + (item['income'] as double));
    final totalExpense = _trendData.fold<double>(
        0, (sum, item) => sum + (item['expense'] as double));
    final netIncome = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Financial Reports',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.onSurface,
              size: 24,
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Budget'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(theme, totalIncome, totalExpense, netIncome),

          // Categories Tab
          _buildCategoriesTab(theme),

          // Budget Tab
          _buildBudgetTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
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

  Widget _buildCategoriesTab(ThemeData theme) {
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
                      _expenseCategories.first['category'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_expenseCategories.first['amount'].toStringAsFixed(2)}',
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

  Widget _buildBudgetTab(ThemeData theme) {
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
}
