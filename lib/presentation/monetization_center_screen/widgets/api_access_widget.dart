import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/monetization_service.dart';
import '../../../services/auth_service.dart';

class ApiAccessWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const ApiAccessWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<ApiAccessWidget> createState() => _ApiAccessWidgetState();
}

class _ApiAccessWidgetState extends State<ApiAccessWidget> {
  final MonetizationService _monetizationService = MonetizationService();
  final AuthService _authService = AuthService();

  List<dynamic> _apiAccess = [];
  List<dynamic> _usageLogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApiData();
  }

  Future<void> _loadApiData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user == null) return;

      final apiAccess = await _monetizationService.getApiAccess();
      final usageLogs = await _monetizationService.getApiAccess();

      setState(() {
        _apiAccess = apiAccess as List<dynamic>;
        _usageLogs = usageLogs;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateApiKey(String tier) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return;

      final apiKey = await _monetizationService.generateApiKey(tier);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('API key generated successfully!'),
          backgroundColor: Colors.green));

      await _loadApiData();
      widget.onRefresh();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to generate API key: $error'),
          backgroundColor: Colors.red));
    }
  }

  void _copyApiKey(String apiKey) {
    Clipboard.setData(ClipboardData(text: apiKey));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('API key copied to clipboard'),
        duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildApiAccessSection(),
          SizedBox(height: 20.h),
          _buildUsageStatistics(),
          SizedBox(height: 20.h),
          _buildRecentUsage(),
          SizedBox(height: 20.h),
          _buildApiDocumentation(),
        ]));
  }

  Widget _buildApiAccessSection() {
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
            Text('API Access Keys',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
            PopupMenuButton<String>(
                onSelected: _generateApiKey,
                itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'basic', child: Text('Generate Basic Key')),
                      const PopupMenuItem(
                          value: 'premium',
                          child: Text('Generate Premium Key')),
                      const PopupMenuItem(
                          value: 'enterprise',
                          child: Text('Generate Enterprise Key')),
                    ],
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('Generate',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ]))),
          ]),
          SizedBox(height: 16.h),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_apiAccess.isEmpty)
            Center(
                child: Column(children: [
              Icon(Icons.api, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text('No API keys generated yet',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: Colors.grey[600])),
            ]))
          else
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _apiAccess.length,
                itemBuilder: (context, index) {
                  final apiKey = _apiAccess[index];
                  return _buildApiKeyCard(apiKey);
                }),
        ]));
  }

  Widget _buildApiKeyCard(Map<String, dynamic> apiKey) {
    final tier = apiKey['tier'] ?? 'basic';
    final callsUsed = apiKey['calls_used'] ?? 0;
    final callsLimit = apiKey['calls_per_month'] ?? 0;
    final usagePercentage = callsLimit > 0 ? (callsUsed / callsLimit) : 0.0;

    Color tierColor = Colors.grey;
    switch (tier) {
      case 'premium':
        tierColor = const Color(0xFF2E7D32);
        break;
      case 'enterprise':
        tierColor = Colors.amber[600]!;
        break;
    }

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: tierColor.withAlpha(26)),
                child: Text(tier.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: tierColor,
                        fontWeight: FontWeight.w600))),
            Row(children: [
              IconButton(
                  onPressed: () => _copyApiKey(apiKey['api_key']),
                  icon: Icon(Icons.copy, size: 16.sp, color: Colors.grey[600])),
              Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                      color: apiKey['is_active'] ? Colors.green : Colors.red,
                      shape: BoxShape.circle)),
            ]),
          ]),
          SizedBox(height: 12.h),
          Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(color: Colors.grey[100]),
              child: Row(children: [
                Expanded(
                    child: Text(
                        '${apiKey['api_key'].toString().substring(0, 20)}...',
                        style: GoogleFonts.sourceCodePro(
                            fontSize: 12.sp, color: Colors.grey[700]))),
                Icon(Icons.visibility_off,
                    size: 16.sp, color: Colors.grey[500]),
              ])),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Usage This Month',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[600])),
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                      value: usagePercentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          usagePercentage > 0.8 ? Colors.red : tierColor)),
                  SizedBox(height: 4.h),
                  Text('$callsUsed / $callsLimit calls',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp, color: Colors.grey[600])),
                ])),
            SizedBox(width: 16.w),
            Text('RM ${apiKey['monthly_fee']?.toStringAsFixed(2) ?? '0.00'}',
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
          ]),
        ]));
  }

  Widget _buildUsageStatistics() {
    if (_usageLogs.isEmpty) return const SizedBox.shrink();

    final totalCalls = _usageLogs.length;
    final successfulCalls =
        _usageLogs.where((log) => log['status_code'] < 400).length;
    final errorCalls = totalCalls - successfulCalls;
    final avgResponseTime = _usageLogs
            .map((log) => log['response_time_ms'] ?? 0)
            .reduce((a, b) => a + b) ~/
        totalCalls;

    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Usage Statistics',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(
                child: _buildStatCard('Total Calls', totalCalls.toString(),
                    Icons.api, Colors.blue)),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildStatCard(
                    'Success Rate',
                    '${((successfulCalls / totalCalls) * 100).toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green)),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
                child: _buildStatCard(
                    'Errors', errorCalls.toString(), Icons.error, Colors.red)),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildStatCard('Avg Response', '${avgResponseTime}ms',
                    Icons.speed, Colors.orange)),
          ]),
        ]));
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(color: color.withAlpha(26)),
        child: Column(children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800])),
          Text(title,
              style:
                  GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildRecentUsage() {
    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recent API Calls',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          if (_usageLogs.isEmpty)
            Text('No API calls yet',
                style:
                    GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]))
          else
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usageLogs.length > 10 ? 10 : _usageLogs.length,
                itemBuilder: (context, index) {
                  final log = _usageLogs[index];
                  return _buildUsageLogItem(log);
                }),
        ]));
  }

  Widget _buildUsageLogItem(Map<String, dynamic> log) {
    final statusCode = log['status_code'] ?? 0;
    final isSuccess = statusCode < 400;
    final endpoint = log['endpoint'] ?? '';
    final method = log['method'] ?? '';
    final responseTime = log['response_time_ms'] ?? 0;

    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Container(
              width: 4.w,
              height: 20.h,
              decoration:
                  BoxDecoration(color: isSuccess ? Colors.green : Colors.red)),
          SizedBox(width: 8.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('$method $endpoint',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800])),
                Text('Status: $statusCode • ${responseTime}ms',
                    style: GoogleFonts.inter(
                        fontSize: 10.sp, color: Colors.grey[600])),
              ])),
        ]));
  }

  Widget _buildApiDocumentation() {
    return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('API Documentation',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          SizedBox(height: 16.h),
          _buildDocumentationItem('Trust Score API', '/api/trustscore/{uid}',
              'Get user trust score and verification data'),
          _buildDocumentationItem(
              'Credit Profile API',
              '/api/credit/profile/{uid}',
              'Return user credit profile for loan decisions'),
          _buildDocumentationItem(
              'City Statistics API',
              '/api/public/cityStats',
              'Get anonymized spending trends by region'),
          SizedBox(height: 16.h),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {
                    // Open API documentation
                  },
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder()),
                  child: Text('View Full Documentation',
                      style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500)))),
        ]));
  }

  Widget _buildDocumentationItem(
      String title, String endpoint, String description) {
    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800])),
          SizedBox(height: 4.h),
          Text(endpoint,
              style: GoogleFonts.sourceCodePro(
                  fontSize: 12.sp, color: const Color(0xFF2E7D32))),
          SizedBox(height: 2.h),
          Text(description,
              style:
                  GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
        ]));
  }
}