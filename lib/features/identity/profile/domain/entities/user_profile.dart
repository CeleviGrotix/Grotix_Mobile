class UserProfile {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profilePictureUrl;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profilePictureUrl,
  });

  String get firstName => name.split(' ').first;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}