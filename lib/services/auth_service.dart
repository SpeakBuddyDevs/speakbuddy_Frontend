import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../models/auth_result.dart';
import '../models/auth_error.dart';

/// BACKEND: Servicio de autenticación que consume la API REST.
/// 
/// Contrato esperado del backend:
/// - POST /api/auth/login: { email, password } → { accessToken, refreshToken?, expiresIn?, user? }
/// - POST /api/auth/register: { name, surname, email, password, nativeLanguageId } → 201
/// - POST /api/auth/logout: Invalida token (opcional)
/// - POST /api/auth/refresh: { refreshToken } → { accessToken, expiresIn }
class AuthService {
  final _storage = const FlutterSecureStorage();

  // --- LOGIN ---
  // BACKEND: POST /api/auth/login
  // Request: { "email": string, "password": string }
  // Response 200: { "accessToken": string, "refreshToken"?: string, "expiresIn"?: int, "user"?: UserDTO }
  // TODO(BE): Incluir refreshToken y expiresIn en la respuesta para manejo de sesión
  // TODO(FE): Guardar refreshToken y programar renovación antes de expiración
  Future<AuthResult> login(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.login);
    
    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken']; 

        // Guardamos el token en el almacenamiento seguro del móvil
        await _storage.write(key: AppConstants.jwtTokenKey, value: token);
        debugPrint("Login Exitoso. Token guardado.");
        return AuthResult.success(token: token);
      } else {
        debugPrint("Error Login: ${response.body}");
        return AuthResult.failure(
          AuthError.fromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
      return AuthResult.failure(NetworkError());
    }
  }

  // --- REGISTER ---
  // BACKEND: POST /api/auth/register
  // Request: { "name": string, "surname": string, "email": string, "password": string, "nativeLanguageId": int }
  // Response 201: Usuario creado (opcionalmente devolver { userId } o auto-login con token)
  // TODO(BE): Validar email único (409 si ya existe), password mínimo 6 chars
  Future<AuthResult> register(String name, String email, String password, int nativeLangId, int learnLangId) async {
    final url = Uri.parse(ApiEndpoints.register);

    
    List<String> names = name.split(" ");
    String firstName = names[0];
    String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

    try {
      final response = await http.post(
        url,
        headers: AppConstants.jsonHeaders,
        body: jsonEncode({
          'name': firstName,
          'surname': lastName,
          'email': email,
          'password': password,
          'nativeLanguageId': nativeLangId,
          // BACKEND: El idioma a aprender se añade después del registro (HU 1.2)
          // TODO(BE): Endpoint POST /api/profile/languages para añadir idiomas de aprendizaje
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("Registro Exitoso");
        return AuthResult.success();
      } else {
        debugPrint("Error Registro: ${response.body}");
        return AuthResult.failure(
          AuthError.fromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      debugPrint("Error de conexión: $e");
      return AuthResult.failure(NetworkError());
    }
  }

  /// Obtiene el token JWT guardado en almacenamiento seguro
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.jwtTokenKey);
  }
  
  /// Cierra sesión eliminando el token local
  // TODO(BE): Llamar POST /api/auth/logout para invalidar token en servidor (opcional)
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.jwtTokenKey);
  }
}