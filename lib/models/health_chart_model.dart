class HealthChartModel {
  final int? id;
  final int parentId;
  final int doctorId;
  final int childId;
  final String chartType; // 'food', 'medicine', 'activity'
  final String chartData; // JSON string containing chart details
  final DateTime generatedAt;
  final String? notes;

  HealthChartModel({
    this.id,
    required this.parentId,
    required this.doctorId,
    required this.childId,
    required this.chartType,
    required this.chartData,
    DateTime? generatedAt,
    this.notes,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'doctor_id': doctorId,
      'child_id': childId,
      'chart_type': chartType,
      'chart_data': chartData,
      'generated_at': generatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory HealthChartModel.fromMap(Map<String, dynamic> map) {
    return HealthChartModel(
      id: map['id'] as int?,
      parentId: map['parent_id'] as int,
      doctorId: map['doctor_id'] as int,
      childId: map['child_id'] as int,
      chartType: map['chart_type'] as String,
      chartData: map['chart_data'] as String,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      notes: map['notes'] as String?,
    );
  }
}
