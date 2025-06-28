import './supabase_service.dart';

class TrustService {
  final SupabaseService _supabaseService = SupabaseService();

  // Get trust score for a user
  Future<Map<String, dynamic>> getTrustScore(String userId) async {
    try {
      final client = await _supabaseService.client;

      // Get user profile with trust data
      final profile = await client
          .from('user_profiles')
          .select(
              'trust_score, trust_tier, total_verified_volume, confirmation_percentage')
          .eq('id', userId)
          .single();

      // Calculate completeness percentage
      final profileFields = ['full_name', 'email'];
      final completedFields = profileFields
          .where((field) =>
              profile[field] != null && profile[field].toString().isNotEmpty)
          .length;
      final completeness = (completedFields / profileFields.length) * 100;

      return {
        'trust_score': profile['trust_score'] ?? 0.0,
        'trust_tier': profile['trust_tier'] ?? 'bronze',
        'total_verified_volume': profile['total_verified_volume'] ?? 0.0,
        'confirmation_percentage': profile['confirmation_percentage'] ?? 0.0,
        'completeness_percentage': completeness,
      };
    } catch (e) {
      throw Exception('Failed to fetch trust score: $e');
    }
  }

  // Calculate trust score for a user
  Future<double> calculateTrustScore(String userId) async {
    try {
      final client = await _supabaseService.client;

      final result = await client.rpc('calculate_trust_score', params: {
        'user_uuid': userId,
      });

      return (result as num).toDouble();
    } catch (e) {
      throw Exception('Failed to calculate trust score: $e');
    }
  }

  // Get credit profile for loan eligibility
  Future<Map<String, dynamic>> getCreditProfile(String userId) async {
    try {
      final client = await _supabaseService.client;

      // Get user profile
      final profile = await client
          .from('user_profiles')
          .select(
              'trust_score, trust_tier, total_verified_volume, confirmation_percentage')
          .eq('id', userId)
          .single();

      // Get verified income from transactions
      final transactions = await client
          .from('transactions')
          .select('amount')
          .eq('user_id', userId)
          .eq('category', 'Income')
          .eq('status', 'verified')
          .gte(
              'transaction_date',
              DateTime.now()
                  .subtract(const Duration(days: 365))
                  .toIso8601String());

      double verifiedIncome = 0.0;
      for (final transaction in transactions) {
        verifiedIncome += (transaction['amount'] as num).toDouble().abs();
      }

      // Get loan eligibility status
      final trustScore = (profile['trust_score'] as num).toDouble();
      final isEligible = trustScore >= 40.0;

      return {
        'trust_score': trustScore,
        'trust_tier': profile['trust_tier'],
        'verified_income': verifiedIncome,
        'is_eligible': isEligible,
        'max_loan_amount': _calculateMaxLoanAmount(trustScore, verifiedIncome),
        'recommended_partners': _getRecommendedPartners(trustScore),
      };
    } catch (e) {
      throw Exception('Failed to fetch credit profile: $e');
    }
  }

  // Get trust score history
  Future<List<Map<String, dynamic>>> getTrustScoreHistory(String userId) async {
    try {
      final client = await _supabaseService.client;

      final scores = await client
          .from('trust_scores')
          .select(
              'score, tier, verified_transactions, total_volume, calculation_date')
          .eq('user_id', userId)
          .order('calculation_date', ascending: false)
          .limit(30);

      return List<Map<String, dynamic>>.from(scores);
    } catch (e) {
      throw Exception('Failed to fetch trust score history: $e');
    }
  }

  // Get anomalies for a user
  Future<List<Map<String, dynamic>>> getUserAnomalies(String userId) async {
    try {
      final client = await _supabaseService.client;

      final anomalies = await client
          .from('anomalies')
          .select(
              'id, transaction_id, anomaly_type, description, severity, reviewed, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(anomalies);
    } catch (e) {
      throw Exception('Failed to fetch user anomalies: $e');
    }
  }

  // Mark anomaly as reviewed
  Future<void> markAnomalyReviewed(String anomalyId, String reviewerId) async {
    try {
      final client = await _supabaseService.client;

      await client.from('anomalies').update({
        'reviewed': true,
        'reviewer_id': reviewerId,
      }).eq('id', anomalyId);
    } catch (e) {
      throw Exception('Failed to mark anomaly as reviewed: $e');
    }
  }

  // Send trust profile to lender (mock endpoint)
  Future<Map<String, dynamic>> sendToLender(
      String userId, String lenderName) async {
    try {
      final creditProfile = await getCreditProfile(userId);

      // In a real implementation, this would call a lender's API
      // For now, we'll simulate the process
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'reference_id': 'REF_${DateTime.now().millisecondsSinceEpoch}',
        'lender': lenderName,
        'profile_sent': creditProfile,
        'message': 'Trust profile successfully sent to $lenderName',
      };
    } catch (e) {
      throw Exception('Failed to send profile to lender: $e');
    }
  }

  // Private helper methods
  double _calculateMaxLoanAmount(double trustScore, double verifiedIncome) {
    double baseMultiplier = 0.0;

    if (trustScore >= 80) {
      baseMultiplier = 5.0; // 5x annual income
    } else if (trustScore >= 60) {
      baseMultiplier = 3.0; // 3x annual income
    } else if (trustScore >= 40) {
      baseMultiplier = 1.5; // 1.5x annual income
    } else {
      baseMultiplier = 0.5; // 0.5x annual income
    }

    // Cap the maximum loan amount
    final maxAmount = verifiedIncome * baseMultiplier;
    return maxAmount > 100000 ? 100000 : maxAmount;
  }

  List<String> _getRecommendedPartners(double trustScore) {
    if (trustScore >= 80) {
      return ['Islamic Bank Solutions', 'Maybank Personal Loan', 'CIMB Bank'];
    } else if (trustScore >= 60) {
      return ['FinTech Partner Malaysia', 'AmBank Personal Loan'];
    } else if (trustScore >= 40) {
      return ['Micro Finance Plus', 'Digital Lending Malaysia'];
    } else {
      return ['Micro Finance Plus'];
    }
  }
}
