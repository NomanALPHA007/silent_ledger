import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class TransactionService {
  final SupabaseService _supabaseService = SupabaseService();

  // Create transaction with smart features
  Future<Map<String, dynamic>> createTransaction({
    required double amount,
    required String description,
    required String category,
    required String account,
    required DateTime transactionDate,
    String? merchantId,
    String confidenceLevel = 'medium',
    bool isRecurring = false,
    bool autoLogged = false,
    String? receiptImageUrl,
    String? notes,
    List<String>? tags,
    List<double>? geolocation,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('transactions')
          .insert({
            'user_id': user.id,
            'merchant_id': merchantId,
            'amount': amount,
            'description': description,
            'category': category,
            'account': account,
            'transaction_date': transactionDate.toIso8601String(),
            'confidence_level': confidenceLevel,
            'is_recurring': isRecurring,
            'auto_logged': autoLogged,
            'receipt_image_url': receiptImageUrl,
            'notes': notes,
            'tags': tags,
            'geolocation': geolocation != null && geolocation.length == 2
                ? 'POINT(${geolocation[0]} ${geolocation[1]})'
                : null,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Get user transactions with filtering
  Future<List<Map<String, dynamic>>> getUserTransactions({
    String? category,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      var query = client.from('transactions').select('''
            *,
            merchant_profiles(name, category)
          ''');

      // Apply user filter first
      query = query.eq('user_id', user.id);

      // Apply additional filters
      if (category != null) {
        query = query.eq('category', category);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (fromDate != null) {
        query = query.gte('transaction_date', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('transaction_date', toDate.toIso8601String());
      }

      // Apply ordering and pagination at the end
      final response = await query
          .order('transaction_date', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Verify transaction (for merchants)
  Future<Map<String, dynamic>> verifyTransaction(
      String transactionId, bool isVerified) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('transactions')
          .update({
            'status': isVerified ? 'verified' : 'flagged',
            'verification_count': isVerified ? 1 : 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to verify transaction: $e');
    }
  }

  // Get transaction analytics
  Future<Map<String, dynamic>> getTransactionAnalytics() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get total transactions
      final totalResponse =
          await client.from('transactions').select('*').eq('user_id', user.id);

      // Get verified transactions
      final verifiedResponse = await client
          .from('transactions')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', 'verified');

      // Get total volume
      final volumeResponse =
          await client.rpc('get_user_volume', params: {'user_uuid': user.id});

      // Get category breakdown
      final categoryResponse = await client
          .rpc('get_category_breakdown', params: {'user_uuid': user.id});

      return {
        'total_transactions': totalResponse.length ?? 0,
        'verified_transactions': verifiedResponse.length ?? 0,
        'total_volume': volumeResponse ?? 0.0,
        'categories': categoryResponse ?? [],
      };
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  // Get pending transactions for verification
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    try {
      final client = await _supabaseService.client;

      final response = await client.from('transactions').select('''
            *,
            user_profiles(full_name, email),
            merchant_profiles(name, category)
          ''').eq('status', 'pending').order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending transactions: $e');
    }
  }

  // Flag transaction for anomaly
  Future<void> flagTransactionAnomaly(
      String transactionId, String reason) async {
    try {
      final client = await _supabaseService.client;

      await client
          .rpc('flag_anomaly', params: {'transaction_uuid': transactionId});

      // Add custom anomaly reason if provided
      if (reason.isNotEmpty) {
        await client.from('transactions').update({
          'anomaly_flags': [reason],
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', transactionId);
      }
    } catch (e) {
      throw Exception('Failed to flag transaction: $e');
    }
  }

  // Get pending merchant transactions
  Future<List<Map<String, dynamic>>> getPendingMerchantTransactions() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final transactions = await client
          .from('transactions')
          .select('''
            *,
            user_profiles(full_name, email, trust_tier)
          ''')
          .eq('status', 'pending')
          .not('merchant_id', 'is', null)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(transactions);
    } catch (e) {
      throw Exception('Failed to fetch pending merchant transactions: $e');
    }
  }

  // Update transaction status
  Future<Map<String, dynamic>> updateTransactionStatus(
      String transactionId, String status) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('transactions')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update transaction status: $e');
    }
  }

  // Real-time subscription for user transactions
  RealtimeChannel subscribeToUserTransactions(
      Function(List<Map<String, dynamic>>) onUpdate) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return client
        .channel('user_transactions_${user.id}')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'transactions',
            filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: user.id),
            callback: (payload) async {
              // Refresh transactions when changes occur
              final transactions = await getUserTransactions();
              onUpdate(transactions);
            })
        .subscribe();
  }
}
