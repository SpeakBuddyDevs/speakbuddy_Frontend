import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // ip del PC.
  final String baseUrl = 'http://10.0.2.2:8080/api/auth'; 
  
  final _storage = const FlutterSecureStorage();

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken']; 

        // Guardamos el token en el almacenamiento seguro del móvil
        await _storage.write(key: 'jwt_token', value: token);
        print("Login Exitoso. Token guardado.");
        return true;
      } else {
        print("Error Login: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register(String name, String email, String password, int nativeLangId, int learnLangId) async {
    final url = Uri.parse('$baseUrl/register');

    
    List<String> names = name.split(" ");
    String firstName = names[0];
    String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': firstName,
          'surname': lastName,
          'email': email,
          'password': password,
          'nativeLanguageId': nativeLangId,
          // El backend espera una lista o un ID para aprender. 
          // Ajusta esto según tu AddLearningLanguageDTO o RegisterDTO
          // Asumiremos que el backend acepta IDs simples por ahora en el registro
          'nativeLanguageId': nativeLangId 
          // NOTA: Tu register actual en Java solo pedía nativeLanguageId.
          // El idioma a aprender se añade DESPUÉS en la HU 1.2.
          // Así que en el registro inicial solo mandamos el nativo.
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registro Exitoso");
        return true;
      } else {
        print("Error Registro: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Método para obtener el token guardado 
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}