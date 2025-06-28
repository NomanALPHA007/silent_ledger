import './supabase_service.dart';

class AdminService {
  final SupabaseService _supabaseService = SupabaseService();

  // Check if current user is admin (platinum trust tier)
  Future<bool> isAdmin() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) return false;

      final profile = await client
          .from('user_profiles')
          .select('trust_tier')
          .eq('id', user.id)
          .maybeSingle();

      return profile?['trust_tier'] == 'platinum';
    } catch (e) {
      return false;
    }
  }

  // Get platform revenue metrics
  Future<Map<String, dynamic>> getRevenueMetrics() async {
    try {
      final client = await _supabaseService.client;

      // Get monthly revenue breakdown
      final monthlyRevenue = await client
          .from('revenue_tracking')
          .select('source, amount, created_at')
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String())
          .order('created_at', ascending: false);

      // Calculate total revenue
      double totalRevenue = 0;
      final Map<String, double> revenueBySource = {};

      for (final record in monthlyRevenue) {
        final amount = double.tryParse(record['amount'].toString()) ?? 0;
        totalRevenue += amount;

        final source = record['source'] as String;
        revenueBySource[source] = (revenueBySource[source] ?? 0) + amount;
      }

      // Get subscription metrics
      final subscriptions = await client
          .from('subscription_plans')
          .select('tier, monthly_price')
          .eq('status', 'active');

      final Map<String, int> subscriptionCounts = {};
      double monthlySubscriptionRevenue = 0;

      for (final sub in subscriptions) {
        final tier = sub['tier'] as String;
        subscriptionCounts[tier] = (subscriptionCounts[tier] ?? 0) + 1;
        monthlySubscriptionRevenue +=
            double.tryParse(sub['monthly_price'].toString()) ?? 0;
      }

      return {
        'total_revenue': totalRevenue,
        'revenue_by_source': revenueBySource,
        'monthly_subscription_revenue': monthlySubscriptionRevenue,
        'subscription_counts': subscriptionCounts,
        'recent_transactions': monthlyRevenue.take(10).toList(),
      };
    } catch (e) {
      throw Exception('Failed to fetch revenue metrics: $e');
    }
  }

  // Get user management statistics
  Future<Map<String, dynamic>> getUserManagementStats() async {
    try {
      final client = await _supabaseService.client;

      // Get user counts by trust tier
      final usersByTier = await client
          .from('user_profiles')
          .select('trust_tier')
          .neq('trust_tier', '');

      final Map<String, int> tierCounts = {};
      for (final user in usersByTier) {
        final tier = user['trust_tier'] as String;
        tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
      }

      // Get recent user registrations
      final recentUsers = await client
          .from('user_profiles')
          .select('full_name, email, trust_tier, trust_score, created_at')
          .order('created_at', ascending: false)
          .limit(10);

      // Get total transaction volume
      final transactions = await client
          .from('transactions')
          .select('amount, status')
          .eq('status', 'verified');

      double totalVolume = 0;
      for (final transaction in transactions) {
        totalVolume +=
            double.tryParse(transaction['amount'].toString())?.abs() ?? 0;
      }

      return {
        'total_users': usersByTier.length,
        'users_by_tier': tierCounts,
        'recent_users': recentUsers,
        'total_transaction_volume': totalVolume,
        'verified_transactions': transactions.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch user management stats: $e');
    }
  }

  // Get API access monitoring data
  Future<Map<String, dynamic>> getApiMonitoring() async {
    try {
      final client = await _supabaseService.client;

      // Get API access statistics
      final apiAccess = await client.from('api_access').select(
          'tier, calls_used, calls_per_month, monthly_fee, is_active, last_call_at');

      // Get recent API usage logs
      final recentLogs = await client
          .from('api_usage_logs')
          .select('endpoint, method, status_code, response_time_ms, called_at')
          .order('called_at', ascending: false)
          .limit(50);

      // Calculate API metrics
      int totalApiClients = apiAccess.length;
      int activeClients =
          apiAccess.where((client) => client['is_active'] == true).length;

      double totalApiRevenue = 0;
      Map<String, int> clientsByTier = {};

      for (final client in apiAccess) {
        totalApiRevenue +=
            double.tryParse(client['monthly_fee'].toString()) ?? 0;
        final tier = client['tier'] as String;
        clientsByTier[tier] = (clientsByTier[tier] ?? 0) + 1;
      }

      // Calculate average response time
      double totalResponseTime = 0;
      int responseTimeCount = 0;

      for (final log in recentLogs) {
        if (log['response_time_ms'] != null) {
          totalResponseTime +=
              double.tryParse(log['response_time_ms'].toString()) ?? 0;
          responseTimeCount++;
        }
      }

      double avgResponseTime =
          responseTimeCount > 0 ? totalResponseTime / responseTimeCount : 0;

      return {
        'total_clients': totalApiClients,
        'active_clients': activeClients,
        'total_api_revenue': totalApiRevenue,
        'clients_by_tier': clientsByTier,
        'recent_logs': recentLogs.take(20).toList(),
        'avg_response_time': avgResponseTime,
        'total_requests_today': recentLogs.where((log) {
          final logDate = DateTime.parse(log['called_at']);
          final today = DateTime.now();
          return logDate.year == today.year &&
              logDate.month == today.month &&
              logDate.day == today.day;
        }).length,
      };
    } catch (e) {
      throw Exception('Failed to fetch API monitoring data: $e');
    }
  }

  // Get system insights and performance metrics
  Future<Map<String, dynamic>> getSystemInsights() async {
    try {
      final client = await _supabaseService.client;

      // Get transaction processing metrics
      final transactions = await client
          .from('transactions')
          .select('status, confidence_level, created_at')
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String());

      Map<String, int> statusCounts = {};
      Map<String, int> confidenceCounts = {};

      for (final transaction in transactions) {
        final status = transaction['status'] as String;
        final confidence = transaction['confidence_level'] as String;

        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        confidenceCounts[confidence] = (confidenceCounts[confidence] ?? 0) + 1;
      }

      // Get merchant verification stats
      final merchants = await client
          .from('merchant_profiles')
          .select('status')
          .neq('status', '');

      Map<String, int> merchantStatusCounts = {};
      for (final merchant in merchants) {
        final status = merchant['status'] as String;
        merchantStatusCounts[status] = (merchantStatusCounts[status] ?? 0) + 1;
      }

      // Get anomaly detection results
      final anomalies = await client
          .from('anomalies')
          .select('anomaly_type, severity, reviewed')
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String());

      Map<String, int> anomalyCounts = {};
      int reviewedAnomalies = 0;

      for (final anomaly in anomalies) {
        final type = anomaly['anomaly_type'] as String;
        anomalyCounts[type] = (anomalyCounts[type] ?? 0) + 1;

        if (anomaly['reviewed'] == true) {
          reviewedAnomalies++;
        }
      }

      return {
        'transaction_status_breakdown': statusCounts,
        'confidence_level_breakdown': confidenceCounts,
        'merchant_status_breakdown': merchantStatusCounts,
        'anomaly_breakdown': anomalyCounts,
        'total_anomalies': anomalies.length,
        'reviewed_anomalies': reviewedAnomalies,
        'pending_anomalies': anomalies.length - reviewedAnomalies,
      };
    } catch (e) {
      throw Exception('Failed to fetch system insights: $e');
    }
  }

  // Get flagged transactions for review
  Future<List<Map<String, dynamic>>> getFlaggedTransactions() async {
    try {
      final client = await _supabaseService.client;

      final flaggedTransactions = await client
          .from('transactions')
          .select('''
            id, amount, description, status, anomaly_flags, created_at,
            user_profiles:user_id (full_name, email, trust_tier),
            merchant_profiles:merchant_id (name, status)
          ''')
          .neq('anomaly_flags', '')
          .order('created_at', ascending: false)
          .limit(25);

      return List<Map<String, dynamic>>.from(flaggedTransactions);
    } catch (e) {
      throw Exception('Failed to fetch flagged transactions: $e');
    }
  }

  // Generate comprehensive admin reports
  Future<Map<String, dynamic>> generateSystemReport() async {
    try {
      final results = await Future.wait([
        getRevenueMetrics(),
        getUserManagementStats(),
        getApiMonitoring(),
        getSystemInsights(),
      ]);

      return {
        'revenue_metrics': results[0],
        'user_stats': results[1],
        'api_monitoring': results[2],
        'system_insights': results[3],
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate system report: $e');
    }
  }

  // Manage API keys (activate/deactivate)
  Future<void> toggleApiKeyStatus(String apiKey, bool isActive) async {
    try {
      final client = await _supabaseService.client;

      await client.from('api_access').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('api_key', apiKey);
    } catch (e) {
      throw Exception('Failed to toggle API key status: $e');
    }
  }

  // Review and mark anomaly as processed
  Future<void> reviewAnomaly(String anomalyId) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client.from('anomalies').update({
        'reviewed': true,
        'reviewer_id': user.id,
      }).eq('id', anomalyId);
    } catch (e) {
      throw Exception('Failed to review anomaly: $e');
    }
  }
}
