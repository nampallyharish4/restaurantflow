import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile_model.dart';
import './supabase_service.dart';

/// Authentication service for managing user authentication and profiles
class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets the current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Checks if user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Signs up a new user with email and password
  /// [email] - User's email address
  /// [password] - User's password
  /// [fullName] - User's full name
  /// [role] - User's role (waiter, counter, kitchen, admin, manager)
  /// [phone] - Optional phone number
  /// Returns AuthResponse with user data
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'waiter',
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
          'phone': phone,
        },
      );

      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  /// Signs in a user with email and password
  /// [email] - User's email address
  /// [password] - User's password
  /// Returns AuthResponse with user data
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  /// Signs out the current user
  /// Returns true if successful
  Future<bool> signOut() async {
    try {
      await _client.auth.signOut();
      return true;
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  /// Gets the current user's profile from the user_profiles table
  /// Returns UserProfileModel or null if not found
  Future<UserProfileModel?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response != null ? UserProfileModel.fromMap(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Updates the current user's profile
  /// [fullName] - New full name
  /// [phone] - New phone number
  /// Returns updated UserProfileModel
  Future<UserProfileModel> updateUserProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  /// Changes user password
  /// [newPassword] - The new password
  /// Returns true if successful
  Future<bool> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (error) {
      throw Exception('Failed to change password: $error');
    }
  }

  /// Sends password reset email
  /// [email] - User's email address
  /// Returns true if successful
  Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (error) {
      throw Exception('Failed to send reset email: $error');
    }
  }

  /// Listens to authentication state changes
  /// [callback] - Function to handle auth state changes
  /// Returns Stream subscription
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Checks if current user has a specific role
  /// [role] - Role to check for
  /// Returns true if user has the role
  Future<bool> hasRole(String role) async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role == role;
    } catch (error) {
      return false;
    }
  }

  /// Checks if current user is admin or manager
  /// Returns true if user is admin or manager
  Future<bool> isAdminOrManager() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role == 'admin' || profile?.role == 'manager';
    } catch (error) {
      return false;
    }
  }

  /// Gets all staff members (for admin/manager use)
  /// Returns list of UserProfileModel
  Future<List<UserProfileModel>> getAllStaff() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('is_active', true)
          .order('full_name', ascending: true);

      return response
          .map<UserProfileModel>((user) => UserProfileModel.fromMap(user))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch staff: $error');
    }
  }

  /// Deactivates a staff member (admin only)
  /// [userId] - ID of the user to deactivate
  /// Returns true if successful
  Future<bool> deactivateStaff(String userId) async {
    try {
      await _client.from('user_profiles').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', userId);

      return true;
    } catch (error) {
      throw Exception('Failed to deactivate staff: $error');
    }
  }

  /// Updates staff role (admin only)
  /// [userId] - ID of the user to update
  /// [newRole] - New role for the user
  /// Returns updated UserProfileModel
  Future<UserProfileModel> updateStaffRole(
      String userId, String newRole) async {
    try {
      final response = await _client
          .from('user_profiles')
          .update({
            'role': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } catch (error) {
      throw Exception('Failed to update staff role: $error');
    }
  }
}
