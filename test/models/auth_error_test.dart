import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/models/auth_error.dart';

void main() {
  group('AuthError', () {
    group('fromResponse', () {
      test('debe retornar InvalidCredentialsError para código 401', () {
        final error = AuthError.fromResponse(401, 'Unauthorized');
        expect(error, isA<InvalidCredentialsError>());
        expect(error.message, contains('incorrectos'));
      });

      test('debe retornar UserExistsError para código 409', () {
        final error = AuthError.fromResponse(409, 'Conflict');
        expect(error, isA<UserExistsError>());
        expect(error.message, contains('registrado'));
      });

      test('debe retornar InvalidCredentialsError para código 400', () {
        final error = AuthError.fromResponse(400, 'Bad Request');
        expect(error, isA<InvalidCredentialsError>());
        expect(error.message, contains('inválidos'));
      });

      test('debe retornar ServerError para código 500', () {
        final error = AuthError.fromResponse(500, 'Internal Server Error');
        expect(error, isA<ServerError>());
        expect(error.message, contains('servidor'));
      });

      test('debe retornar ServerError para código 502', () {
        final error = AuthError.fromResponse(502, 'Bad Gateway');
        expect(error, isA<ServerError>());
      });

      test('debe retornar ServerError para código 503', () {
        final error = AuthError.fromResponse(503, 'Service Unavailable');
        expect(error, isA<ServerError>());
      });

      test('debe retornar ServerError para código 504', () {
        final error = AuthError.fromResponse(504, 'Gateway Timeout');
        expect(error, isA<ServerError>());
      });

      test('debe retornar UnknownError para código desconocido', () {
        final error = AuthError.fromResponse(418, 'I\'m a teapot');
        expect(error, isA<UnknownError>());
        expect(error.message, contains('inesperado'));
      });
    });

    group('NetworkError', () {
      test('debe usar mensaje por defecto', () {
        const error = NetworkError();
        expect(error.message, contains('conexión'));
      });

      test('debe usar mensaje personalizado', () {
        const error = NetworkError('Error personalizado');
        expect(error.message, 'Error personalizado');
      });
    });

    group('InvalidCredentialsError', () {
      test('debe usar mensaje por defecto', () {
        const error = InvalidCredentialsError();
        expect(error.message, contains('incorrectos'));
      });

      test('debe usar mensaje personalizado', () {
        const error = InvalidCredentialsError('Mensaje personalizado');
        expect(error.message, 'Mensaje personalizado');
      });
    });

    group('UserExistsError', () {
      test('debe usar mensaje por defecto', () {
        const error = UserExistsError();
        expect(error.message, contains('registrado'));
      });
    });

    group('ServerError', () {
      test('debe usar mensaje por defecto', () {
        const error = ServerError();
        expect(error.message, contains('servidor'));
      });
    });

    group('UnknownError', () {
      test('debe usar mensaje por defecto', () {
        const error = UnknownError();
        expect(error.message, contains('inesperado'));
      });
    });

    test('toString debe retornar el mensaje', () {
      const error = NetworkError('Test error');
      expect(error.toString(), 'Test error');
    });
  });
}
