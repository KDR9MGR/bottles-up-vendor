import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (result.user != null) {
        await _updateLastLoginTime(result.user!.uid);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? businessName,
    String? phoneNumber,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create vendor user document
        final vendorUser = VendorUser(
          id: result.user!.uid,
          email: email,
          name: name,
          businessName: businessName,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          isVerified: false,
          role: 'staff', // Default role
          permissions: ['read_events', 'read_bookings', 'read_inventory'], // Basic permissions
        );

        await _createVendorUserDocument(vendorUser);
        
        // Update display name
        await result.user!.updateDisplayName(name);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
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
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get vendor user data
  Future<VendorUser?> getVendorUser(String uid) async {
    try {
      final doc = await _firestore.collection('vendors').doc(uid).get();
      if (doc.exists) {
        return VendorUser.fromMap(doc.data()!);
      } else {
        // Auto-create vendor document for existing Firebase Auth users
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          final newVendorUser = VendorUser(
            id: uid,
            email: currentUser.email ?? 'Unknown Email',
            name: currentUser.displayName ?? 'Unknown User',
            businessName: 'Bottles Up Vendor',
            phoneNumber: currentUser.phoneNumber,
            profileImageUrl: currentUser.photoURL,
            isVerified: currentUser.emailVerified,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            permissions: ['read_events', 'write_events', 'read_bookings', 'write_bookings', 'read_inventory', 'write_inventory', 'admin'],
            role: 'admin', // Set as admin for existing users
          );
          
          // Create the document
          await _createVendorUserDocument(newVendorUser);
          
          // Also create some sample data
          await _createSampleData(uid);
          
          return newVendorUser;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vendor user: $e');
    }
  }

  // Update vendor user data
  Future<void> updateVendorUser(VendorUser user) async {
    try {
      await _firestore.collection('vendors').doc(user.id).update(user.toMap());
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

  Future<void> _createVendorUserDocument(VendorUser user) async {
    try {
      await _firestore.collection('vendors').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create vendor user document: $e');
    }
  }

  Future<void> _updateLastLoginTime(String uid) async {
    try {
      await _firestore.collection('vendors').doc(uid).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Don't throw error for this, just log it
      print('Failed to update last login time: $e');
    }
  }

  Future<void> _createSampleData(String vendorId) async {
    try {
      // Create sample events
      final eventsRef = _firestore.collection('events');
      
      await eventsRef.doc('event_wine_tasting').set({
        'id': 'event_wine_tasting',
        'title': 'Wine Tasting Night',
        'description': 'Exclusive wine tasting event featuring premium selections',
        'venue': 'Downtown Wine Bar',
        'date': DateTime(2025, 2, 15).millisecondsSinceEpoch,
        'price': 45.99,
        'capacity': 50,
        'bookedSeats': 12,
        'vendorId': vendorId,
        'status': 'active',
        'featured': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      await eventsRef.doc('event_whiskey_social').set({
        'id': 'event_whiskey_social',
        'title': 'Whiskey Social Hour',
        'description': 'Meet fellow whiskey enthusiasts and taste rare selections',
        'venue': 'The Barrel Room',
        'date': DateTime(2025, 2, 22).millisecondsSinceEpoch,
        'price': 65.00,
        'capacity': 30,
        'bookedSeats': 8,
        'vendorId': vendorId,
        'status': 'active',
        'featured': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Create sample inventory
      final inventoryRef = _firestore.collection('inventory');
      
      await inventoryRef.doc('bottle_premium_red').set({
        'id': 'bottle_premium_red',
        'name': 'Premium Red Wine',
        'category': 'Wine',
        'brand': 'Château Reserve',
        'description': 'A bold and elegant red wine with notes of dark berries',
        'price': 45.99,
        'stock': 24,
        'minStock': 5,
        'vendorId': vendorId,
        'featured': true,
        'alcoholContent': 13.5,
        'volume': 750,
        'unit': 'ml',
        'imageUrl': null,
        'tags': ['red wine', 'premium', 'dinner wine'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      await inventoryRef.doc('bottle_craft_whiskey').set({
        'id': 'bottle_craft_whiskey',
        'name': 'Craft Single Malt Whiskey',
        'category': 'Whiskey',
        'brand': 'Highland Distillery',
        'description': 'Smooth single malt with caramel and vanilla notes',
        'price': 89.99,
        'stock': 15,
        'minStock': 3,
        'vendorId': vendorId,
        'featured': true,
        'alcoholContent': 40.0,
        'volume': 700,
        'unit': 'ml',
        'imageUrl': null,
        'tags': ['whiskey', 'single malt', 'craft'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Create sample bookings
      final bookingsRef = _firestore.collection('bookings');
      
      await bookingsRef.doc('booking_001').set({
        'id': 'booking_001',
        'eventId': 'event_wine_tasting',
        'userId': 'user_demo_001',
        'vendorId': vendorId,
        'customerName': 'John Smith',
        'customerEmail': 'john.smith@example.com',
        'customerPhone': '+1234567890',
        'seats': 2,
        'totalAmount': 91.98,
        'status': 'confirmed',
        'paymentStatus': 'paid',
        'paymentMethod': 'card',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        'updatedAt': DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      });

      await bookingsRef.doc('booking_002').set({
        'id': 'booking_002',
        'eventId': 'event_wine_tasting',
        'userId': 'user_demo_002',
        'vendorId': vendorId,
        'customerName': 'Sarah Johnson',
        'customerEmail': 'sarah.j@example.com',
        'customerPhone': '+1987654321',
        'seats': 1,
        'totalAmount': 45.99,
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': 'card',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      });

      print('Sample data created successfully for vendor: $vendorId');
    } catch (e) {
      print('Failed to create sample data: $e');
      // Don't throw error, just log it
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No vendor account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
}); 