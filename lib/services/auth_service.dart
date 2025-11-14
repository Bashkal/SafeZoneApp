import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  AppUser? _currentAppUser;
  AppUser? get currentAppUser => _currentAppUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentAppUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentAppUser = AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      rethrow;
    }
  }

  Future<void> _createOrUpdateUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create new user with reportsSubmitted initialized to 0
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        reportsSubmitted: 0,
      );
      await userDoc.set(appUser.toMap());
      _currentAppUser = appUser;
    } else {
      // Update existing user
      await userDoc.update({
        'displayName': user.displayName ?? 'Anonymous',
        'photoUrl': user.photoURL,
      });
      // Reload user data to get the latest reportsSubmitted count
      await _loadUserData(user.uid);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentAppUser = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'photoUrl': photoUrl,
      });

      if (_currentAppUser != null) {
        _currentAppUser = _currentAppUser!.copyWith(photoUrl: photoUrl);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user photo: $e');
      }
      rethrow;
    }
  }

  // Refresh user data (useful after submitting reports)
  Future<void> refreshUserData() async {
    if (currentUser != null) {
      await _loadUserData(currentUser!.uid);
      notifyListeners();
    }
  }
}
