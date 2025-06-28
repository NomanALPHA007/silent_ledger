import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ApiMonitoringWidget extends StatelessWidget {
  final Map<String, dynamic> apiData;
  final AnimationController animation;

  const ApiMonitoringWidget({
    super.key,
    required this.apiData,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
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
                        color: const Color(0xFF9C27B0).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.api,
                        color: const Color(0xFF9C27B0),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Access Monitoring',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Usage statistics and integration health',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildHealthStatusIndicator(),
                  ],
                ),

                SizedBox(height: 4.h),

                // API overview metrics
                _buildApiOverviewCards(),

                SizedBox(height: 3.h),

                // Client tier distribution
                _buildClientTierDistribution(),

                SizedBox(height: 3.h),

                // Performance metrics
                _buildPerformanceMetrics(),

                SizedBox(height: 3.h),

                // Recent API activity
                _buildRecentApiActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusIndicator() {
    final totalClients = apiData['total_clients'] ?? 0;
    final activeClients = apiData['active_clients'] ?? 0;
    final avgResponseTime = apiData['avg_response_time']?.toDouble() ?? 0.0;

    String status;
    Color statusColor;
    IconData statusIcon;

    if (totalClients == 0) {
      status = 'No Clients';
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    } else if (avgResponseTime > 1000) {
      status = 'Slow';
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else if (activeClients / totalClients >= 0.8) {
      status = 'Healthy';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      status = 'Normal';
      statusColor = Colors.blue;
      statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 14.sp,
          ),
          SizedBox(width: 1.w),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiOverviewCards() {
    final totalClients = apiData['total_clients'] ?? 0;
    final activeClients = apiData['active_clients'] ?? 0;
    final totalApiRevenue = apiData['total_api_revenue']?.toDouble() ?? 0.0;
    final requestsToday = apiData['total_requests_today'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Clients',
                value: totalClients.toString(),
                subtitle: '$activeClients active',
                icon: Icons.groups,
                color: const Color(0xFF2196F3),
                trend: '+5%',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildMetricCard(
                title: 'API Revenue',
                value: '\$${_formatNumber(totalApiRevenue)}',
                subtitle: 'Monthly earnings',
                icon: Icons.monetization_on,
                color: const Color(0xFF4CAF50),
                trend: '+12%',
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        _buildTodayRequestsCard(requestsToday),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              if (trend != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRequestsCard(int requestsToday) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFF8E24AA)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s API Requests',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withAlpha(230),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _formatNumber(requestsToday.toDouble()),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white.withAlpha(204),
                      size: 14.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Real-time monitoring active',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.speed,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTierDistribution() {
    final clientsByTier =
        Map<String, int>.from(apiData['clients_by_tier'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Tier Distribution',
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
              child: _buildTierCard(
                tier: 'Basic',
                count: clientsByTier['basic'] ?? 0,
                color: const Color(0xFF607D8B),
                features: 'Limited access',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildTierCard(
                tier: 'Premium',
                count: clientsByTier['premium'] ?? 0,
                color: const Color(0xFF2196F3),
                features: 'Enhanced features',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildTierCard(
                tier: 'Enterprise',
                count: clientsByTier['enterprise'] ?? 0,
                color: const Color(0xFF9C27B0),
                features: 'Full access',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String tier,
    required int count,
    required Color color,
    required String features,
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
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTierIcon(tier),
              color: color,
              size: 18.sp,
            ),
          ),
          SizedBox(height: 1.h),
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
            tier,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            features,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final avgResponseTime = apiData['avg_response_time']?.toDouble() ?? 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
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
                child: _buildPerformanceItem(
                  label: 'Avg Response Time',
                  value: '${avgResponseTime.toStringAsFixed(0)}ms',
                  icon: Icons.speed,
                  color: avgResponseTime > 1000 ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildPerformanceItem(
                  label: 'Uptime',
                  value: '99.9%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceItem(
                  label: 'Rate Limit Status',
                  value: 'Normal',
                  icon: Icons.security,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildPerformanceItem(
                  label: 'Error Rate',
                  value: '0.1%',
                  icon: Icons.error_outline,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem({
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApiActivity() {
    final recentLogs = List<Map<String, dynamic>>.from(
      apiData['recent_logs'] ?? [],
    );

    if (recentLogs.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No recent API activity',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent API Activity',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all API logs
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...recentLogs.take(5).map((log) {
          return Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(log['status_code']).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(log['method']),
                    color: _getStatusColor(log['status_code']),
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log['method']} ${log['endpoint']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDateTime(log['called_at']),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(log['status_code']).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log['status_code'].toString(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getStatusColor(log['status_code']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${log['response_time_ms'] ?? 0}ms',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'basic':
        return Icons.layers_outlined;
      case 'premium':
        return Icons.layers;
      case 'enterprise':
        return Icons.business;
      default:
        return Icons.api;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Icons.download;
      case 'POST':
        return Icons.upload;
      case 'PUT':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.code;
    }
  }

  Color _getStatusColor(dynamic statusCode) {
    final code = int.tryParse(statusCode.toString()) ?? 0;
    if (code >= 200 && code < 300) {
      return Colors.green;
    } else if (code >= 400 && code < 500) {
      return Colors.orange;
    } else if (code >= 500) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateTime.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
