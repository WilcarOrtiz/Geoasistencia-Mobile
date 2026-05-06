class InvalidCredentialsException implements Exception {
  final String message;
  const InvalidCredentialsException([
    this.message = 'Email o contraseña incorrectos',
  ]);
}

class ServerException implements Exception {
  final String message;
  const ServerException([
    this.message = 'Error del servidor, intenta más tarde',
  ]);
}

class UserNotFoundException implements Exception {
  final String message;
  const UserNotFoundException([
    this.message = 'Usuario no encontrado o sin acceso',
  ]);
}
