# Tests de Flutter SpeakBuddy

Este directorio contiene todos los tests unitarios del proyecto.

## Estructura de Tests

### Servicios (`test/services/`)
- **current_user_service_test.dart**: Tests para el servicio de usuario actual
  - Verifica el patrón singleton
  - Valida los métodos getDisplayName, getLevel, getProgressToNextLevel, isPro

- **auth_service_test.dart**: Tests para el servicio de autenticación
  - Verifica la estructura básica del servicio
  - Nota: Los tests de getToken y logout manejan excepciones de plugins nativos

### Modelos (`test/models/`)
- **user_profile_test.dart**: Tests para el modelo UserProfile
  - Verifica la creación de perfiles
  - Valida el método copyWith con diferentes escenarios
  - Verifica campos opcionales

- **public_user_profile_test.dart**: Tests para el modelo PublicUserProfile
  - Verifica la creación de perfiles públicos
  - Valida el factory fromFindUser
  - Verifica campos opcionales

- **auth_result_test.dart**: Tests para el modelo AuthResult
  - Verifica los factories success y failure
  - Valida el constructor directo

- **auth_error_test.dart**: Tests para los errores de autenticación
  - Verifica fromResponse con diferentes códigos HTTP
  - Valida todos los tipos de errores (NetworkError, InvalidCredentialsError, etc.)
  - Verifica mensajes por defecto y personalizados

### Utilidades (`test/utils/`)
- **validators_test.dart**: Tests para FormValidators
  - Valida emails (válidos e inválidos)
  - Valida contraseñas (longitud mínima, requeridas)
  - Valida nombres
  - Valida coincidencia de contraseñas
  - Valida campos requeridos genéricos
  - Verifica isFormValid (con manejo de excepciones para GlobalKey)

- **image_helpers_test.dart**: Tests para getAvatarImageProvider
  - Verifica la prioridad: pickedFile > filePath > assetPath
  - Valida la creación de FileImage y AssetImage
  - Verifica el retorno null cuando todos los parámetros son null

### Repositorios (`test/repositories/`)
- **fake_users_repository_test.dart**: Tests para FakeUsersRepository
  - Verifica la obtención de perfiles públicos cuando el usuario existe
  - Verifica el retorno null cuando el usuario no existe
  - Valida la simulación de latencia de red
  - Verifica que todos los campos requeridos están presentes

## Ejecutar Tests

Para ejecutar todos los tests:
```bash
flutter test
```

Para ejecutar un archivo específico:
```bash
flutter test test/models/user_profile_test.dart
```

Para ejecutar con cobertura:
```bash
flutter test --coverage
```

## Cobertura

Los tests cubren:
- ✅ Servicios principales (CurrentUserService, AuthService)
- ✅ Modelos de datos (UserProfile, PublicUserProfile, AuthResult, AuthError)
- ✅ Utilidades de validación (FormValidators)
- ✅ Helpers de imágenes (getAvatarImageProvider)
- ✅ Repositorios fake (FakeUsersRepository)

## Notas

- Algunos tests que usan plugins nativos (como FlutterSecureStorage) pueden lanzar excepciones en el entorno de pruebas. Estos están manejados apropiadamente.
- Los tests de widgets requieren `TestWidgetsFlutterBinding.ensureInitialized()` y se han configurado correctamente.
