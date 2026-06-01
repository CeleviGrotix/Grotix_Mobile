class Association {
  final int id;
  final String name;
  final String email;

  const Association({
    required this.id,
    required this.name,
    required this.email,
  });

  // Constructor para estado inicial vacío
  factory Association.empty() {
    return const Association(
      id: 0,
      name: '',
      email: '',
    );
  }

  // Mapeo desde el JSON del backend
  factory Association.fromMap(Map<String, dynamic> map) {
    return Association(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Mapeo para el envío de datos (ej. creación o edición)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  Association copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return Association(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}