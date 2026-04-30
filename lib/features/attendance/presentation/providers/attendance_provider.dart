import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/attendance/data/attendance_service.dart';
import 'package:geoasistencia/features/attendance/domain/my_attendance.dart';

final myAttendanceProvider = FutureProvider.family<MyAttendances, String>(
  (ref, groupId) => AttendanceService().getMyHistory(groupId),
);
