class AppointmentModel {
  final int? id;
  final int parentId;
  final int doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    this.id,
    required this.parentId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = 'pending',
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'appointment_time': appointmentTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as int?,
      parentId: map['parent_id'] as int,
      doctorId: map['doctor_id'] as int,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      appointmentTime: map['appointment_time'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  AppointmentModel copyWith({
    int? id,
    int? parentId,
    int? doctorId,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
