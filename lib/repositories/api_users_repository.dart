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

      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
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

      final data = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      return _mapProfileResponseToPublic(data);
    } catch (e, st) {
      print('🔴 [PublicProfile] Error: $e');
      print(st);
      return null;
    }
  }

  PublicUserProfile _mapProfileResponseToPublic(Map<String, dynamic> json) {
    final nameSurname =
        '${json['name'] ?? ''} ${json['surname'] ?? ''}'.trim();
    final name = nameSurname.isNotEmpty ? nameSurname : (json['username'] as String? ?? 'Usuario');

    final native = json['nativeLanguage'] as Map<String, dynamic>?;
    String nativeLanguage = '—';
    if (native != null) {
      final n = native['name'] as String?;
      if (n != null && n.isNotEmpty) {
        nativeLanguage = n;
      } else {
        final iso = (native['isoCode'] as String? ?? 'es').toString().toUpperCase();
        nativeLanguage = AppLanguages.getName(iso);
      }
    }

    final learning = json['languagesToLearn'] as List?;
    String targetLanguage = '—';
    if (learning != null && learning.isNotEmpty) {
      final first = learning.first as Map<String, dynamic>?;
      final lang = first?['language'] as Map<String, dynamic>?;
      final n = lang?['name'] as String?;
      if (n != null && n.isNotEmpty) targetLanguage = n;
    }

    return PublicUserProfile(
      id: json['id']?.toString() ?? '',
      name: name,
      country: '',
      avatarUrl: json['profilePictureURL'] as String?,
      isOnline: false,
      isPro: false,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      level: (json['level'] ?? 1) as int,
      rating: 0.0,
      exchanges: 0,
      bio: null,
      interests: null,
    );
  }

  Future<bool> updateProfile(
    String userId, {
    String? name,
    String? surname,
    String? profilePictureUrl,
  }) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (surname != null) body['surname'] = surname;
      if (profilePictureUrl != null) body['profilePictureUrl'] = profilePictureUrl;

      final url = Uri.parse(ApiEndpoints.userProfile(userId));
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        print('🔴 [Profile] updateProfile ${response.statusCode}: ${response.body}');
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] updateProfile error: $e');
      print(st);
      return false;
    }
  }

  Future<bool> updateNativeLanguage(String userId, String newNativeLanguageCode) async {
    final code = newNativeLanguageCode.toUpperCase();
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
        print('🔴 [Profile] updateNativeLanguage ${response.statusCode}: ${response.body}');
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] updateNativeLanguage error: $e');
      print(st);
      return false;
    }
  }

  Future<bool> addLearningLanguage(String userId, String languageCode, {int levelId = 1}) async {
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
        print('🔴 [Profile] addLearningLanguage ${response.statusCode}: ${response.body}');
        return false;
      }
      return true;
    } catch (e, st) {
      print('🔴 [Profile] addLearningLanguage error: $e');
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

      final response = await http.get(
        url,
        headers: headers,
      );

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

  // Mapeador manual (Json -> UserProfile)
  UserProfile _mapJsonToProfile(Map<String, dynamic> json) {
    // Normalizar nativeLanguage a mayúsculas (backend envía "es", app usa "ES")
    final rawNative = json['nativeLanguage'] as String?;
    final nativeLanguage =
        rawNative != null && rawNative.isNotEmpty ? rawNative.toUpperCase() : 'ES';

    // Mapear la lista de idiomas (code también a mayúsculas)
    List<LanguageItem> learningLangs = [];
    if (json['learningLanguages'] != null) {
      learningLangs = (json['learningLanguages'] as List).map((l) {
        final rawCode = l['code'] as String?;
        final code = rawCode != null && rawCode.isNotEmpty
            ? rawCode.toString().toUpperCase()
            : 'EN';
        return LanguageItem(
          code: code,
          name: l['name'] ?? 'Inglés',
          level:
              l['level']?.toString().split(' - ')[0] ??
              'A1', // "A1 - Beginner" -> "A1"
          active: true,
        );
      }).toList();
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      progressPct: (json['progressPct'] ?? 0.0).toDouble(),
      exchanges: json['exchanges'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      languagesCount: json['languagesCount'] ?? 0,
      hoursTotal: json['hoursTotal'] ?? 0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      bestStreakDays: json['bestStreakDays'] ?? 0,
      medals: json['medals'] ?? 0,
      learningLanguages: learningLangs,
      isPro: json['isPro'] ?? false,
      nativeLanguage: nativeLanguage,
      description: json['description'] ?? '',
      avatarPath: json['avatarUrl'] as String?,
    );
  }
}
