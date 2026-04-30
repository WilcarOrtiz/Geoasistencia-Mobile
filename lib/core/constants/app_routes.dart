import 'package:flutter/material.dart';
import 'package:geoasistencia/features/attendance/presentation/screens/mark_attendance_screen.dart';
import 'package:geoasistencia/features/attendance/presentation/screens/my_attendance_screen.dart';
import 'package:geoasistencia/features/auth/presentation/screens/login_screen.dart';
import 'package:geoasistencia/features/auth/presentation/screens/onboarding_screen.dart'; // 👈
import 'package:geoasistencia/features/auth/presentation/screens/splash_screen.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';
import 'package:geoasistencia/features/groups/presentation/screen/group_detail_screen.dart';
import 'package:geoasistencia/features/home/presentation/screens/home_screen.dart';
import 'package:geoasistencia/features/sessions/presentation/screens/open_session_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const onboarding = '/onboarding';
  static const grupos = '/grupos';
  static const asistencia = '/asistencia';
  static const groupDetail = '/group-detail';
  static const String myAttendance = '/my-attendance';
  static const openSession = '/open-session';
  static const markAttendance = '/mark-attendance';

  static final routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    onboarding: (_) => const OnboardingScreen(),
    groupDetail: (context) {
      final group = ModalRoute.of(context)!.settings.arguments as Group;
      return GroupDetailScreen(group: group);
    },
    myAttendance: (context) {
      final groupId = ModalRoute.of(context)!.settings.arguments as String;
      return MyAttendanceScreen(groupId: groupId);
    },
    openSession: (context) {
      final groupId = ModalRoute.of(context)!.settings.arguments as String;
      return OpenSessionScreen(groupId: groupId);
    },
    markAttendance: (_) => const MarkAttendanceScreen(),
  };
}
