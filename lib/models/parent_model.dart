class ParentModel {
  final int? id;
  final int userId;
  final String name;
  final int age;
  final String phoneNumber;
  final String email;
  final String gender;
  final DateTime createdAt;

  ParentModel({
    this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'age': age,
      'phone_number': phoneNumber,
      'email': email,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      age: map['age'] as int,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
