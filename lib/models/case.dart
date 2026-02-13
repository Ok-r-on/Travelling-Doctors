class CaseReport {
  final String id;
  final String docId;
  final String patientId;
  final String prerequisites;
  final String diagnosis;
  final String recommendations;
  final DateTime createdAt;

  CaseReport({
    required this.id,
    required this.docId,
    required this.patientId,
    required this.prerequisites,
    required this.diagnosis,
    required this.recommendations,
    required this.createdAt,
  });

  factory CaseReport.fromJson(Map<String, dynamic> json) {
    return CaseReport(
      id: json['id'] as String,
      docId: json['doc_id'] as String,
      patientId: json['patient_id'] as String,
      prerequisites: json['prerequisites'] as String,
      diagnosis: json['diagnosis'] as String,
      recommendations: json['recommendations'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
