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

  AuthService() {
    _initializeAuth();
  }

  FirebaseAuth get _firebaseAuth {
    if (_auth == null && Firebase.apps.isNotEmpty) {
      _auth = FirebaseAuth.instance;
    }
    return _auth ?? FirebaseAuth.instance;
  }

  FirebaseFirestore get _firebaseFirestore {
    if (_firestore == null && Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser ?? (_firebaseAuth.currentUser);
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => currentUser != null;
  String get userRole => _currentUserModel?.role ?? 'owner';

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  void _initializeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;

        _currentUser = _auth!.currentUser;
        if (_currentUser != null) {
          _fetchUserProfile(_currentUser!.uid);
        }

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
      debugPrint('AuthService: Auth init notice: $e');
      _isInitialized = true;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firebaseFirestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromFirestore(doc);
      } else {
        _currentUserModel = UserModel(
          id: uid,
          name: _currentUser?.displayName ?? 'Pet Owner',
          email: _currentUser?.email ?? '',
          role: 'owner',
          createdAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService: Error fetching user profile: $e');
    }
  }

  /// Determines the appropriate destination route based on authentication and user role.
  /// Used by SplashScreen after waiting briefly.
  Future<String> determineInitialRoute({Duration waitDuration = const Duration(milliseconds: 1800)}) async {
    if (waitDuration > Duration.zero) {
      await Future.delayed(waitDuration);
    }

    if (!isAuthenticated) {
      return AppRoutes.login;
    }

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

  // --- Real Firebase Auth Actions ---

  Future<void> signInWithGoogle() async {
    final auth = _firebaseAuth;
    UserCredential userCredential;

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      userCredential = await auth.signInWithPopup(googleProvider);
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled Google sign-in dialog
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await auth.signInWithCredential(credential);
    }

    _currentUser = userCredential.user;
    if (_currentUser != null) {
      final firestore = _firebaseFirestore;
      final doc = await firestore.collection('users').doc(_currentUser!.uid).get();
      if (!doc.exists) {
        final newUser = UserModel(
          id: _currentUser!.uid,
          name: _currentUser!.displayName ?? 'Pet Owner',
          email: _currentUser!.email ?? '',
          role: 'owner',
          createdAt: DateTime.now(),
        );
        await firestore.collection('users').doc(_currentUser!.uid).set(newUser.toMap());
        _currentUserModel = newUser;
      } else {
        _currentUserModel = UserModel.fromFirestore(doc);
      }
    }
    notifyListeners();
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _currentUser = credential.user;
    if (_currentUser != null) {
      await _fetchUserProfile(_currentUser!.uid);
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
    final auth = _firebaseAuth;
    final firestore = _firebaseFirestore;

    final credential = await auth.createUserWithEmailAndPassword(
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
      await firestore.collection('users').doc(user.uid).set(newUser.toMap());
      _currentUser = user;
      _currentUserModel = newUser;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    _currentUserModel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
