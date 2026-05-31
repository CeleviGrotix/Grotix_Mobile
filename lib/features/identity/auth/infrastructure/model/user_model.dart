import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.identityId,
    required super.name,
    required super.email,
    super.taxId,
    super.phone,
    required super.roleId,
    super.associationId,
    super.profilePicture,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      identityId: json['identityId'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      taxId: json['taxId'] as String?,
      phone: json['phone'] as String?,
      roleId: json['roleId'] as int,
      associationId: json['associationId'] as int?,
      profilePicture: json['profilePicture'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'identityId': identityId,
    'name': name,
    'email': email,
    'taxId': taxId,
    'phone': phone,
    'roleId': roleId,
    'associationId': associationId,
    'profilePicture': profilePicture,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}