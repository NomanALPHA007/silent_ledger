import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/monetization_service.dart';

class RevenueDashboardWidget extends StatefulWidget {
  const RevenueDashboardWidget({super.key});

  @override
  State<RevenueDashboardWidget> createState() => _RevenueDashboardWidgetState();
}

class _RevenueDashboardWidgetState extends State<RevenueDashboardWidget> {
  final MonetizationService _monetizationService = MonetizationService();

  List<dynamic> _monthlyRevenue = [];
  List<dynamic> _revenueHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Since getMonthlyRevenue is not defined in MonetizationService
      // Using empty list as fallback
      final monthlyData = [];

      // Since getRevenueHistory is not defined in MonetizationService
      // Using empty list as fallback
      final historyData = [];

      setState(() {
        _monthlyRevenue = monthlyData;
        _revenueHistory = historyData;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildMonthSelector(),
          SizedBox(height: 20.h),
          _buildRevenueOverview(),
          SizedBox(height: 20.h),
          _buildRevenueChart(),
          SizedBox(height: 20.h),
          _buildRevenueBreakdown(),
          SizedBox(height: 20.h),
          _buildRecentTransactions(),
        ]));
  }

  Widget _buildMonthSelector() {
    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Row(children: [
          Expanded(
              child: Text('Revenue Dashboard',
                  style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]))),
          PopupMenuButton<String>(
              onSelected: (value) {
                final parts = value.split('-');
                setState(() {
                  _selectedMonth = int.parse(parts[0]);
                  _selectedYear = int.parse(parts[1]);
                });
                _loadRevenueData();
              },
              itemBuilder: (context) {
                final months = [
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December'
                ];
                return List.generate(12, (index) {
                  final month = index + 1;
                  return PopupMenuItem(
                      value: '$month-$_selectedYear',
                      child: Text('${months[index]} $_selectedYear'));
                });
              },
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_getMonthName(_selectedMonth),
                        style: GoogleFonts.inter(
                            fontSize: 12.sp, color: Colors.grey[700])),
                    Icon(Icons.arrow_drop_down, size: 16.sp),
                  ]))),
        ]));
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildRevenueOverview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRevenue = _monthlyRevenue.fold<double>(
        0.0, (sum, item) => sum + (item['total_amount'] ?? 0.0));

    return Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Revenue',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8.h),
          Text('RM ${totalRevenue.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                  fontSize: 32.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text('${_getMonthName(_selectedMonth)} $_selectedYear',
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white70)),
          SizedBox(height: 16.h),
          Row(children: [
            _buildRevenueMetric('Sources', _monthlyRevenue.length.toString()),
            SizedBox(width: 20.w),
            _buildRevenueMetric(
                'Transactions',
                _monthlyRevenue
                    .fold<int>(
                        0,
                        (sum, item) =>
                            sum + (item['transaction_count'] ?? 0) as int)
                    .toString()),
          ]),
        ]));
  }

  Widget _buildRevenueMetric(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600)),
      Text(label,
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white70)),
    ]);
  }

  Widget _buildRevenueChart() {
    if (_monthlyRevenue.isEmpty) {
      return Container(
          height: 200.h,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.grey.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ]),
          child: Center(
              child: Text('No revenue data available',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: Colors.grey[600]))));
    }

    return Container(
        height: 250.h,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Revenue by Source',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          Expanded(
              child: PieChart(PieChartData(
                  sections: _buildPieChartSections(), sectionsSpace: 2))),
        ]));
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      const Color(0xFF2E7D32),
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return _monthlyRevenue.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final source = data['source_type'] ?? 'unknown';
      final amount = data['total_amount'] ?? 0.0;

      return PieChartSectionData(
          color: colors[index % colors.length],
          value: amount,
          title: '${amount.toStringAsFixed(0)}',
          titleStyle: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white));
    }).toList();
  }

  Widget _buildRevenueBreakdown() {
    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Revenue Breakdown',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          if (_monthlyRevenue.isEmpty)
            Text('No revenue data available',
                style:
                    GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]))
          else
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _monthlyRevenue.length,
                itemBuilder: (context, index) {
                  final revenue = _monthlyRevenue[index];
                  return _buildRevenueBreakdownItem(revenue);
                }),
        ]));
  }

  Widget _buildRevenueBreakdownItem(Map<String, dynamic> revenue) {
    final source = revenue['source_type'] ?? 'unknown';
    final amount = revenue['total_amount'] ?? 0.0;
    final count = revenue['transaction_count'] ?? 0;

    IconData icon = Icons.monetization_on;
    Color color = Colors.grey;

    switch (source) {
      case 'subscription':
        icon = Icons.card_membership;
        color = const Color(0xFF2E7D32);
        break;
      case 'api_usage':
        icon = Icons.api;
        color = Colors.blue;
        break;
      case 'coin_store':
        icon = Icons.store;
        color = Colors.orange;
        break;
      case 'loan_referral':
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
      case 'data_export':
        icon = Icons.download;
        color = Colors.red;
        break;
    }

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(color: color.withAlpha(26)),
              child: Icon(icon, color: color, size: 20.sp)),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(source.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800])),
                Text('$count transactions',
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: Colors.grey[600])),
              ])),
          Text('RM ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
        ]));
  }

  Widget _buildRecentTransactions() {
    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Recent Revenue',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
            TextButton(
                onPressed: () {
                  // Navigate to full revenue history
                },
                child: Text('View All',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xFF2E7D32)))),
          ]),
          SizedBox(height: 16.h),
          if (_revenueHistory.isEmpty)
            Text('No recent transactions',
                style:
                    GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]))
          else
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _revenueHistory.length > 10 ? 10 : _revenueHistory.length,
                itemBuilder: (context, index) {
                  final transaction = _revenueHistory[index];
                  return _buildRevenueTransactionItem(transaction);
                }),
        ]));
  }

  Widget _buildRevenueTransactionItem(Map<String, dynamic> transaction) {
    final source = transaction['source'] ?? 'unknown';
    final amount = transaction['amount'] ?? 0.0;
    final description = transaction['description'] ?? '';
    final createdAt = DateTime.parse(
        transaction['created_at'] ?? DateTime.now().toIso8601String());

    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Container(
              width: 4.w,
              height: 20.h,
              decoration: BoxDecoration(color: const Color(0xFF2E7D32))),
          SizedBox(width: 8.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    description.isNotEmpty
                        ? description
                        : source.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800])),
                Text('${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: GoogleFonts.inter(
                        fontSize: 10.sp, color: Colors.grey[600])),
              ])),
          Text('+RM ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32))),
        ]));
  }
}
