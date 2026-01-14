import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/services/current_user_service.dart';

void main() {
  group('CurrentUserService', () {
    late CurrentUserService service;

    setUp(() {
      service = CurrentUserService();
    });

    test('debe ser un singleton', () {
      final instance1 = CurrentUserService();
      final instance2 = CurrentUserService();
      expect(instance1, same(instance2));
    });

    test('getDisplayName debe retornar un nombre válido', () {
      final displayName = service.getDisplayName();
      expect(displayName, isNotEmpty);
      expect(displayName, isA<String>());
    });

    test('getLevel debe retornar un nivel válido', () {
      final level = service.getLevel();
      expect(level, isA<int>());
      expect(level, greaterThanOrEqualTo(0));
    });

    test('getProgressToNextLevel debe retornar un valor entre 0.0 y 1.0', () {
      final progress = service.getProgressToNextLevel();
      expect(progress, isA<double>());
      expect(progress, greaterThanOrEqualTo(0.0));
      expect(progress, lessThanOrEqualTo(1.0));
    });

    test('isPro debe retornar un booleano', () {
      final isPro = service.isPro();
      expect(isPro, isA<bool>());
    });
  });
}
