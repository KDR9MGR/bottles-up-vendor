import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_model.dart';
import '../services/auth_service.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final User? firebaseUser;
  final VendorUser? vendorUser;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.firebaseUser,
    this.vendorUser,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? firebaseUser,
    VendorUser? vendorUser,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      vendorUser: vendorUser ?? this.vendorUser,
      error: error,
    );
  }

  bool get isAuthenticated => firebaseUser != null;
  bool get isVendorComplete => vendorUser != null;
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadVendorUser(user);
      } else {
        state = const AuthState();
      }
    });
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User will be loaded via auth state listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? businessName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        businessName: businessName,
        phoneNumber: phoneNumber,
      );
      // User will be loaded via auth state listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update vendor user
  Future<void> updateVendorUser(VendorUser user) async {
    try {
      await _authService.updateVendorUser(user);
      state = state.copyWith(vendorUser: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Load vendor user data
  Future<void> _loadVendorUser(User firebaseUser) async {
    state = state.copyWith(
      isLoading: true,
      firebaseUser: firebaseUser,
      error: null,
    );

    try {
      final vendorUser = await _authService.getVendorUser(firebaseUser.uid);
      state = state.copyWith(
        isLoading: false,
        vendorUser: vendorUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check permission
  Future<bool> hasPermission(String permission) async {
    if (state.firebaseUser == null) return false;
    return await _authService.hasPermission(
      state.firebaseUser!.uid,
      permission,
    );
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).firebaseUser;
});

final currentVendorUserProvider = Provider<VendorUser?>((ref) {
  return ref.watch(authProvider).vendorUser;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
}); 