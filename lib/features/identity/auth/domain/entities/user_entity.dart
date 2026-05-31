class UserEntity {
  final int id;
  final int identityId;
  final String? name;
  final String email;
  final String? taxId;
  final String? phone;
  final int roleId;
  final int? associationId;
  final String? profilePicture;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.identityId,
    required this.name,
    required this.email,
    this.taxId,
    this.phone,
    required this.roleId,
    this.associationId,
    this.profilePicture,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => name ?? email.split('@').first;
  String get firstName => displayName.split(' ').first;

  String get roleName => switch (roleId) {
    1 => 'Admin',
    2 => 'Staff',
    3 => 'User Admin',
    4 => 'Basic User',
    5 => 'Advanced User',
    _ => 'User',
  };

  bool get isAdmin => roleId == 1;
  bool get isStaff => roleId == 2;
}