import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/groups/data/class_day_service.dart';
import 'package:geoasistencia/features/groups/domain/class_day.dart';

final classDayProvider = FutureProvider.family<List<ClassDay>, String>((
  ref,
  groupId,
) {
  ref.watch(authProvider);
  return ClassDayService().getByGroup(groupId);
});
