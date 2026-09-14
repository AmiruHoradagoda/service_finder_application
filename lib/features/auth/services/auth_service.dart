import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, ProfileService? profiles})
      : _auth = auth,
        _profiles = profiles;

  final FirebaseAuth? _auth;
  final ProfileService? _profiles;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  ProfileService get _profileService =>
      _profiles ?? ProfileService(auth: _firebaseAuth);

  Stream<String?> get sessionChanges =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  /// Completes only after the new account's application profile has been saved.
  Future<void> register({
    required RegistrationData registration,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: registration.email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Registration did not return a user.');
    final profile = RegistrationData(
      username: registration.username,
      email: user.email ?? registration.email,
      isProvider: registration.isProvider,
    ).toProfile(userId: user.uid);
    await _profileService.createProfile(profile);
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
