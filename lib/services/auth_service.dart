import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final client = await _supabaseService.client;
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final client = await _supabaseService.client;
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final client = await _supabaseService.client;

      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return response;
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _supabaseService.currentUser != null;
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabaseService.authStateChanges;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) return null;

      final response = await client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    bool? passiveLoggingEnabled,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) {
        updates['full_name'] = fullName;
      }

      if (passiveLoggingEnabled != null) {
        updates['passive_logging_enabled'] = passiveLoggingEnabled;
      }

      final response = await client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete user profile (this will cascade delete related data)
      await client.from('user_profiles').delete().eq('id', user.id);

      // Sign out after deletion
      await signOut();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}
