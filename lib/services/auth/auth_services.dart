import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/Password Sign-In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update user data in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    }
  }

  // Email/Password Registration
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Store user data in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    }
  }

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Update user data in Firestore
      await _updateUserData(
        userCredential.user!,
        provider: 'google',
        email: googleUser.email,
      );

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  

  // Helper to update user data in Firestore
  Future<void> _updateUserData(
    User user, {
    String? provider,
    String? email,
    String? displayName,
  }) async {
    await _firestore.collection("Users").doc(user.uid).set({
      'uid': user.uid,
      'email': email ?? user.email,
      'displayName': displayName ?? user.displayName,
      'photoURL': user.photoURL,
      'provider': provider,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google too
    await _auth.signOut();
  }

  // Error handling
  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account is disabled';
      case 'user-not-found':
        return 'Account not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'operation-not-allowed':
        return 'Email/password not enabled';
      case 'weak-password':
        return 'Password too weak (min 6 chars)';
      case 'account-exists-with-different-credential':
        return 'Account already exists with different method';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}