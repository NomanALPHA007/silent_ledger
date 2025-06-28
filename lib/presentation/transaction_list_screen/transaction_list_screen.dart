import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/transaction_detail_bottom_sheet_widget.dart';
import './widgets/transaction_item_widget.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with TickerProviderStateMixin {
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

  // Mock transaction data
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
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupTransactionsByDate();
    final hasTransactions = _filteredTransactions.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
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
              PopupMenuItem(value: 'Category', child: Text('Sort by Category')),
            ],
          ),
        ],
      ),
      body: Column(
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

                        final dateKey =
                            groupedTransactions.keys.elementAt(index);
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
                            ...transactions.map((transaction) =>
                                TransactionItemWidget(
                                  transaction: transaction,
                                  onTap: () => _onTransactionTap(transaction),
                                  onEdit: () => _onTransactionEdit(transaction),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/add-transaction-screen'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
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
}
