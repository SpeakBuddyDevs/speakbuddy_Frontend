import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speakbuddy/models/public_user_profile.dart';
import 'package:flutter_speakbuddy/models/find_user.dart';

void main() {
  group('PublicUserProfile', () {
    test('debe crear un perfil público con todos los campos requeridos', () {
      const profile = PublicUserProfile(
        id: 'user123',
        name: 'Ana López',
        country: 'España',
        avatarUrl: 'https://example.com/avatar.jpg',
        isOnline: true,
        isPro: true,
        nativeLanguage: 'ES',
        targetLanguage: 'EN',
        level: 7,
        rating: 4.9,
        exchanges: 25,
        bio: 'Bio de prueba',
      );

      expect(profile.id, 'user123');
      expect(profile.name, 'Ana López');
      expect(profile.country, 'España');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.isOnline, true);
      expect(profile.isPro, true);
      expect(profile.nativeLanguage, 'ES');
      expect(profile.targetLanguage, 'EN');
      expect(profile.level, 7);
      expect(profile.rating, 4.9);
      expect(profile.exchanges, 25);
      expect(profile.bio, 'Bio de prueba');
    });

    test('debe permitir campos opcionales como null', () {
      const profile = PublicUserProfile(
        id: 'user456',
        name: 'Carlos Ruiz',
        country: 'México',
        nativeLanguage: 'ES',
        targetLanguage: 'FR',
        level: 3,
        rating: 4.0,
        exchanges: 5,
      );

      expect(profile.avatarUrl, isNull);
      expect(profile.bio, isNull);
      expect(profile.interests, isNull);
      expect(profile.isOnline, false);
      expect(profile.isPro, false);
    });

    test('fromFindUser debe crear PublicUserProfile desde FindUser', () {
      const findUser = FindUser(
        id: 'user789',
        name: 'Laura Martínez',
        country: 'Colombia',
        avatarUrl: 'https://example.com/laura.jpg',
        isOnline: true,
        isPro: false,
        nativeLanguage: 'ES',
        targetLanguage: 'EN',
        level: 4,
        rating: 4.5,
        exchanges: 10,
        bio: 'Bio desde FindUser',
      );

      final profile = PublicUserProfile.fromFindUser(findUser);

      expect(profile.id, findUser.id);
      expect(profile.name, findUser.name);
      expect(profile.country, findUser.country);
      expect(profile.avatarUrl, findUser.avatarUrl);
      expect(profile.isOnline, findUser.isOnline);
      expect(profile.isPro, findUser.isPro);
      expect(profile.nativeLanguage, findUser.nativeLanguage);
      expect(profile.targetLanguage, findUser.targetLanguage);
      expect(profile.level, findUser.level);
      expect(profile.rating, findUser.rating);
      expect(profile.exchanges, findUser.exchanges);
      expect(profile.bio, findUser.bio);
    });

    test('fromFindUser debe manejar FindUser sin avatarUrl', () {
      const findUser = FindUser(
        id: 'user999',
        name: 'Pedro Sánchez',
        country: 'Argentina',
        nativeLanguage: 'ES',
        targetLanguage: 'IT',
        level: 2,
        rating: 3.8,
        exchanges: 3,
      );

      final profile = PublicUserProfile.fromFindUser(findUser);

      expect(profile.avatarUrl, isNull);
      expect(profile.bio, isNull);
    });
  });
}
