import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient _client = SupabaseConfig.client;
  final GoTrueClient _auth = SupabaseConfig.auth;

  // Get current user stream
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (response.user != null) {
        await _updateLastLoginTime(response.user!.id);
      }
      
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<AuthResponse> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? businessName,
    String? phoneNumber,
  }) async {
    try {
      // Create Supabase auth user
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'business_name': businessName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user != null) {
        // Create vendor document
        await _createVendorUserDocument(
          VendorUser(
            id: response.user!.id,
            email: email,
            name: name,
            businessName: businessName ?? 'Bottles Up Vendor',
            phoneNumber: phoneNumber,
            createdAt: DateTime.now(),
            isVerified: true,
            role: 'admin',
            permissions: ['read_events', 'write_events', 'read_bookings', 'write_bookings', 'read_inventory', 'write_inventory', 'admin'],
          ),
        );
      }

      return response;
      
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get vendor user data
  Future<VendorUser?> getVendorUser(String uid) async {
    try {
      final response = await _client
          .from('vendors')
          .select()
          .eq('id', uid)
          .maybeSingle();
      
      if (response != null) {
        return VendorUser.fromMap(response);
      } else {
        // Auto-create vendor document for existing Supabase Auth users
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.id == uid) {
          final newVendorUser = VendorUser(
            id: uid,
            email: currentUser.email ?? 'Unknown Email',
            name: currentUser.userMetadata?['name'] ?? 'Unknown User',
            businessName: 'Bottles Up Vendor',
            phoneNumber: currentUser.userMetadata?['phone_number'],
            profileImageUrl: currentUser.userMetadata?['avatar_url'],
            isVerified: currentUser.emailConfirmedAt != null,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            permissions: ['read_events', 'write_events', 'read_bookings', 'write_bookings', 'read_inventory', 'write_inventory', 'admin'],
            role: 'admin',
          );
          
          // Try to create the document asynchronously
          _createVendorUserDocumentAsync(newVendorUser);
          
          return newVendorUser;
        }
      }
      return null;
    } catch (e) {
      print('Error getting vendor user: $e');
      return null;
    }
  }

  // Update vendor user data
  Future<void> updateVendorUser(VendorUser user) async {
    try {
      await _client
          .from('vendors')
          .update(user.toMap())
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update vendor user: $e');
    }
  }

  // Check if user has permission
  Future<bool> hasPermission(String uid, String permission) async {
    try {
      final vendorUser = await getVendorUser(uid);
      return vendorUser?.hasPermission(permission) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Private methods



  // Create vendor user document asynchronously without blocking
  void _createVendorUserDocumentAsync(VendorUser user) {
    Future.microtask(() async {
      try {
        await _createVendorUserDocument(user);
        print('Vendor document created successfully for: ${user.id}');
      } catch (e) {
        print('Warning: Failed to create vendor document: $e');
        // Don't throw - this is non-blocking
      }
    });
  }

  Future<void> _createVendorUserDocument(VendorUser user) async {
    try {
      await _client
          .from('vendors')
          .insert(user.toMap());
    } catch (e) {
      String errorMsg = e.toString();
      
      if (errorMsg.contains('relation "vendors" does not exist')) {
        throw Exception('Database setup required. Please run the database setup script.');
      } else if (errorMsg.contains('duplicate key')) {
        print('Vendor user already exists: ${user.id}');
        return;
      } else if (errorMsg.contains('permission denied')) {
        throw Exception('Database permissions issue. Please check RLS policies.');
      } else {
        throw Exception('Failed to create vendor user document: $e');
      }
    }
  }

  Future<void> _updateLastLoginTime(String uid) async {
    try {
      await _client
          .from('vendors')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', uid);
    } catch (e) {
      print('Failed to update last login time: $e');
    }
  }

  String _handleAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password.';
      case 'User already registered':
        return 'An account already exists with this email.';
      case 'Weak password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'Invalid email':
        return 'Please enter a valid email address.';
      case 'User not found':
        return 'No vendor account found with this email.';
      case 'Too many requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

// Provider for Supabase auth service
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});