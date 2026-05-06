class MyAttendanceSession {
  final String sessionId;
  final String? classTopic;
  final DateTime date;
  final String status;
  final String? checkInTime;

  const MyAttendanceSession({
    required this.sessionId,
    required this.classTopic,
    required this.date,
    required this.status,
    this.checkInTime,
  });
}

class MyAttendances {
  final String groupId;
  final int totalSessions;
  final int totalPresent;
  final double attendanceRate;
  final List<MyAttendanceSession> sessions;

  const MyAttendances({
    required this.groupId,
    required this.totalSessions,
    required this.totalPresent,
    required this.attendanceRate,
    required this.sessions,
  });
}
