class ChildModel {
  final int? id;
  final int parentId;
  final String name;
  final int age;
  final double weight;
  final double height;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String gender;
  final DateTime createdAt;

  ChildModel({
    this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.gender,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as int?,
      parentId: map['parent_id'] as int,
      name: map['name'] as String,
      age: map['age'] as int,
      weight: map['weight'] as double,
      height: map['height'] as double,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      placeOfBirth: map['place_of_birth'] as String,
      gender: map['gender'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
