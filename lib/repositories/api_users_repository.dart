import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../constants/language_ids.dart';
import '../constants/languages.dart';
import '../models/user_profile.dart';
import '../models/language_item.dart';
import '../models/public_user_profile.dart';
import '../services/auth_service.dart';
import 'users_repository.dart';

class ApiUsersRepository implements UsersRepository {
  final _authService = AuthService();
  Map<String, int>? _languageIdCache;

  Future<Map<String, int>> _fetchLanguageIds() async {
    if (_languageIdCache != null) return _languageIdCache!;
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return {};

      final url = Uri.parse(ApiEndpoints.languages);
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) return {};

      final list =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
      if (list == null) return {};
      final map = <String, int>{};
      for (final e in list) {
        final o = e as Map<String, dynamic>?;
        if (o == null) continue;
        final id = o['id'];
        final iso = o['isoCode'] as String?;
        if (id != null && iso != null && iso.isNotEmpty) {
          final v = (id is int) ? id : int.tryParse(id.toString());
          if (v != null && v != 0) map[iso.toUpperCase()] = v;
        }
      }
      _languageIdCache = map;
      return map;
    } catch (e, st) {
      print('🔴 [Profile] _fetchLanguageIds error: $e');
      print(st);
      return {};
    }
  }

  @override
  Future<PublicUserProfile?> getPublicProfile(String userId) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse(ApiEndpoints.userProfile(userId));
      final response = await http.get(url, headers: headers);

      if (response.statusCode != 200) return null;

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return _mapProfileResponseToPublic(data);
    } catch (e, st) {
      print('🔴 [PublicProfile] Error: $e');
      print(st);
      return null;
    }
  }

  PublicUserProfile _mapProfileResponseToPublic(Map<String, dynamic> json) {
    final nameSurname = '${json['name'] ?? ''} ${json['surname'] ?? ''}'.trim();
    final name = nameSurname.isNotEmpty
        ? nameSurname
        : (json['username'] as String? ?? 'Usuario');

    final native = json['nativeLanguage'] as Map<String, dynamic>?;
    String nativeLanguage = '—';
    if (native != null) {
      final n = native['name'] as String?;
      if (n != null && n.isNotEmpty) {
        nativeLanguage = n;
      } else {
        final iso = (native['isoCode'] as String? ?? 'es')
            .toString()
            .toLowerCase();
        nativeLanguage = AppLanguages.getName(iso);
      }
    }

    final learning = json['languagesToLearn'] as List?;
    List<LanguageItem> learningLanguages = [];
    if (learning != null && learning.isNotEmpty) {
      learningLanguages = learning.map((item) {
        final langMap = item as Map<String, dynamic>?;
        final lang = langMap?['language'] as Map<String, dynamic>?;
        final name = lang?['name'] as String? ?? '';
        final isoCode = (lang?['isoCode'] as String? ?? '').toLowerCase();
        final levelName = langMap?['levelName'] as String? ?? '';
        final active = langMap?['active'] == true;
        return LanguageItem(
          code: isoCode,
          name: name,
          level: levelName,
          active: active,
        );
      }).where((l) => l.name.isNotEmpty).toList();
    }

    final rawRating = json['averageRating'];
    final rating = (rawRating is num) ? rawRating.toDouble() : 0.0;
    final rawExchanges = json['completedExchanges'];
    final exchanges = (rawExchanges is int)
        ? rawExchanges
        : int.tryParse((rawExchanges ?? '0').toString()) ?? 0;
    final country = (json['country'] as String?)?.trim() ?? '';
    final bio = (json['description'] as String?)?.trim();
    return PublicUserProfile(
      id: json['id']?.toString() ?? '',
      name: name,
      country: country,
      avatarUrl: json['profilePictureURL'] as String?,
      isOnline: false,
      isPro: json['isPro'] == true,
      nativeLanguage: nativeLanguage,
      learningLanguages: learningLanguages,
      level: (json['level'] is int) ? json['level'] as int : int.tryParse((json['level'] ?? '1').toString()) ?? 1,
      rating: rating,
      exchanges: exchanges,
      bio: (bio != null && bio.isNotEmpty) ? bio : null,
      interests: null,
    );
  }

  Future<bool> updateProfile(
    String userId, {
    String? name,
    String? surname,
    String? profilePictureUrl,
    String? description,
  }) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (surname != null) body['surname'] = surname;
      if (profilePictureUrl != null)
        body['profilePictureUrl'] = profilePictureUrl;
      if (description != null) body['description'] = description;

      final url = Uri.parse(ApiEndpoints.userProfile(userId));
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        print(
          '🔴 [Profile] updateProfile ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] updateProfile error: $e');
      print(st);
      return false;
    }
  }

  Future<bool> updateNativeLanguage(
    String userId,
    String newNativeLanguageCode,
  ) async {
    final code = newNativeLanguageCode.toLowerCase();
    final languageId = LanguageIds.getId(code);
    if (languageId == null) return false;
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(ApiEndpoints.userLanguagesNative(userId));
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'newNativeLanguageId': languageId}),
      );
      if (response.statusCode != 200) {
        print(
          '🔴 [Profile] updateNativeLanguage ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] updateNativeLanguage error: $e');
      print(st);
      return false;
    }
  }

  Future<bool> addLearningLanguage(
    String userId,
    String languageCode, {
    int levelId = 1,
  }) async {
    final code = languageCode.toUpperCase();
    final ids = await _fetchLanguageIds();
    final languageId = ids[code] ?? LanguageIds.getId(code);
    if (languageId == null || languageId == 0) return false;
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(ApiEndpoints.userLanguagesLearn(userId));
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'languageId': languageId, 'levelId': levelId}),
      );
      if (response.statusCode != 200) {
        print(
          '🔴 [Profile] addLearningLanguage ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] addLearningLanguage error: $e');
      print(st);
      return false;
    }
  }

  Future<bool> setLearningLanguageActive(
    String userId,
    String languageCode,
  ) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      // URL: /api/users/{userId}/languages/{code}/active
      final url = Uri.parse(
        '${ApiEndpoints.apiBase}/users/$userId/languages/$languageCode/active',
      );

      // Usamos PATCH porque así lo definimos en el backend (@PatchMapping)
      final response = await http.patch(url, headers: headers);

      if (response.statusCode != 200) {
        print('🔴 [Profile] Error al activar idioma: ${response.statusCode}');
        return false;
      }
      return true;
    } catch (e) {
      print('🔴 [Profile] Excepción al activar idioma: $e');
      return false;
    }
  }

  Future<bool> setLearningLanguageInactive(
    String userId,
    String languageCode,
  ) async {
    try {
      final headers = await _authService.headersWithAuth();
      // URL: /api/users/{userId}/languages/{code}/inactive
      final url = Uri.parse(
        '${ApiEndpoints.apiBase}/users/$userId/languages/$languageCode/inactive',
      );

      // Usamos PATCH
      final response = await http.patch(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print('🔴 [Profile] Error desactivando idioma: $e');
      return false;
    }
  }

  /// Eliminar idioma de aprendizaje por código
  Future<bool> deleteLearningLanguage(
    String userId,
    String languageCode,
  ) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(
        ApiEndpoints.userLanguagesLearnByCode(userId, languageCode),
      );

      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200) {
        print(
          '🔴 [Profile] deleteLearningLanguage ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] deleteLearningLanguage error: $e');
      print(st);
      return false;
    }
  }

  /// Actualizar nivel de idioma de aprendizaje por código
  Future<bool> updateLearningLevel(
    String userId,
    String languageCode,
    int newLevelId,
  ) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(
        ApiEndpoints.userLanguagesLevelByCode(userId, languageCode),
      );

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'newLevelId': newLevelId}),
      );

      if (response.statusCode != 200) {
        print(
          '🔴 [Profile] updateLearningLevel ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] updateLearningLevel error: $e');
      print(st);
      return false;
    }
  }

  /// Eliminar la cuenta del usuario autenticado
  Future<bool> deleteAccount() async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(ApiEndpoints.me);
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        print(
          '🔴 [Profile] deleteAccount ${response.statusCode}: ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] deleteAccount error: $e');
      print(st);
      return false;
    }
  }

  /// Obtener mi perfil completo
  Future<UserProfile?> getMyProfile() async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse(ApiEndpoints.me);

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return _mapJsonToProfile(data);
      }
      return null;
    } catch (e, stackTrace) {
      print('🔴 [Profile] Error: $e');
      print(stackTrace);
      return null;
    }
  }

  /// Subir foto de perfil (multipart/form-data)
  /// Devuelve la URL completa de la imagen subida, o null si falla
  Future<String?> uploadProfilePicture(String userId, String filePath) async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse(ApiEndpoints.userProfilePicture(userId));

      // Crear request multipart
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Añadir archivo
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Enviar
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String? imageUrl = data['url'] as String?;

        // Convertir URL relativa a absoluta si es necesario
        if (imageUrl != null && imageUrl.startsWith('/')) {
          imageUrl = '${ApiEndpoints.baseUrl}$imageUrl';
        }

        print('✅ [Profile] Imagen subida: $imageUrl');
        return imageUrl;
      } else {
        print(
          '🔴 [Profile] uploadProfilePicture ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e, st) {
      print('🔴 [Profile] uploadProfilePicture error: $e');
      print(st);
      return null;
    }
  }

  // Mapeador manual (Json -> UserProfile)
  UserProfile _mapJsonToProfile(Map<String, dynamic> json) {
    // Normalizar nativeLanguage a minúsculas (consistente con AppLanguages.codeToName)
    final rawNative = json['nativeLanguage'] as String?;
    final nativeLanguage = rawNative != null && rawNative.isNotEmpty
        ? rawNative.toLowerCase()
        : 'es';

    // Mapear la lista de idiomas (code también a minúsculas)
    List<LanguageItem> learningLangs = [];
    if (json['learningLanguages'] != null) {
      learningLangs = (json['learningLanguages'] as List).map((l) {
        final rawCode = l['code'] as String?;
        final code = rawCode != null && rawCode.isNotEmpty
            ? rawCode.toString().toLowerCase()
            : 'en';
        return LanguageItem(
          code: code,
          name: l['name'] ?? 'Inglés',
          level:
              l['level']?.toString() ??
              'A1', // "A1 - Beginner" -> "A1"
          active: l['active'] ?? false,
        );
      }).toList();
    }

    // Convertir URL del avatar de relativa a absoluta si es necesario
    String? avatarUrl = json['avatarUrl'] as String?;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = json['profilePictureURL'] as String?;
    }
    if (avatarUrl != null && avatarUrl.startsWith('/')) {
      avatarUrl = '${ApiEndpoints.baseUrl}$avatarUrl';
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 100,
      progressPct: (json['progressPct'] ?? 0.0).toDouble(),
      streakMultiplier: (json['streakMultiplier'] ?? 1.0).toDouble(),
      canClaimDailyBonus: json['canClaimDailyBonus'] ?? true,
      exchanges: json['exchanges'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      languagesCount: json['languagesCount'] ?? 0,
      hoursTotal: (json['hoursTotal'] as num?)?.toDouble() ?? 0.0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      bestStreakDays: json['bestStreakDays'] ?? 0,
      medals: json['medals'] ?? 0,
      learningLanguages: learningLangs,
      isPro: json['isPro'] ?? false,
      nativeLanguage: nativeLanguage,
      description: json['description'] ?? '',
      avatarPath: avatarUrl,
    );
  }

  /// Reclamar el bonus diario de XP.
  /// Devuelve un mapa con información del resultado, o null si hay error.
  Future<Map<String, dynamic>?> claimDailyBonus() async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return null;

      final url = Uri.parse('${ApiEndpoints.me}/daily-bonus');
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data as Map<String, dynamic>;
      }
      return null;
    } catch (e, st) {
      print('🔴 [Profile] claimDailyBonus error: $e');
      print(st);
      return null;
    }
  }
}
