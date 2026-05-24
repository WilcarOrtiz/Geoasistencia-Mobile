import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/attendance/data/attendance_service.dart';
import 'package:geoasistencia/features/attendance/domain/my_attendance.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';

final myAttendanceProvider = FutureProvider.family<MyAttendances, String>((
  ref,
  groupId,
) {
  ref.watch(authProvider);

  return AttendanceService().getMyHistory(groupId);
});
