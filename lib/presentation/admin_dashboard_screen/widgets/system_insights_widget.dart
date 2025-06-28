import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class SystemInsightsWidget extends StatelessWidget {
  final Map<String, dynamic> systemData;
  final AnimationController animation;

  const SystemInsightsWidget({
    super.key,
    required this.systemData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.insights,
                        color: const Color(0xFFFF5722),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Insights',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Performance metrics and fraud detection',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAnomalyAlert(),
                  ],
                ),

                SizedBox(height: 4.h),

                // Transaction processing overview
                _buildTransactionProcessingOverview(),

                SizedBox(height: 3.h),

                // Trust score algorithm performance
                _buildTrustScorePerformance(),

                SizedBox(height: 3.h),

                // Merchant verification stats
                _buildMerchantVerificationStats(),

                SizedBox(height: 3.h),

                // Anomaly detection dashboard
                _buildAnomalyDetectionDashboard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnomalyAlert() {
    final pendingAnomalies = systemData['pending_anomalies'] ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: pendingAnomalies > 0
            ? Colors.red.withAlpha(26)
            : Colors.green.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pendingAnomalies > 0
              ? Colors.red.withAlpha(77)
              : Colors.green.withAlpha(77),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pendingAnomalies > 0 ? Icons.warning : Icons.check_circle,
            color: pendingAnomalies > 0 ? Colors.red : Colors.green,
            size: 14.sp,
          ),
          SizedBox(width: 1.w),
          Text(
            pendingAnomalies > 0 ? '$pendingAnomalies alerts' : 'All clear',
            style: TextStyle(
              color: pendingAnomalies > 0 ? Colors.red : Colors.green,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionProcessingOverview() {
    final statusBreakdown = Map<String, int>.from(
      systemData['transaction_status_breakdown'] ?? {},
    );
    final confidenceBreakdown = Map<String, int>.from(
      systemData['confidence_level_breakdown'] ?? {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Processing Overview',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildStatusChart(statusBreakdown),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildConfidenceChart(confidenceBreakdown),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChart(Map<String, int> statusBreakdown) {
    if (statusBreakdown.isEmpty) {
      return Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Status',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: PieChart(
              PieChartData(
                sections: _generateStatusSections(statusBreakdown),
                centerSpaceRadius: 5.w,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          _buildStatusLegend(statusBreakdown),
        ],
      ),
    );
  }

  Widget _buildConfidenceChart(Map<String, int> confidenceBreakdown) {
    if (confidenceBreakdown.isEmpty) {
      return Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidence Levels',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: PieChart(
              PieChartData(
                sections: _generateConfidenceSections(confidenceBreakdown),
                centerSpaceRadius: 5.w,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          _buildConfidenceLegend(confidenceBreakdown),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateStatusSections(
      Map<String, int> statusBreakdown) {
    final statusColors = {
      'pending': Colors.orange,
      'verified': Colors.green,
      'flagged': Colors.red,
      'confirmed': Colors.blue,
    };

    final total =
        statusBreakdown.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return statusBreakdown.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = statusColors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 6.w,
        titleStyle: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _generateConfidenceSections(
      Map<String, int> confidenceBreakdown) {
    final confidenceColors = {
      'low': Colors.red[300]!,
      'medium': Colors.orange[300]!,
      'high': Colors.green[300]!,
    };

    final total =
        confidenceBreakdown.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return confidenceBreakdown.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = confidenceColors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 6.w,
        titleStyle: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildStatusLegend(Map<String, int> statusBreakdown) {
    final statusColors = {
      'pending': Colors.orange,
      'verified': Colors.green,
      'flagged': Colors.red,
      'confirmed': Colors.blue,
    };

    return Column(
      children: statusBreakdown.entries.map((entry) {
        final color = statusColors[entry.key] ?? Colors.grey;
        return Padding(
          padding: EdgeInsets.only(bottom: 0.5.h),
          child: Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '${_formatStatusName(entry.key)}: ${entry.value}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfidenceLegend(Map<String, int> confidenceBreakdown) {
    final confidenceColors = {
      'low': Colors.red[300]!,
      'medium': Colors.orange[300]!,
      'high': Colors.green[300]!,
    };

    return Column(
      children: confidenceBreakdown.entries.map((entry) {
        final color = confidenceColors[entry.key] ?? Colors.grey;
        return Padding(
          padding: EdgeInsets.only(bottom: 0.5.h),
          child: Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '${_formatConfidenceName(entry.key)}: ${entry.value}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrustScorePerformance() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withAlpha(26),
            const Color(0xFF2E7D32).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: const Color(0xFF4CAF50),
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Trust Score Algorithm Performance',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  label: 'Accuracy Rate',
                  value: '94.7%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildPerformanceMetric(
                  label: 'Processing Speed',
                  value: '< 50ms',
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantVerificationStats() {
    final merchantStatusBreakdown = Map<String, int>.from(
      systemData['merchant_status_breakdown'] ?? {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merchant Verification Statistics',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: merchantStatusBreakdown.entries.map((entry) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    right: entry != merchantStatusBreakdown.entries.last
                        ? 3.w
                        : 0),
                child: _buildMerchantStatusCard(
                  status: entry.key,
                  count: entry.value,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMerchantStatusCard({
    required String status,
    required int count,
  }) {
    final statusColors = {
      'active': Colors.green,
      'inactive': Colors.grey,
      'verified': Colors.blue,
      'pending': Colors.orange,
    };

    final color = statusColors[status] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            _formatStatusName(status),
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyDetectionDashboard() {
    final totalAnomalies = systemData['total_anomalies'] ?? 0;
    final reviewedAnomalies = systemData['reviewed_anomalies'] ?? 0;
    final pendingAnomalies = systemData['pending_anomalies'] ?? 0;
    final anomalyBreakdown = Map<String, int>.from(
      systemData['anomaly_breakdown'] ?? {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fraud Detection & Anomalies',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: pendingAnomalies > 0
                    ? Colors.red.withAlpha(26)
                    : Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pendingAnomalies pending',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: pendingAnomalies > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildAnomalyMetricCard(
                title: 'Total Detected',
                value: totalAnomalies.toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildAnomalyMetricCard(
                title: 'Reviewed',
                value: reviewedAnomalies.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildAnomalyMetricCard(
                title: 'Pending',
                value: pendingAnomalies.toString(),
                icon: Icons.pending,
                color: Colors.red,
              ),
            ),
          ],
        ),
        if (anomalyBreakdown.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Anomaly Types',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: anomalyBreakdown.entries.map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatAnomalyType(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAnomalyMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16.sp,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatStatusName(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  String _formatConfidenceName(String confidence) {
    return confidence.substring(0, 1).toUpperCase() + confidence.substring(1);
  }

  String _formatAnomalyType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}
