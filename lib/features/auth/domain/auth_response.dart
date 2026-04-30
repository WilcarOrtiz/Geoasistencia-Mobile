import 'package:geoasistencia/features/auth/domain/role.dart';
import 'package:geoasistencia/features/auth/domain/user.dart';

class AuthData {
  final User user;
  final List<Role> roles;

  AuthData({required this.user, required this.roles});

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    user: User.fromJson(json['user']),
    roles: (json['roles'] as List).map((e) => Role.fromJson(e)).toList(),
  );
}
