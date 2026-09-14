/// Application profile stored in Users; Firebase User remains the auth identity.
class UserProfile {
  const UserProfile({
    required this.userId,
    this.email,
    this.username,
    this.isProvider = false,
    this.profileImage,
    this.bio,
    this.phone,
    this.address,
    this.legacyUserType,
  });

  final String userId;
  final String? email;
  final String? username;
  final bool isProvider;
  final String? profileImage;
  final String? bio;
  final String? phone;
  final String? address;
  final String? legacyUserType;

  factory UserProfile.fromMap(Map<String, dynamic> data) => UserProfile(
        userId: data['user_ID'] as String? ?? '',
        email: data['email'] as String?,
        username: data['username'] as String?,
        isProvider: data['provider'] as bool? ?? data['userType'] == 'Provider',
        profileImage: data['profileImage'] as String?,
        bio: data['bio'] as String?,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        legacyUserType: data['userType'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'user_ID': userId,
        'email': email,
        'username': username,
        'provider': isProvider,
        if (profileImage != null) 'profileImage': profileImage,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (legacyUserType != null) 'userType': legacyUserType,
      };
}
