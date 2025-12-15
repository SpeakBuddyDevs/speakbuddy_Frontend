import 'auth_error.dart';

/// Resultado de una operación de autenticación
class AuthResult {
  final bool success;
  final AuthError? error;
  final String? token;

  const AuthResult({
    required this.success,
    this.error,
    this.token,
  });

  /// Constructor para éxito en login (con token)
  factory AuthResult.success({String? token}) {
    return AuthResult(success: true, token: token);
  }

  /// Constructor para error
  factory AuthResult.failure(AuthError error) {
    return AuthResult(success: false, error: error);
  }
}

