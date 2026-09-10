import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../routes/app_routes.dart';

/// Authentication Service handling Firebase Auth state, role retrieval, and session flow.
class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  StreamSubscription<User?>? _authSubscription;

  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isInitialized = false;

  // Mock / demo fallback support (when Firebase is not yet configured with google-services.json)
  bool _mockLoggedIn = false;
  String _mockRole = 'owner'; // 'owner' | 'vet' | 'admin'

  AuthService() {
    _initializeAuth();
  }

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => _auth != null ? _currentUser != null : _mockLoggedIn;
  String get userRole => _currentUserModel?.role ?? _mockRole;

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    // Stream for mock state
    return Stream.value(null);
  }

  void _initializeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;

        _authSubscription = _auth!.authStateChanges().listen((User? user) async {
          _currentUser = user;
          if (user != null) {
            await _fetchUserProfile(user.uid);
          } else {
            _currentUserModel = null;
          }
          _isInitialized = true;
          notifyListeners();
        });
      } else {
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('AuthService: Firebase not initialized yet, using fallback mode: $e');
      _isInitialized = true;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists) {
          _currentUserModel = UserModel.fromFirestore(doc);
        } else {
          // Default fallback profile if user doc is being created
          _currentUserModel = UserModel(
            id: uid,
            name: _currentUser?.displayName ?? 'Pet Owner',
            email: _currentUser?.email ?? '',
            role: 'owner',
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint('AuthService: Error fetching user profile: $e');
    }
  }

  /// Determines the appropriate destination route based on authentication and user role.
  /// Used by SplashScreen after waiting briefly.
  Future<String> determineInitialRoute({Duration waitDuration = const Duration(milliseconds: 1800)}) async {
    // 1. Splash screen branding wait time
    await Future.delayed(waitDuration);

    // 2. Check login status
    if (!isAuthenticated) {
      return AppRoutes.login;
    }

    // 3. Role-based routing
    switch (userRole) {
      case 'vet':
        return AppRoutes.vetSearch;
      case 'admin':
        return AppRoutes.admin;
      case 'owner':
      default:
        return AppRoutes.ownerHome;
    }
  }

  // --- Auth Actions ---

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_auth != null) {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      if (_currentUser != null) {
        await _fetchUserProfile(_currentUser!.uid);
      }
    } else {
      // Mock fallback
      _mockLoggedIn = true;
      _mockRole = email.contains('vet') ? 'vet' : (email.contains('admin') ? 'admin' : 'owner');
      _currentUserModel = UserModel(
        id: 'mock_uid_123',
        name: 'Demo User',
        email: email,
        role: _mockRole,
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (_auth != null) {
      UserCredential userCredential;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth!.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // User aborted Google sign-in
          return;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth!.signInWithCredential(credential);
      }

      _currentUser = userCredential.user;
      if (_currentUser != null) {
        if (_firestore != null) {
          final doc = await _firestore!.collection('users').doc(_currentUser!.uid).get();
          if (!doc.exists) {
            final newUser = UserModel(
              id: _currentUser!.uid,
              name: _currentUser!.displayName ?? 'Pet Owner',
              email: _currentUser!.email ?? '',
              role: 'owner',
              createdAt: DateTime.now(),
            );
            await _firestore!.collection('users').doc(_currentUser!.uid).set(newUser.toMap());
            _currentUserModel = newUser;
          } else {
            _currentUserModel = UserModel.fromFirestore(doc);
          }
        }
      }
    } else {
      // Mock fallback
      _mockLoggedIn = true;
      _mockRole = 'owner';
      _currentUserModel = UserModel(
        id: 'google_mock_uid',
        name: 'Google User',
        email: 'google_user@gmail.com',
        role: 'owner',
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? branchId,
  }) async {
    if (_auth != null && _firestore != null) {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          role: role,
          branchId: branchId,
          createdAt: DateTime.now(),
        );
        await _firestore!.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUser = user;
        _currentUserModel = newUser;
      }
    } else {
      // Mock fallback
      _mockLoggedIn = true;
      _mockRole = role;
      _currentUserModel = UserModel(
        id: 'mock_registered_uid',
        name: name,
        email: email,
        role: role,
        branchId: branchId,
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _mockLoggedIn = false;
    _currentUser = null;
    _currentUserModel = null;
    notifyListeners();
  }

  /// Testing helper: set mock auth state to test splash routing across roles
  void setMockAuthState({required bool loggedIn, String role = 'owner'}) {
    _mockLoggedIn = loggedIn;
    _mockRole = role;
    if (loggedIn) {
      _currentUserModel = UserModel(
        id: 'test_user_id',
        name: 'Test $role',
        email: 'test_$role@vetcare.com',
        role: role,
        createdAt: DateTime.now(),
      );
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
