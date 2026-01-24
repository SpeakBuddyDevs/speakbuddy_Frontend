import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../constants/languages.dart';
import '../models/find_user.dart';
import '../models/find_filters.dart';
import '../services/auth_service.dart';
import 'find_users_repository.dart';

/// Implementación API del repositorio de búsqueda de usuarios.
/// GET /api/users/search?nativeLang=&learningLang=&page=&size=
class ApiFindUsersRepository implements FindUsersRepository {
  final _authService = AuthService();

  @override
  Future<List<FindUser>> searchUsers({
    String query = '',
    FindFilters? filters,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return [];

      String? nativeLang;
      String? learningLang;
      if (filters != null) {
        if (filters.nativeLanguage != null &&
            filters.nativeLanguage!.isNotEmpty) {
          final code = AppLanguages.getCodeFromName(filters.nativeLanguage!);
          if (code != null) nativeLang = code.toLowerCase();
        }
        if (filters.targetLanguage != null &&
            filters.targetLanguage!.isNotEmpty) {
          final code = AppLanguages.getCodeFromName(filters.targetLanguage!);
          if (code != null) learningLang = code.toLowerCase();
        }
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'size': pageSize.toString(),
        if (nativeLang != null && nativeLang.isNotEmpty) 'nativeLang': nativeLang,
        if (learningLang != null && learningLang.isNotEmpty)
          'learningLang': learningLang,
      };
      final uri = Uri.parse(ApiEndpoints.usersSearch)
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      final content = data['content'] as List?;
      if (content == null) return [];

      return content
          .map((e) => _mapSummaryToFindUser(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('🔴 [FindUsers] Error: $e');
      print(st);
      rethrow;
    }
  }

  FindUser _mapSummaryToFindUser(Map<String, dynamic> dto) {
    final rawCode = dto['nativeLanguageCode'] as String?;
    final code = rawCode != null && rawCode.isNotEmpty
        ? rawCode.toString().toUpperCase()
        : 'ES';
    final nativeLanguage = dto['nativeLanguage'] as String? ??
        AppLanguages.getName(code);

    final learning = dto['languagesToLearn'] as List?;
    String targetLanguage = '—';
    if (learning != null && learning.isNotEmpty) {
      final first = learning.first as Map<String, dynamic>?;
      final name = first?['languageName'] as String?;
      if (name != null && name.isNotEmpty) targetLanguage = name;
    }

    return FindUser(
      id: dto['id']?.toString() ?? '',
      name: dto['username'] as String? ?? 'Usuario',
      country: '',
      avatarUrl: dto['profilePicture'] as String?,
      isOnline: false,
      isPro: false,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      level: 0,
      rating: 0.0,
      exchanges: 0,
      bio: null,
    );
  }
}
