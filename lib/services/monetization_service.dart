import './supabase_service.dart';

class MonetizationService {
  final SupabaseService _supabaseService = SupabaseService();

  // Get dashboard stats for monetization center
  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      final client = await _supabaseService.client;

      // Get wallet balance
      final wallet = await client
          .from('wallets')
          .select('silent_coins, total_earned')
          .eq('user_id', userId)
          .maybeSingle();

      // Get API usage for current month
      final startOfMonth =
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      final apiUsage = await client
          .from('api_usage_logs')
          .select('id')
          .eq('client_id', userId)
          .gte('called_at', startOfMonth.toIso8601String());

      // Get referral stats
      final referralProgram = await client
          .from('referral_program')
          .select('total_referrals, successful_referrals, total_coins_earned')
          .eq('referrer_id', userId)
          .maybeSingle();

      return {
        'wallet_balance': wallet?['silent_coins'] ?? 0.0,
        'total_earned': wallet?['total_earned'] ?? 0.0,
        'api_calls_used': apiUsage.length,
        'total_referrals': referralProgram?['total_referrals'] ?? 0,
        'successful_referrals': referralProgram?['successful_referrals'] ?? 0,
        'referral_coins_earned': referralProgram?['total_coins_earned'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Get referral history
  Future<List<dynamic>> getReferralHistory() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final referralHistory = await client
          .from('referral_history')
          .select('''
            *,
            user_profiles!referred_user_id(full_name, email)
          ''')
          .eq('referrer_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      return referralHistory;
    } catch (e) {
      throw Exception('Failed to fetch referral history: $e');
    }
  }

  // Create referral code
  Future<String> createReferralCode() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user already has a referral program
      final existingProgram = await client
          .from('referral_program')
          .select('referral_code')
          .eq('referrer_id', user.id)
          .maybeSingle();

      if (existingProgram != null) {
        return existingProgram['referral_code'] as String;
      }

      // Create new referral program with generated code
      final referralCode = _generateReferralCode();

      final newProgram = await client
          .from('referral_program')
          .insert({
            'referrer_id': user.id,
            'referral_code': referralCode,
          })
          .select('referral_code')
          .single();

      return newProgram['referral_code'] as String;
    } catch (e) {
      throw Exception('Failed to create referral code: $e');
    }
  }

  // Get user subscription plan
  Future<Map<String, dynamic>> getUserSubscriptionPlan(String userId) async {
    try {
      final client = await _supabaseService.client;

      final subscription = await client
          .from('subscription_plans')
          .select('*')
          .eq('merchant_id', userId)
          .maybeSingle();

      if (subscription == null) {
        // Return default free plan
        return {
          'tier': 'free',
          'monthly_price': 0.00,
          'transaction_limit': 100,
          'api_calls_limit': 1000,
          'transactions_used': 0,
          'api_calls_used': 0,
          'analytics_enabled': false,
          'priority_support': false,
          'custom_branding': false,
        };
      }

      // Get usage statistics
      final transactionsUsed = await _getTransactionUsage(userId);
      final apiCallsUsed = await _getApiUsage(userId);

      return {
        ...subscription,
        'transactions_used': transactionsUsed,
        'api_calls_used': apiCallsUsed,
      };
    } catch (e) {
      throw Exception('Failed to fetch user subscription plan: $e');
    }
  }

  // Get revenue overview
  Future<Map<String, dynamic>> getRevenueOverview() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate daily revenue
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final dailyRevenue = await client
          .from('revenue_tracking')
          .select('amount')
          .eq('client_id', user.id)
          .gte('created_at', startOfDay.toIso8601String());

      // Calculate weekly revenue
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final weeklyRevenue = await client
          .from('revenue_tracking')
          .select('amount')
          .eq('client_id', user.id)
          .gte('created_at', startOfWeek.toIso8601String());

      // Calculate monthly revenue
      final startOfMonth = DateTime(today.year, today.month, 1);
      final monthlyRevenue = await client
          .from('revenue_tracking')
          .select('amount')
          .eq('client_id', user.id)
          .gte('created_at', startOfMonth.toIso8601String());

      double dailyTotal = 0.0;
      double weeklyTotal = 0.0;
      double monthlyTotal = 0.0;

      for (var record in dailyRevenue) {
        dailyTotal += (record['amount'] as num).toDouble();
      }

      for (var record in weeklyRevenue) {
        weeklyTotal += (record['amount'] as num).toDouble();
      }

      for (var record in monthlyRevenue) {
        monthlyTotal += (record['amount'] as num).toDouble();
      }

      // Calculate growth percentage (mock data for now)
      final growthPercentage = 12.5;

      return {
        'daily': dailyTotal,
        'weekly': weeklyTotal,
        'monthly': monthlyTotal,
        'growth_percentage': growthPercentage,
      };
    } catch (e) {
      throw Exception('Failed to fetch revenue overview: $e');
    }
  }

  // Get user subscription
  Future<Map<String, dynamic>> getUserSubscription() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final subscription = await client
          .from('subscription_plans')
          .select('*')
          .eq('merchant_id', user.id)
          .maybeSingle();

      if (subscription == null) {
        // Return default free plan
        return {
          'tier': 'free',
          'monthly_price': 0.00,
          'transaction_limit': 100,
          'api_calls_limit': 1000,
          'transactions_used': 0,
          'api_calls_used': 0,
          'analytics_enabled': false,
          'priority_support': false,
          'custom_branding': false,
        };
      }

      // Get usage statistics
      final transactionsUsed = await _getTransactionUsage(user.id);
      final apiCallsUsed = await _getApiUsage(user.id);

      return {
        ...subscription,
        'transactions_used': transactionsUsed,
        'api_calls_used': apiCallsUsed,
      };
    } catch (e) {
      throw Exception('Failed to fetch user subscription: $e');
    }
  }

  // Update subscription tier
  Future<Map<String, dynamic>> updateSubscriptionTier(
      String userId, String tier) async {
    try {
      final client = await _supabaseService.client;

      final result = await client.rpc('update_subscription_tier', params: {
        'merchant_uuid': userId,
        'new_tier': tier,
        'stripe_sub_id': null,
      });

      return {'success': true, 'message': 'Subscription updated successfully'};
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Get wallet overview
  Future<Map<String, dynamic>> getWalletOverview() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final wallet = await client
          .from('wallets')
          .select('*')
          .eq('user_id', user.id)
          .single();

      // Get recent redemptions
      final recentRedemptions = await client
          .from('coin_redemptions')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      return {
        'silent_coins': wallet['silent_coins'] ?? 0.0,
        'royalty_balance': wallet['royalty_balance'] ?? 0.0,
        'total_earned': wallet['total_earned'] ?? 0.0,
        'recent_redemptions': recentRedemptions,
      };
    } catch (e) {
      throw Exception('Failed to fetch wallet overview: $e');
    }
  }

  // Redeem Silent Coins
  Future<Map<String, dynamic>> redeemCoins({
    required double amount,
    required String redemptionType,
    required double redemptionValue,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final redemptionId = await client.rpc('redeem_silent_coins', params: {
        'user_uuid': user.id,
        'coins_amount': amount,
        'redemption_type_param': redemptionType,
        'redemption_value_param': redemptionValue,
      });

      return {
        'success': true,
        'redemption_id': redemptionId,
        'message': 'Redemption request submitted successfully',
      };
    } catch (e) {
      throw Exception('Failed to redeem coins: $e');
    }
  }

  // Get referral program data
  Future<Map<String, dynamic>> getReferralProgram() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final referralProgram = await client
          .from('referral_program')
          .select('*')
          .eq('referrer_id', user.id)
          .maybeSingle();

      if (referralProgram == null) {
        // Create new referral program
        final newProgram = await client
            .from('referral_program')
            .insert({
              'referrer_id': user.id,
              'referral_code': _generateReferralCode(),
            })
            .select()
            .single();

        return newProgram;
      }

      // Get referral history
      final referralHistory = await client
          .from('referral_history')
          .select('''
            *,
            user_profiles!referred_user_id(full_name, email)
          ''')
          .eq('referrer_id', user.id)
          .order('created_at', ascending: false)
          .limit(10);

      return {
        ...referralProgram,
        'referral_history': referralHistory,
      };
    } catch (e) {
      throw Exception('Failed to fetch referral program: $e');
    }
  }

  // Create loan referral
  Future<Map<String, dynamic>> createLoanReferral({
    required double loanAmount,
    required String partnerName,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final referralId = await client.rpc('create_loan_referral', params: {
        'user_uuid': user.id,
        'loan_amount': loanAmount,
        'partner_name': partnerName,
      });

      return {
        'success': true,
        'referral_id': referralId,
        'message': 'Loan referral created successfully',
      };
    } catch (e) {
      throw Exception('Failed to create loan referral: $e');
    }
  }

  // Get API access information
  Future<Map<String, dynamic>> getApiAccess() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final apiAccess = await client
          .from('api_access')
          .select('*')
          .eq('client_id', user.id)
          .maybeSingle();

      if (apiAccess == null) {
        return {
          'has_access': false,
          'message': 'No API access configured',
        };
      }

      // Get recent API usage
      final recentUsage = await client
          .from('api_usage_logs')
          .select('*')
          .eq('client_id', user.id)
          .order('called_at', ascending: false)
          .limit(10);

      return {
        'has_access': true,
        ...apiAccess,
        'recent_usage': recentUsage,
      };
    } catch (e) {
      throw Exception('Failed to fetch API access: $e');
    }
  }

  // Generate API key
  Future<String> generateApiKey(String tier) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final apiKey = await client.rpc('generate_api_key', params: {
        'client_uuid': user.id,
        'tier_level': tier,
      });

      return apiKey as String;
    } catch (e) {
      throw Exception('Failed to generate API key: $e');
    }
  }

  // Private helper methods
  Future<int> _getTransactionUsage(String userId) async {
    final client = await _supabaseService.client;

    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final transactions = await client
        .from('transactions')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfMonth.toIso8601String());

    return transactions.length;
  }

  Future<int> _getApiUsage(String userId) async {
    final client = await _supabaseService.client;

    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final apiCalls = await client
        .from('api_usage_logs')
        .select('id')
        .eq('client_id', userId)
        .gte('called_at', startOfMonth.toIso8601String());

    return apiCalls.length;
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'REF${chars[(random % chars.length)]}${chars[((random ~/ 10) % chars.length)]}${chars[((random ~/ 100) % chars.length)]}${chars[((random ~/ 1000) % chars.length)]}';
  }
}
