import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/repositories/fake_users_repository.dart';
import 'package:flutter_speakbuddy/models/public_user_profile.dart';

void main() {
  group('FakeUsersRepository', () {
    late FakeUsersRepository repository;

    setUp(() {
      repository = FakeUsersRepository();
    });

    test('debe retornar un PublicUserProfile cuando el usuario existe', () async {
      // El repositorio fake busca en FakeFindUsersRepository
      // Los datos mock tienen IDs del '1' al '20'
      final profile = await repository.getPublicProfile('1');

      expect(profile, isNotNull);
      expect(profile, isA<PublicUserProfile>());
      expect(profile!.id, '1');
      expect(profile.name, isNotEmpty);
      expect(profile.country, isNotEmpty);
      expect(profile.nativeLanguage, isNotEmpty);
      expect(profile.targetLanguage, isNotEmpty);
      expect(profile.level, greaterThanOrEqualTo(0));
      expect(profile.rating, greaterThanOrEqualTo(0.0));
      expect(profile.exchanges, greaterThanOrEqualTo(0));
    });

    test('debe retornar null cuando el usuario no existe', () async {
      final profile = await repository.getPublicProfile('usuario_inexistente_999');

      expect(profile, isNull);
    });

    test('debe simular latencia de red', () async {
      final stopwatch = Stopwatch()..start();
      await repository.getPublicProfile('1');
      stopwatch.stop();

      // Debe haber una pequeña demora (al menos 100ms según el código)
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('debe retornar un perfil con todos los campos requeridos cuando existe', () async {
      final profile = await repository.getPublicProfile('2');

      expect(profile, isNotNull);
      expect(profile!.id, '2');
      expect(profile.name, isNotEmpty);
      expect(profile.country, isNotEmpty);
      expect(profile.nativeLanguage, isNotEmpty);
      expect(profile.targetLanguage, isNotEmpty);
      expect(profile.level, isA<int>());
      expect(profile.rating, isA<double>());
      expect(profile.exchanges, isA<int>());
      expect(profile.isOnline, isA<bool>());
      expect(profile.isPro, isA<bool>());
    });
  });
}
