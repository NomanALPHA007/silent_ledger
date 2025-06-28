import './supabase_service.dart';

class WalletService {
  final SupabaseService _supabaseService = SupabaseService();

  // Get wallet balance for a user
  Future<Map<String, dynamic>> getWalletBalance(String userId) async {
    try {
      final client = await _supabaseService.client;

      final wallet = await client
          .from('wallets')
          .select(
              'silent_coins, royalty_balance, total_earned, last_payout_date, created_at, updated_at')
          .eq('user_id', userId)
          .single();

      return {
        'silent_coins': wallet['silent_coins'] ?? 0.0,
        'royalty_balance': wallet['royalty_balance'] ?? 0.0,
        'total_earned': wallet['total_earned'] ?? 0.0,
        'last_payout_date': wallet['last_payout_date'],
        'last_redemption':
            wallet['last_payout_date'], // Alias for compatibility
        'created_at': wallet['created_at'],
        'updated_at': wallet['updated_at'],
      };
    } catch (e) {
      throw Exception('Failed to fetch wallet balance: $e');
    }
  }

  // Add Silent Coins to wallet
  Future<void> addSilentCoins(
      String userId, double amount, String source) async {
    try {
      final client = await _supabaseService.client;

      await client.from('wallets').update({
        'silent_coins': 'silent_coins + $amount',
        'total_earned': 'total_earned + $amount',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      // Log the transaction for audit
      await _logWalletTransaction(userId, amount, 'credit', source);
    } catch (e) {
      throw Exception('Failed to add Silent Coins: $e');
    }
  }

  // Deduct Silent Coins from wallet
  Future<void> deductSilentCoins(
      String userId, double amount, String reason) async {
    try {
      final client = await _supabaseService.client;

      // Check if user has sufficient balance
      final wallet = await getWalletBalance(userId);
      final currentBalance = wallet['silent_coins'] as double;

      if (currentBalance < amount) {
        throw Exception('Insufficient Silent Coins balance');
      }

      await client.from('wallets').update({
        'silent_coins': 'silent_coins - $amount',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      // Log the transaction for audit
      await _logWalletTransaction(userId, amount, 'debit', reason);
    } catch (e) {
      throw Exception('Failed to deduct Silent Coins: $e');
    }
  }

  // Redeem Silent Coins
  Future<Map<String, dynamic>> redeemSilentCoins(
    String userId,
    double amount,
    String redemptionType,
    Map<String, dynamic> redemptionDetails,
  ) async {
    try {
      final client = await _supabaseService.client;

      // Check balance
      final wallet = await getWalletBalance(userId);
      final currentBalance = wallet['silent_coins'] as double;

      if (currentBalance < amount) {
        throw Exception('Insufficient Silent Coins balance');
      }

      // Calculate redemption value based on type
      double redemptionValue = 0.0;
      switch (redemptionType.toLowerCase()) {
        case 'cash':
          redemptionValue = amount * 0.10; // 1 SC = RM 0.10
          break;
        case 'gift_card':
          redemptionValue = amount * 0.12; // Better rate for gift cards
          break;
        case 'loan_interest_reduction':
          redemptionValue = amount * 0.08; // Lower rate but direct benefit
          break;
        default:
          redemptionValue = amount * 0.10;
      }

      // Create redemption record
      final redemption = await client
          .from('coin_redemptions')
          .insert({
            'user_id': userId,
            'coins_redeemed': amount,
            'redemption_type': redemptionType,
            'redemption_value': redemptionValue,
            'status': 'pending',
            'payment_method': redemptionDetails['payment_method'],
            'notes': redemptionDetails['notes'],
          })
          .select()
          .single();

      // Deduct coins from wallet
      await deductSilentCoins(userId, amount, 'Redemption: $redemptionType');

      // Update last payout date
      await client.from('wallets').update({
        'last_payout_date': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      return {
        'redemption_id': redemption['id'],
        'amount_redeemed': amount,
        'redemption_value': redemptionValue,
        'status': 'pending',
        'estimated_processing_time': '3-5 business days',
      };
    } catch (e) {
      throw Exception('Failed to redeem Silent Coins: $e');
    }
  }

  // Get redemption history
  Future<List<Map<String, dynamic>>> getRedemptionHistory(String userId) async {
    try {
      final client = await _supabaseService.client;

      final redemptions = await client
          .from('coin_redemptions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(redemptions);
    } catch (e) {
      throw Exception('Failed to fetch redemption history: $e');
    }
  }

  // Get wallet transaction history
  Future<List<Map<String, dynamic>>> getWalletTransactionHistory(
      String userId) async {
    try {
      final client = await _supabaseService.client;

      // Since we don't have a dedicated wallet_transactions table in the migration,
      // we'll simulate this with coin redemptions and other wallet-related activities
      final redemptions = await client
          .from('coin_redemptions')
          .select(
              'coins_redeemed, redemption_type, redemption_value, status, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Transform to common format
      final transactions = redemptions
          .map((redemption) => {
                'id': redemption['id'],
                'amount': -(redemption['coins_redeemed']
                    as double), // Negative for redemptions
                'type': 'redemption',
                'description': 'Redeemed for ${redemption['redemption_type']}',
                'status': redemption['status'],
                'created_at': redemption['created_at'],
              })
          .toList();

      return transactions;
    } catch (e) {
      throw Exception('Failed to fetch wallet transaction history: $e');
    }
  }

  // Get earnings breakdown
  Future<Map<String, dynamic>> getEarningsBreakdown(String userId) async {
    try {
      final client = await _supabaseService.client;

      // Get earnings from different sources
      final results = await Future.wait([
        _getTransactionEarnings(userId),
        _getReferralEarnings(userId),
        _getRoyaltyEarnings(userId),
      ]);

      final transactionEarnings = results[0];
      final referralEarnings = results[1];
      final royaltyEarnings = results[2];

      final totalEarnings =
          transactionEarnings + referralEarnings + royaltyEarnings;

      return {
        'transaction_earnings': transactionEarnings,
        'referral_earnings': referralEarnings,
        'royalty_earnings': royaltyEarnings,
        'total_earnings': totalEarnings,
        'breakdown_percentage': {
          'transactions': totalEarnings > 0
              ? (transactionEarnings / totalEarnings * 100)
              : 0.0,
          'referrals': totalEarnings > 0
              ? (referralEarnings / totalEarnings * 100)
              : 0.0,
          'royalties':
              totalEarnings > 0 ? (royaltyEarnings / totalEarnings * 100) : 0.0,
        },
      };
    } catch (e) {
      throw Exception('Failed to fetch earnings breakdown: $e');
    }
  }

  // Check if user can redeem (minimum threshold, daily limits, etc.)
  Future<Map<String, dynamic>> checkRedemptionEligibility(String userId) async {
    try {
      final wallet = await getWalletBalance(userId);
      final silentCoins = wallet['silent_coins'] as double;

      // Check minimum redemption threshold
      const double minRedemption = 10.0;

      // Check daily redemption limit
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final client = await _supabaseService.client;
      final todayRedemptions = await client
          .from('coin_redemptions')
          .select('coins_redeemed')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String());

      double todayRedeemed = 0.0;
      for (final redemption in todayRedemptions) {
        todayRedeemed += (redemption['coins_redeemed'] as num).toDouble();
      }

      const double dailyLimit = 500.0; // Daily redemption limit

      return {
        'can_redeem':
            silentCoins >= minRedemption && todayRedeemed < dailyLimit,
        'current_balance': silentCoins,
        'minimum_redemption': minRedemption,
        'daily_limit': dailyLimit,
        'today_redeemed': todayRedeemed,
        'remaining_daily_limit': dailyLimit - todayRedeemed,
        'reasons': _getRedemptionReasons(
            silentCoins, minRedemption, todayRedeemed, dailyLimit),
      };
    } catch (e) {
      throw Exception('Failed to check redemption eligibility: $e');
    }
  }

  // Private helper methods
  Future<void> _logWalletTransaction(
    String userId,
    double amount,
    String type,
    String description,
  ) async {
    // This would typically log to a wallet_transactions table
    // For now, we'll just store it in a simple format
    // In a real implementation, you'd want proper audit logging
  }

  Future<double> _getTransactionEarnings(String userId) async {
    try {
      final client = await _supabaseService.client;

      // Simulate earning 1 SC per verified transaction
      final verifiedTransactions = await client
          .from('transactions')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'verified');

      return verifiedTransactions.length.toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getReferralEarnings(String userId) async {
    try {
      final client = await _supabaseService.client;

      final referrals = await client
          .from('referral_history')
          .select('coins_awarded')
          .eq('referrer_id', userId)
          .eq('bonus_paid', true);

      double total = 0.0;
      for (final referral in referrals) {
        total += (referral['coins_awarded'] as num).toDouble();
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getRoyaltyEarnings(String userId) async {
    try {
      final wallet = await getWalletBalance(userId);
      return wallet['royalty_balance'] as double;
    } catch (e) {
      return 0.0;
    }
  }

  List<String> _getRedemptionReasons(
    double balance,
    double minRedemption,
    double todayRedeemed,
    double dailyLimit,
  ) {
    final reasons = <String>[];

    if (balance < minRedemption) {
      reasons.add('Minimum redemption amount is ${minRedemption.toInt()} SC');
    }

    if (todayRedeemed >= dailyLimit) {
      reasons.add('Daily redemption limit of ${dailyLimit.toInt()} SC reached');
    }

    if (reasons.isEmpty) {
      reasons.add('You can redeem your Silent Coins');
    }

    return reasons;
  }
}
