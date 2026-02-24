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
          'Incorrect email or password',
        );
      case 409:
        return UserExistsError(
          'This email is already registered',
        );
      case 400:
        return InvalidCredentialsError(
          'Invalid data. Please check the form',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerError(
          'Server error. Please try again later',
        );
      default:
        return UnknownError(
          'Unexpected error. Please try again',
        );
    }
  }
}

/// Error de conexión (timeout, sin internet, etc.)
class NetworkError extends AuthError {
  const NetworkError([super.message = 'Connection error. Check your internet connection.']);
}

/// Error de credenciales incorrectas (401)
class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError([super.message = 'Incorrect email or password']);
}

/// Error de usuario ya registrado (409)
class UserExistsError extends AuthError {
  const UserExistsError([super.message = 'This email is already registered']);
}

/// Error del servidor (500+)
class ServerError extends AuthError {
  const ServerError([super.message = 'Server error. Please try again later']);
}

/// Error desconocido o no categorizado
class UnknownError extends AuthError {
  const UnknownError([super.message = 'Unexpected error. Please try again']);
}

