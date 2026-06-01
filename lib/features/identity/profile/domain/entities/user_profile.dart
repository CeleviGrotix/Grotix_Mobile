class UserProfile {
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
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.identityId,
    this.name,
    required this.email,
    this.taxId,
    this.phone,
    required this.roleId,
    this.associationId,
    this.profilePicture,
    required this.isActive,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor para estado inicial vacío
  factory UserProfile.empty() {
    return UserProfile(
      id: 0,
      identityId: 0,
      email: '',
      roleId: 0,
      isActive: false,
      preferences: const {'push': false, 'email': false},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Mapeo desde el JSON del backend
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? 0,
      identityId: map['identityId'] ?? 0,
      name: map['name'],
      email: map['email'] ?? '',
      taxId: map['taxId'],
      phone: map['phone'],
      roleId: map['roleId'] ?? 0,
      associationId: map['associationId'],
      profilePicture: map['profilePicture'],
      isActive: map['isActive'] ?? true,
      preferences: map['preferences'] ?? const {'push': false, 'email': false},
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  // Mapeo para el envío de datos
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      identityId: identityId,
      name: name ?? this.name,
      email: email,
      taxId: taxId,
      phone: phone ?? this.phone,
      roleId: roleId,
      associationId: associationId,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Getters útiles para la UI
  String get displayName => name ?? email.split('@').first;
  bool get isAdmin => roleId == 1;
}