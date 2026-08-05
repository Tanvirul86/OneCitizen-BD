import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/realtime_db.dart';

/// Thrown for any auth/profile failure so providers can show `message`
/// directly without unwrapping a provider-specific exception type.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, FirebaseDatabase? database})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _database = database ?? appDatabase;

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  DatabaseReference get _users => _database.ref('users');

  /// Creates the account only — does not sign the user in. They must call
  /// [login] afterward with the credentials they just registered.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _users.child(uid).set({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': 'citizen',
        'verified': false,
        'is_active': true,
        'created_at': ServerValue.timestamp,
      });
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authErrorMessage(e));
    }
  }

  Future<User> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final snapshot = await _users.child(uid).get();
      if (!snapshot.exists) {
        await _auth.signOut();
        throw AuthException('Invalid email or password.');
      }
      final user = User.fromJson(withKey(uid, snapshot.value));
      if (user.role != role) {
        await _auth.signOut();
        throw AuthException('Invalid email or password.');
      }
      if (!user.isActive) {
        await _auth.signOut();
        throw AuthException('This account has been deactivated.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authErrorMessage(e));
    }
  }

  Future<User> fetchProfile() async {
    final uid = _requireUid();
    final snapshot = await _users.child(uid).get();
    if (!snapshot.exists) throw AuthException('Profile not found.');
    return User.fromJson(withKey(uid, snapshot.value));
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final uid = _requireUid();
    await _users.child(uid).update(data);
    final snapshot = await _users.child(uid).get();
    return User.fromJson(withKey(uid, snapshot.value));
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw AuthException('You must be signed in to change your password.');
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.code == 'wrong-password' || e.code == 'invalid-credential'
            ? 'Current password is incorrect.'
            : _authErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> hasValidSession() async {
    return _auth.currentUser != null;
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AuthException('You must be signed in.');
    return uid;
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
