class DoctorParentRequestModel {
  final int? id;
  final int parentId;
  final int doctorId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? respondedAt;

  DoctorParentRequestModel({
    this.id,
    required this.parentId,
    required this.doctorId,
    this.status = 'pending',
    DateTime? createdAt,
    this.respondedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'doctor_id': doctorId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  factory DoctorParentRequestModel.fromMap(Map<String, dynamic> map) {
    return DoctorParentRequestModel(
      id: map['id'] as int?,
      parentId: map['parent_id'] as int,
      doctorId: map['doctor_id'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      respondedAt: map['responded_at'] != null
          ? DateTime.parse(map['responded_at'] as String)
          : null,
    );
  }

  DoctorParentRequestModel copyWith({
    int? id,
    int? parentId,
    int? doctorId,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return DoctorParentRequestModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      doctorId: doctorId ?? this.doctorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
