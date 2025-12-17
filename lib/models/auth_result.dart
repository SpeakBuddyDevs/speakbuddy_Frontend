import 'auth_error.dart';

/// Resultado de una operación de autenticación
/// 
/// BACKEND: Mapea la respuesta de login/register.
/// TODO(BE): Considerar incluir refreshToken y expiresIn en respuesta de login
/// TODO(FE): Extender para guardar refreshToken cuando esté disponible
class AuthResult {
  final bool success;
  final AuthError? error;
  final String? token;
  // TODO(FE): Añadir refreshToken y expiresAt cuando BE los implemente
  // final String? refreshToken;
  // final DateTime? expiresAt;

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

