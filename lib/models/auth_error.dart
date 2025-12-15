/// Clase base abstracta para errores de autenticación
abstract class AuthError implements Exception {
  final String message;

  const AuthError(this.message);

  @override
  String toString() => message;

  /// Crea un error apropiado según el código de estado HTTP
  static AuthError fromResponse(int statusCode, String? body) {
    switch (statusCode) {
      case 401:
        return InvalidCredentialsError(
          'Correo o contraseña incorrectos',
        );
      case 409:
        return UserExistsError(
          'Este correo ya está registrado',
        );
      case 400:
        return InvalidCredentialsError(
          'Datos inválidos. Revisa el formulario',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerError(
          'Error del servidor. Intenta más tarde',
        );
      default:
        return UnknownError(
          'Error inesperado. Intenta nuevamente',
        );
    }
  }
}

/// Error de conexión (timeout, sin internet, etc.)
class NetworkError extends AuthError {
  const NetworkError([super.message = 'Error de conexión. Verifica tu internet.']);
}

/// Error de credenciales incorrectas (401)
class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError([super.message = 'Correo o contraseña incorrectos']);
}

/// Error de usuario ya registrado (409)
class UserExistsError extends AuthError {
  const UserExistsError([super.message = 'Este correo ya está registrado']);
}

/// Error del servidor (500+)
class ServerError extends AuthError {
  const ServerError([super.message = 'Error del servidor. Intenta más tarde']);
}

/// Error desconocido o no categorizado
class UnknownError extends AuthError {
  const UnknownError([super.message = 'Error inesperado. Intenta nuevamente']);
}

