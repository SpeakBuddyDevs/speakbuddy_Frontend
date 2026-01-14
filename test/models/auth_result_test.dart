import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/models/auth_result.dart';
import 'package:flutter_speakbuddy/models/auth_error.dart';

void main() {
  group('AuthResult', () {
    test('success factory debe crear un resultado exitoso con token', () {
      const token = 'test_token_123';
      final result = AuthResult.success(token: token);

      expect(result.success, true);
      expect(result.token, token);
      expect(result.error, isNull);
    });

    test('success factory debe crear un resultado exitoso sin token', () {
      final result = AuthResult.success();

      expect(result.success, true);
      expect(result.token, isNull);
      expect(result.error, isNull);
    });

    test('failure factory debe crear un resultado de error', () {
      const error = InvalidCredentialsError('Credenciales incorrectas');
      final result = AuthResult.failure(error);

      expect(result.success, false);
      expect(result.error, error);
      expect(result.token, isNull);
    });

    test('debe crear un resultado con constructor directo', () {
      const token = 'direct_token';
      final result = AuthResult(
        success: true,
        token: token,
      );

      expect(result.success, true);
      expect(result.token, token);
    });

    test('debe crear un resultado de error con constructor directo', () {
      const error = NetworkError('Error de conexión');
      final result = AuthResult(
        success: false,
        error: error,
      );

      expect(result.success, false);
      expect(result.error, error);
      expect(result.token, isNull);
    });
  });
}
