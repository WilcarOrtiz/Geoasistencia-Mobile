enum AttendanceStatus { absent, present, late }

class AttendanceRecord {
  final String id;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String studentId;
  final String studentName;

  const AttendanceRecord({
    required this.id,
    required this.status,
    this.checkInTime,
    required this.studentId,
    required this.studentName,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      status: switch (json['status'] as String) {
        'PRESENT' => AttendanceStatus.present,
        'LATE' => AttendanceStatus.late,
        _ => AttendanceStatus.absent,
      },
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      studentId: json['student']['id'] as String,
      studentName: json['student']['name'] as String,
    );
  }
}
