import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/merchant_service.dart';
import '../../services/transaction_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_picker_widget.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_picker_widget.dart';
import './widgets/confidence_level_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/merchant_qr_widget.dart';
import './widgets/passive_mode_toggle_widget.dart';
import './widgets/quick_amount_widget.dart';
import './widgets/receipt_scanner_widget.dart';
import './widgets/smart_autofill_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isExpense = true;
  String _selectedCategory = '';
  String _selectedAccount = '';
  DateTime _selectedDate = DateTime.now();
  String _receiptImagePath = '';
  bool _isLoading = false;
  bool _showOptionalFields = false;

  // New Smart Data Capture features
  String _confidenceLevel = 'medium';
  bool _passiveModeEnabled = false;
  Map<String, dynamic>? _selectedMerchant;
  String? _currentLocation;

  // Services
  final TransactionService _transactionService = TransactionService();
  final MerchantService _merchantService = MerchantService();

  late TabController _tabController;

  // Mock data for categories
  final List<Map<String, dynamic>> _categories = [
    {
      "id": "1",
      "name": "Food & Dining",
      "icon": "restaurant",
      "color": 0xFFFF6B6B,
      "isFrequent": true
    },
    {
      "id": "2",
      "name": "Transportation",
      "icon": "directions_car",
      "color": 0xFF4ECDC4,
      "isFrequent": true
    },
    {
      "id": "3",
      "name": "Shopping",
      "icon": "shopping_bag",
      "color": 0xFF45B7D1,
      "isFrequent": true
    },
    {
      "id": "4",
      "name": "Entertainment",
      "icon": "movie",
      "color": 0xFF96CEB4,
      "isFrequent": false
    },
    {
      "id": "5",
      "name": "Bills & Utilities",
      "icon": "receipt",
      "color": 0xFFFECA57,
      "isFrequent": true
    },
    {
      "id": "6",
      "name": "Healthcare",
      "icon": "local_hospital",
      "color": 0xFFFF9FF3,
      "isFrequent": false
    },
    {
      "id": "7",
      "name": "Education",
      "icon": "school",
      "color": 0xFF54A0FF,
      "isFrequent": false
    },
    {
      "id": "8",
      "name": "Travel",
      "icon": "flight",
      "color": 0xFF5F27CD,
      "isFrequent": false
    },
  ];

  // Mock data for accounts
  final List<Map<String, dynamic>> _accounts = [
    {
      "id": "1",
      "name": "Checking Account",
      "balance": 2450.75,
      "type": "checking"
    },
    {
      "id": "2",
      "name": "Savings Account",
      "balance": 8920.50,
      "type": "savings"
    },
    {"id": "3", "name": "Credit Card", "balance": -1250.25, "type": "credit"},
    {"id": "4", "name": "Cash", "balance": 150.00, "type": "cash"},
  ];

  // Mock suggestions for descriptions
  final List<String> _descriptionSuggestions = [
    "Grocery shopping",
    "Gas station",
    "Coffee shop",
    "Restaurant dinner",
    "Online purchase",
    "ATM withdrawal",
    "Salary deposit",
    "Freelance payment",
    "Rent payment",
    "Utility bill",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = _categories.first['id'];
    _selectedAccount = _accounts.first['id'];
    _loadUserLocation();
  }

  void _loadUserLocation() {
    // Mock location loading - in real implementation, use location services
    setState(() {
      _currentLocation = "Downtown Plaza";
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTransactionTypeChanged(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
    });
    HapticFeedback.lightImpact();
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    HapticFeedback.selectionClick();
  }

  void _onAccountSelected(String accountId) {
    setState(() {
      _selectedAccount = accountId;
    });
    HapticFeedback.selectionClick();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onReceiptScanned(String imagePath, Map<String, String> extractedData) {
    setState(() {
      _receiptImagePath = imagePath;
      if (extractedData['amount'] != null &&
          extractedData['amount']!.isNotEmpty) {
        _amountController.text = extractedData['amount']!;
      }
      if (extractedData['description'] != null &&
          extractedData['description']!.isNotEmpty) {
        _descriptionController.text = extractedData['description']!;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleOptionalFields() {
    setState(() {
      _showOptionalFields = !_showOptionalFields;
    });
    HapticFeedback.lightImpact();
  }

  void _onQuickAmountSelected(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
    });
    HapticFeedback.mediumImpact();
  }

  void _onConfidenceLevelChanged(String level) {
    setState(() {
      _confidenceLevel = level;
    });
    HapticFeedback.selectionClick();
  }

  void _onPassiveModeToggle(bool enabled) {
    setState(() {
      _passiveModeEnabled = enabled;
    });
    HapticFeedback.lightImpact();
  }

  void _onMerchantScanned(Map<String, dynamic> merchant) {
    setState(() {
      _selectedMerchant = merchant.isNotEmpty ? merchant : null;
    });

    if (merchant.isNotEmpty) {
      // Auto-fill category if merchant has one
      if (merchant['category'] != null) {
        final matchingCategory = _categories.firstWhere(
          (cat) => cat['name'] == merchant['category'],
          orElse: () => _categories.first,
        );
        _onCategorySelected(matchingCategory['id']);
      }

      // Auto-fill description with merchant name
      if (merchant['name'] != null) {
        _descriptionController.text = merchant['name'];
      }
    }

    HapticFeedback.mediumImpact();
  }

  void _onSmartAutofill(Map<String, String> autofillData) {
    setState(() {
      if (autofillData['amount'] != null) {
        _amountController.text = autofillData['amount']!;
      }
      if (autofillData['description'] != null) {
        _descriptionController.text = autofillData['description']!;
      }
      if (autofillData['category'] != null) {
        final matchingCategory = _categories.firstWhere(
          (cat) => cat['name'] == autofillData['category'],
          orElse: () => _categories.first,
        );
        _onCategorySelected(matchingCategory['id']);
      }
      if (autofillData['confidence'] != null) {
        _confidenceLevel = autofillData['confidence']!;
      }
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _saveTransaction({bool saveAndAddAnother = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_amountController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter an amount",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final finalAmount = _isExpense ? -amount : amount;

      final selectedCategoryData = _categories.firstWhere(
        (cat) => cat['id'] == _selectedCategory,
        orElse: () => _categories.first,
      );

      // Save transaction using Supabase
      final transactionData = await _transactionService.createTransaction(
        amount: finalAmount,
        description: _descriptionController.text.trim(),
        category: selectedCategoryData['name'],
        account: _selectedAccount,
        transactionDate: _selectedDate,
        merchantId: _selectedMerchant?['id'],
        confidenceLevel: _confidenceLevel,
        autoLogged: _passiveModeEnabled,
        receiptImageUrl:
            _receiptImagePath.isNotEmpty ? _receiptImagePath : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        tags: _tagsController.text.trim().isNotEmpty
            ? _tagsController.text
                .trim()
                .split(',')
                .map((e) => e.trim())
                .toList()
            : null,
        geolocation:
            _currentLocation != null ? [0.0, 0.0] : null, // Mock coordinates
      );

      // Notify merchant if selected
      if (_selectedMerchant != null) {
        await _merchantService.notifyMerchantOfTransaction(
          _selectedMerchant!['id'],
          transactionData['id'],
        );
      }

      HapticFeedback.mediumImpact();

      if (saveAndAddAnother) {
        Fluttertoast.showToast(
          msg: "Transaction saved! Add another",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _clearForm();
      } else {
        Fluttertoast.showToast(
          msg: "Transaction saved successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.pop(context, transactionData);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error saving transaction: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _notesController.clear();
    _tagsController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _receiptImagePath = '';
      _showOptionalFields = false;
      _selectedMerchant = null;
      _confidenceLevel = 'medium';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Add Transaction',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_receiptImagePath.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _receiptImagePath = '';
                });
              },
              icon: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Smart Autofill Suggestions
                      SmartAutofillWidget(
                        onAutofillData: _onSmartAutofill,
                        currentLocation: _currentLocation,
                        currentTime: TimeOfDay.now(),
                      ),

                      SizedBox(height: 3.h),

                      // Amount Input Section
                      AmountInputWidget(
                        controller: _amountController,
                        isExpense: _isExpense,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Quick Amount Selection
                      QuickAmountWidget(
                        onAmountSelected: _onQuickAmountSelected,
                        isExpense: _isExpense,
                      ),

                      SizedBox(height: 3.h),

                      // Transaction Type Toggle
                      TransactionTypeToggleWidget(
                        isExpense: _isExpense,
                        onChanged: _onTransactionTypeChanged,
                      ),

                      SizedBox(height: 3.h),

                      // Confidence Level Widget
                      ConfidenceLevelWidget(
                        selectedLevel: _confidenceLevel,
                        onLevelChanged: _onConfidenceLevelChanged,
                      ),

                      SizedBox(height: 3.h),

                      // Merchant QR Code Widget
                      MerchantQRWidget(
                        onMerchantScanned: _onMerchantScanned,
                        selectedMerchantId: _selectedMerchant?['id'],
                      ),

                      SizedBox(height: 3.h),

                      // Category Picker
                      CategoryPickerWidget(
                        categories: _categories,
                        selectedCategoryId: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),

                      SizedBox(height: 3.h),

                      // Description Field
                      _buildDescriptionField(theme),

                      SizedBox(height: 3.h),

                      // Account Picker
                      AccountPickerWidget(
                        accounts: _accounts,
                        selectedAccountId: _selectedAccount,
                        onAccountSelected: _onAccountSelected,
                      ),

                      SizedBox(height: 3.h),

                      // Date Picker
                      DatePickerWidget(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                      ),

                      SizedBox(height: 3.h),

                      // Receipt Scanner
                      ReceiptScannerWidget(
                        receiptImagePath: _receiptImagePath,
                        onReceiptScanned: _onReceiptScanned,
                      ),

                      SizedBox(height: 3.h),

                      // Passive Mode Toggle
                      PassiveModeToggleWidget(
                        isEnabled: _passiveModeEnabled,
                        onToggle: _onPassiveModeToggle,
                      ),

                      SizedBox(height: 2.h),

                      // Optional Fields Toggle
                      _buildOptionalFieldsToggle(theme),

                      if (_showOptionalFields) ...[
                        SizedBox(height: 2.h),
                        _buildOptionalFields(theme),
                      ],

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              _buildBottomActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter transaction description',
            suffixIcon: _descriptionController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _descriptionController.clear();
                      setState(() {});
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  )
                : null,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        if (_descriptionController.text.isNotEmpty &&
            _getFilteredSuggestions().isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(maxHeight: 20.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _getFilteredSuggestions().length,
              itemBuilder: (context, index) {
                final suggestion = _getFilteredSuggestions()[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    suggestion,
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    _descriptionController.text = suggestion;
                    setState(() {});
                    FocusScope.of(context).nextFocus();
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  List<String> _getFilteredSuggestions() {
    final query = _descriptionController.text.toLowerCase();
    if (query.isEmpty) return [];

    return _descriptionSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .take(3)
        .toList();
  }

  Widget _buildOptionalFieldsToggle(ThemeData theme) {
    return InkWell(
      onTap: _toggleOptionalFields,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _showOptionalFields ? 'expand_less' : 'expand_more',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Optional Fields',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes Field
        Text(
          'Notes',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Add additional notes (optional)',
          ),
          maxLines: 3,
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: 2.h),

        // Tags Field
        Text(
          'Tags',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _tagsController,
          decoration: const InputDecoration(
            hintText: 'Add tags separated by commas',
          ),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save & Add Another Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => _saveTransaction(saveAndAddAnother: true),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Text('Save & Add Another'),
              ),
            ),

            SizedBox(height: 2.h),

            // Save Transaction Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveTransaction(),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
