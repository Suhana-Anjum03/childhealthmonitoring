class DoctorModel {
  final int? id;
  final int userId;
  final String name;
  final String phoneNumber;
  final String email;
  final String licenseId;
  final String workingLocation;
  final String hospitalName;
  final int age;
  final String specialization;
  final String? profilePhoto; // Base64 encoded image or file path
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? approvedAt;

  DoctorModel({
    this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.licenseId,
    required this.workingLocation,
    required this.hospitalName,
    required this.age,
    required this.specialization,
    this.profilePhoto,
    this.approvalStatus = 'pending',
    this.rejectionReason,
    DateTime? createdAt,
    this.approvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'license_id': licenseId,
      'working_location': workingLocation,
      'hospital_name': hospitalName,
      'age': age,
      'specialization': specialization,
      'profile_photo': profilePhoto,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      licenseId: map['license_id'] as String,
      workingLocation: map['working_location'] as String,
      hospitalName: map['hospital_name'] as String,
      age: map['age'] as int,
      specialization: map['specialization'] as String,
      profilePhoto: map['profile_photo'] as String?,
      approvalStatus: map['approval_status'] as String,
      rejectionReason: map['rejection_reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String)
          : null,
    );
  }

  DoctorModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? licenseId,
    String? workingLocation,
    String? hospitalName,
    int? age,
    String? specialization,
    String? profilePhoto,
    String? approvalStatus,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licenseId: licenseId ?? this.licenseId,
      workingLocation: workingLocation ?? this.workingLocation,
      hospitalName: hospitalName ?? this.hospitalName,
      age: age ?? this.age,
      specialization: specialization ?? this.specialization,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
