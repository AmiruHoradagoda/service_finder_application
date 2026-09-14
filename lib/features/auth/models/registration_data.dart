import 'package:service_finder_application/features/profile/models/user_profile.dart';

/// Public registration data. Passwords stay in the authentication form.
class RegistrationData {
  const RegistrationData({
    required this.username,
    required this.email,
    required this.isProvider,
  });

  final String username;
  final String email;
  final bool isProvider;

  UserProfile toProfile({required String userId}) => UserProfile(
        userId: userId,
        username: username,
        email: email,
        isProvider: isProvider,
      );
}
