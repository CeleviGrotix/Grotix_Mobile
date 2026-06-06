class ZoneMember {
  final int userId;
  final String? name;
  final String email;
  final int roleId;
  final String roleName;
  // Solo presentes en zone members
  final DateTime? assignedAt;
  final int? assignedByUserId;
  final String? profilePicture;

  const ZoneMember({
    required this.userId,
    this.name,
    required this.email,
    required this.roleId,
    required this.roleName,
    this.assignedAt,
    this.assignedByUserId,
    this.profilePicture
  });

  String get displayName => name ?? email.split('@').first;

  factory ZoneMember.fromMap(Map<String, dynamic> map) {
    return ZoneMember(
      userId: (map['userId'] as num?)?.toInt() ?? 0,
      name: map['name'] as String?,
      email: map['email'] as String? ?? '',
      roleId: (map['roleId'] as num?)?.toInt() ?? 0,
      roleName: map['roleName'] as String? ?? '',
      assignedAt: map['assignedAt'] != null
          ? DateTime.parse(map['assignedAt'] as String)
          : null,
      assignedByUserId: (map['assignedByUserId'] as num?)?.toInt(),
      profilePicture: map['profilePicture'] as String?,
    );
  }
}