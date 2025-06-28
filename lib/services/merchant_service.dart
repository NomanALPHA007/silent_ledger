import './supabase_service.dart';

class MerchantService {
  final SupabaseService _supabaseService = SupabaseService();

  // Create merchant profile
  Future<Map<String, dynamic>> createMerchant({
    required String name,
    required String location,
    required String category,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique QR code
      final qrCode =
          'QR_${name.toUpperCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await client
          .from('merchant_profiles')
          .insert({
            'name': name,
            'qr_code': qrCode,
            'location': location,
            'category': category,
            'owner_id': user.id,
            'status': 'pending',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create merchant: $e');
    }
  }

  // Get merchant by QR code
  Future<Map<String, dynamic>?> getMerchantByQRCode(String qrCode) async {
    try {
      final client = await _supabaseService.client;

      final response = await client.from('merchant_profiles').select('''
            *,
            user_profiles(full_name, email)
          ''').eq('qr_code', qrCode).maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch merchant by QR code: $e');
    }
  }

  // Get user's merchants
  Future<List<Map<String, dynamic>>> getUserMerchants() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('merchant_profiles')
          .select('*')
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user merchants: $e');
    }
  }

  // Update merchant verification status
  Future<Map<String, dynamic>> updateMerchantStatus(
      String merchantId, String status) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('merchant_profiles')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', merchantId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update merchant status: $e');
    }
  }

  // Get merchant analytics
  Future<Map<String, dynamic>> getMerchantAnalytics(String merchantId) async {
    try {
      final client = await _supabaseService.client;

      // Get total transactions for merchant
      final totalResponse = await client
          .from('transactions')
          .select('*')
          .eq('merchant_id', merchantId);

      // Get verified transactions for merchant
      final verifiedResponse = await client
          .from('transactions')
          .select('*')
          .eq('merchant_id', merchantId)
          .eq('status', 'verified');

      // Get total volume for merchant
      final volumeResponse = await client
          .from('transactions')
          .select('amount')
          .eq('merchant_id', merchantId)
          .eq('status', 'verified');

      double totalVolume = 0.0;
      for (var transaction in volumeResponse) {
        totalVolume += (transaction['amount'] as num).abs();
      }

      // Get recent transactions
      final recentTransactions = await client
          .from('transactions')
          .select('''
            *,
            user_profiles(full_name, email)
          ''')
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false)
          .limit(10);

      return {
        'total_transactions': totalResponse.length,
        'verified_transactions': verifiedResponse.length,
        'total_volume': totalVolume,
        'recent_transactions': recentTransactions,
      };
    } catch (e) {
      throw Exception('Failed to fetch merchant analytics: $e');
    }
  }

  // Search merchants
  Future<List<Map<String, dynamic>>> searchMerchants({
    String? name,
    String? category,
    String? location,
  }) async {
    try {
      final client = await _supabaseService.client;

      var query =
          client.from('merchant_profiles').select('*').eq('status', 'verified');

      if (name != null && name.isNotEmpty) {
        query = query.ilike('name', '%$name%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (location != null && location.isNotEmpty) {
        query = query.ilike('location', '%$location%');
      }

      final response = await query.order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search merchants: $e');
    }
  }

  // Get merchant categories
  Future<List<String>> getMerchantCategories() async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('merchant_profiles')
          .select('category')
          .eq('status', 'verified');

      final categories = <String>{};
      for (var merchant in response) {
        if (merchant['category'] != null) {
          categories.add(merchant['category'] as String);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to fetch merchant categories: $e');
    }
  }

  // Notify merchant of transaction
  Future<void> notifyMerchantOfTransaction(
      String merchantId, String transactionId) async {
    try {
      final client = await _supabaseService.client;

      // This could be expanded to send push notifications
      // For now, we'll just update the merchant's transaction count
      await client.rpc('increment_merchant_transactions', params: {
        'merchant_uuid': merchantId,
      });
    } catch (e) {
      throw Exception('Failed to notify merchant: $e');
    }
  }
}
