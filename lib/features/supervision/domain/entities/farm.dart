class Farm {
  final int id;
  final int? userId;
  final int associationId;
  final String name;
  final String location;

  const Farm({
    required this.id,
    this.userId,
    required this.associationId,
    required this.name,
    required this.location,
  });

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'] as int,
      userId: map['userId'] as int?,
      associationId: map['associationId'] as int,
      name: map['name'] as String,
      location: map['location'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'associationId': associationId,
  };

  Farm copyWith({String? name, String? location}) {
    return Farm(
      id: id,
      userId: userId,
      associationId: associationId,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }
}