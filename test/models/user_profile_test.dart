import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/models/user_profile.dart';
import 'package:flutter_speakbuddy/models/language_item.dart';

void main() {
  group('UserProfile', () {
    late UserProfile profile;

    setUp(() {
      profile = UserProfile(
        id: '1',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        level: 5,
        progressPct: 0.40,
        exchanges: 12,
        rating: 4.8,
        languagesCount: 2,
        hoursTotal: 18,
        currentStreakDays: 5,
        bestStreakDays: 12,
        medals: 4,
        nativeLanguage: 'ES',
        learningLanguages: const [
          LanguageItem(code: 'EN', name: 'Inglés', level: 'Intermedio', active: true),
          LanguageItem(code: 'FR', name: 'Francés', level: 'Principiante'),
        ],
        isPro: true,
        description: 'Descripción de prueba',
      );
    });

    test('debe crear un perfil con todos los campos requeridos', () {
      expect(profile.name, 'Juan Pérez');
      expect(profile.email, 'juan@example.com');
      expect(profile.level, 5);
      expect(profile.progressPct, 0.40);
      expect(profile.exchanges, 12);
      expect(profile.rating, 4.8);
      expect(profile.languagesCount, 2);
      expect(profile.hoursTotal, 18);
      expect(profile.currentStreakDays, 5);
      expect(profile.bestStreakDays, 12);
      expect(profile.medals, 4);
      expect(profile.nativeLanguage, 'ES');
      expect(profile.isPro, true);
      expect(profile.description, 'Descripción de prueba');
      expect(profile.learningLanguages.length, 2);
    });

    test('copyWith debe crear una copia con campos modificados', () {
      final updated = profile.copyWith(
        name: 'María García',
        level: 6,
        progressPct: 0.50,
      );

      expect(updated.name, 'María García');
      expect(updated.level, 6);
      expect(updated.progressPct, 0.50);
      // Campos no modificados deben mantenerse
      expect(updated.email, profile.email);
      expect(updated.exchanges, profile.exchanges);
      expect(updated.rating, profile.rating);
    });

    test('copyWith debe mantener valores originales cuando no se especifican', () {
      final updated = profile.copyWith(name: 'Nuevo Nombre');

      expect(updated.name, 'Nuevo Nombre');
      expect(updated.email, profile.email);
      expect(updated.level, profile.level);
      expect(updated.progressPct, profile.progressPct);
      expect(updated.learningLanguages, profile.learningLanguages);
    });

    test('copyWith debe actualizar avatarPath correctamente', () {
      final updated = profile.copyWith(avatarPath: '/path/to/avatar.jpg');

      expect(updated.avatarPath, '/path/to/avatar.jpg');
    });

    test('copyWith debe actualizar learningLanguages correctamente', () {
      final newLanguages = [
        const LanguageItem(code: 'DE', name: 'Alemán', level: 'Principiante'),
      ];
      final updated = profile.copyWith(learningLanguages: newLanguages);

      expect(updated.learningLanguages.length, 1);
      expect(updated.learningLanguages.first.code, 'DE');
      expect(updated.languagesCount, profile.languagesCount); // No se actualiza automáticamente
    });

    test('debe permitir avatarPath null', () {
      final profileWithoutAvatar = UserProfile(
        id: '',
        name: 'Test',
        email: 'test@example.com',
        level: 1,
        progressPct: 0.0,
        exchanges: 0,
        rating: 0.0,
        languagesCount: 0,
        hoursTotal: 0,
        currentStreakDays: 0,
        bestStreakDays: 0,
        medals: 0,
        nativeLanguage: 'ES',
        learningLanguages: const [],
        isPro: false,
        description: '',
        avatarPath: null,
      );

      expect(profileWithoutAvatar.avatarPath, isNull);
    });
  });
}
