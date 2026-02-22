# Migración: Intercambios Privados de "Enlace" a "Contraseña"

## Contexto del Problema

Actualmente, los intercambios privados funcionan mediante un `shareToken` que se genera al crear el intercambio y se comparte como enlace `speakbuddy://exchange/{token}`. 

**Problema**: El enlace se envía como texto plano por chats (WhatsApp, Telegram) y no es clicable, lo que genera mala experiencia de usuario.

## Nueva Solución

Los intercambios privados aparecerán en la lista pública con un **icono de candado**. Para unirse, el usuario deberá introducir una **contraseña** de 6 caracteres que el creador copia y comparte manualmente.

| Antes | Después |
|-------|---------|
| Intercambio privado NO aparece en lista pública | Aparece con icono de candado |
| Creador recibe enlace `speakbuddy://exchange/TOKEN` | Creador recibe contraseña de 6 caracteres (ej: `X4K9P2`) |
| Usuario pega enlace en campo especial de la app | Usuario pulsa "Unirse" y escribe la contraseña |
| Deep links configurados en Android | Sin deep links |

---

## FASE 1: BACKEND (Java - Spring Boot)

### 1.1 Modelo `Exchange`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/models/Exchange.java`

**ELIMINAR** campo:
```java
@Column(name = "share_token", length = 64, unique = true)
private String shareToken;
```

**AÑADIR** campo:
```java
@Column(name = "password", length = 20)
private String password;
```

---

### 1.2 Servicio `ExchangeService`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/service/ExchangeService.java`

#### MODIFICAR método `create()` (líneas ~111-115)

**ELIMINAR** esta lógica:
```java
if (Boolean.FALSE.equals(dto.getIsPublic())) {
    String token = UUID.randomUUID().toString().replace("-", "");
    exchange.setShareToken(token);
}
```

**REEMPLAZAR POR**:
```java
if (Boolean.FALSE.equals(dto.getIsPublic())) {
    String password = generateRandomPassword(6);
    exchange.setPassword(password);
}
```

#### AÑADIR método helper:
```java
private String generateRandomPassword(int length) {
    // Sin I, O, 0, 1 para evitar confusión visual
    String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    java.security.SecureRandom random = new java.security.SecureRandom();
    StringBuilder sb = new StringBuilder(length);
    for (int i = 0; i < length; i++) {
        sb.append(chars.charAt(random.nextInt(chars.length())));
    }
    return sb.toString();
}
```

#### ELIMINAR métodos completos:

1. **`joinByLink()`** (líneas ~206-242)
2. **`getByShareToken()`** (líneas ~539-553)

#### AÑADIR nuevo método:
```java
@Transactional
public ExchangeResponseDTO joinWithPassword(Long exchangeId, String password, Long userId) {
    Exchange exchange = exchangeRepository.findById(exchangeId)
            .orElseThrow(() -> new ResourceNotFoundException("Intercambio no encontrado"));

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

    if (Boolean.TRUE.equals(exchange.getIsPublic())) {
        throw new IllegalArgumentException("Este intercambio es público. Usa el botón Unirse habitual");
    }

    if (exchange.getPassword() == null || !exchange.getPassword().equalsIgnoreCase(password.trim())) {
        throw new IllegalArgumentException("Contraseña incorrecta");
    }

    if (exchange.getStatus() != ExchangeStatus.SCHEDULED) {
        throw new IllegalArgumentException("Este intercambio ya no está disponible");
    }

    if (participantRepository.existsByExchangeAndUser(exchange, user)) {
        throw new IllegalArgumentException("Ya eres participante de este intercambio");
    }

    int currentCount = participantRepository.findByExchange(exchange).size();
    if (exchange.getMaxParticipants() != null && currentCount >= exchange.getMaxParticipants()) {
        throw new IllegalArgumentException("El intercambio está completo");
    }

    ExchangeParticipant participant = new ExchangeParticipant();
    participant.setExchange(exchange);
    participant.setUser(user);
    participant.setRole("participant");
    participantRepository.save(participant);

    return toResponseDTO(exchange, userId);
}
```

#### MODIFICAR `searchPublicExchanges()`:

Cambiar la especificación para que devuelva **TODOS los intercambios SCHEDULED** (públicos Y privados). Los privados se mostrarán con `isPublic=false` y el cliente mostrará el candado.

#### MODIFICAR `toPublicExchangeResponseDTO()` (líneas ~555-606):

**ELIMINAR** lógica de shareLink (líneas ~574-577):
```java
// ELIMINAR:
String shareLink = null;
if (Boolean.FALSE.equals(exchange.getIsPublic()) && exchange.getShareToken() != null) {
    shareLink = "speakbuddy://exchange/" + exchange.getShareToken();
}
```

**AÑADIR** lógica de password (solo visible para el creador):
```java
String password = null;
if (Boolean.FALSE.equals(exchange.getIsPublic()) 
    && currentUser != null 
    && creator != null 
    && currentUser.getId().equals(creator.getId())) {
    password = exchange.getPassword();
}
```

**MODIFICAR** el builder: cambiar `.shareLink(shareLink)` por `.password(password)`

#### MODIFICAR `toResponseDTO()` (líneas ~698-746):

**ELIMINAR** lógica de shareLink (líneas ~727-730):
```java
// ELIMINAR:
String shareLink = null;
if (Boolean.FALSE.equals(exchange.getIsPublic()) && exchange.getShareToken() != null) {
    shareLink = "speakbuddy://exchange/" + exchange.getShareToken();
}
```

**AÑADIR** lógica de password y modificar builder igual que arriba.

---

### 1.3 DTOs

#### `PublicExchangeResponseDTO.java`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/PublicExchangeResponseDTO.java`

- **ELIMINAR**: campo `private String shareLink;`
- **AÑADIR**: campo `private String password;`

#### `ExchangeResponseDTO.java`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/ExchangeResponseDTO.java`

- **ELIMINAR**: campo `private String shareLink;`
- **AÑADIR**: campo `private String password;`

#### ELIMINAR archivo completo:

`speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/JoinByLinkRequestDTO.java`

#### CREAR nuevo DTO:

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/JoinWithPasswordRequestDTO.java`

```java
package com.speakBuddy.speackBuddy_backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinWithPasswordRequestDTO {
    @NotBlank(message = "La contraseña es obligatoria")
    private String password;
}
```

---

### 1.4 Controlador `ExchangeController`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/controller/ExchangeController.java`

#### ELIMINAR endpoints:

1. `GET /exchanges/by-token/{token}`
2. `POST /exchanges/{id}/join-by-link`

#### AÑADIR endpoint:

```java
@PostMapping("/{id}/join-with-password")
public ResponseEntity<ExchangeResponseDTO> joinWithPassword(
        @PathVariable Long id,
        @RequestBody @Valid JoinWithPasswordRequestDTO dto,
        @AuthenticationPrincipal UserDetails userDetails) {
    Long userId = getCurrentUserId(userDetails);
    return ResponseEntity.ok(exchangeService.joinWithPassword(id, dto.getPassword(), userId));
}
```

---

### 1.5 Repositorio `ExchangeRepository`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/repository/ExchangeRepository.java`

**ELIMINAR** método:
```java
Optional<Exchange> findByShareToken(String shareToken);
```

---

### 1.6 Especificación `ExchangeSpecification`

**Archivo**: `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/repository/specifications/ExchangeSpecification.java`

**MODIFICAR** `publicExchangesWithFilters()`:

Cambiar para que devuelva intercambios con `status=SCHEDULED` sin filtrar por `isPublic`. Los intercambios privados también deben aparecer.

---

### 1.7 Migración de Base de Datos

Crear script SQL:

```sql
-- Eliminar columna share_token
ALTER TABLE exchanges DROP COLUMN IF EXISTS share_token;

-- Añadir columna password
ALTER TABLE exchanges ADD COLUMN password VARCHAR(20);

-- Generar contraseñas para intercambios privados existentes (si los hay)
UPDATE exchanges 
SET password = UPPER(SUBSTRING(MD5(RANDOM()::text), 1, 6))
WHERE is_public = false AND password IS NULL;
```

---

## FASE 2: FLUTTER (Frontend)

### 2.1 Archivos a ELIMINAR completamente

| Archivo | Motivo |
|---------|--------|
| `lib/screens/exchange_by_link_screen.dart` | Pantalla de acceso por enlace ya no se usa |
| `lib/navigation/exchange_by_link_args.dart` | Argumentos de navegación por enlace ya no se usan |
| `lib/widgets/share_link_dialog.dart` | Diálogo de compartir enlace reemplazado por contraseña |

---

### 2.2 `lib/constants/routes.dart`

**ELIMINAR** línea:
```dart
static const String exchangeByLink = '/exchange-by-link';
```

---

### 2.3 `lib/main.dart`

**ELIMINAR** todo lo relacionado con deep links:

1. Importación de `app_links` package
2. Importación de `exchange_by_link_args.dart`
3. Método `_initDeepLinks()` o similar
4. Llamadas a `getInitialLink()`, `uriLinkStream`, etc.
5. La ruta `AppRoutes.exchangeByLink` del `onGenerateRoute`

---

### 2.4 `lib/screens/home_screen.dart`

**ELIMINAR**:
1. Importación de `flutter/services.dart` (si solo se usaba para el portapapeles)
2. Importación de `exchange_by_link_args.dart`
3. Widget `_PasteExchangeLinkChip`
4. Método `_onPasteExchangeLink()`
5. Método `_extractTokenFromClipboard()`
6. Referencia a `_PasteExchangeLinkChip` en el `build()` (líneas del Column)

---

### 2.5 `lib/screens/create_exchange_screen.dart`

**ELIMINAR**:
- Importación de `share_link_dialog.dart`

**MODIFICAR** método `_onCreate()`:

**ELIMINAR** lógica actual (líneas ~208-214):
```dart
if (!_isPublic && created.shareLink != null && created.shareLink!.isNotEmpty) {
  await showShareLinkDialog(context, shareLink: created.shareLink!);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Intercambio creado correctamente')),
  );
}
```

**REEMPLAZAR POR**:
```dart
if (!_isPublic && created.password != null && created.password!.isNotEmpty) {
  await showPasswordDialog(context, password: created.password!);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Intercambio creado correctamente')),
  );
}
```

---

### 2.6 CREAR `lib/widgets/password_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';

Future<void> showPasswordDialog(BuildContext context, {required String password}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PasswordDialog(password: password),
  );
}

class PasswordDialog extends StatelessWidget {
  final String password;

  const PasswordDialog({super.key, required this.password});

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: password));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña copiada al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      title: const Text(
        'Intercambio creado',
        style: TextStyle(color: AppTheme.text),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparte esta contraseña para que otros se unan:',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXL,
                vertical: AppDimensions.spacingL,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: SelectableText(
                password,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copiar'),
        ),
      ],
    );
  }
}
```

---

### 2.7 CREAR `lib/widgets/password_input_dialog.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';

Future<String?> showPasswordInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const PasswordInputDialog(),
  );
}

class PasswordInputDialog extends StatefulWidget {
  const PasswordInputDialog({super.key});

  @override
  State<PasswordInputDialog> createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<PasswordInputDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Introduce la contraseña');
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppTheme.accent, size: 24),
          const SizedBox(width: AppDimensions.spacingSM),
          const Text(
            'Intercambio privado',
            style: TextStyle(color: AppTheme.text),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Introduce la contraseña para unirte:',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide.none,
              ),
              hintText: 'XXXXXX',
              hintStyle: TextStyle(
                color: AppTheme.subtle.withOpacity(0.5),
                letterSpacing: 2,
              ),
              errorText: _error,
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _onSubmit,
          child: const Text('Unirse'),
        ),
      ],
    );
  }
}
```

---

### 2.8 `lib/models/public_exchange.dart`

**ELIMINAR** campo:
```dart
final String? shareLink;
```

**AÑADIR** campo:
```dart
final String? password;
```

**ACTUALIZAR** constructor y `fromJson()` para usar `password` en lugar de `shareLink`.

---

### 2.9 `lib/repositories/api_public_exchanges_repository.dart`

**ELIMINAR** métodos:
1. `getExchangeByShareToken(String token)`
2. `joinByLink(String exchangeId, String shareToken)`

**AÑADIR** método:
```dart
Future<void> joinWithPassword(String exchangeId, String password) async {
  final response = await _apiClient.post(
    '/exchanges/$exchangeId/join-with-password',
    body: {'password': password},
  );
  if (response.statusCode != 200) {
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Error al unirse');
  }
}
```

---

### 2.10 `lib/widgets/public_exchanges/public_exchange_card.dart`

**MODIFICAR** para mostrar candado en intercambios privados:

En el título o header del card, añadir:
```dart
if (!exchange.isPublic) ...[
  Icon(
    Icons.lock_rounded,
    color: AppTheme.subtle,
    size: AppDimensions.iconSizeS,
  ),
  const SizedBox(width: AppDimensions.spacingXS),
],
```

**MODIFICAR** el botón "Unirse":

El callback `onJoin` debe verificar si es privado y mostrar el diálogo de contraseña:

```dart
onPressed: () async {
  if (!exchange.isPublic) {
    final password = await showPasswordInputDialog(context);
    if (password != null && password.isNotEmpty) {
      onJoinWithPassword?.call(password);
    }
  } else {
    onJoin?.call();
  }
},
```

Añadir nuevo callback al widget:
```dart
final void Function(String password)? onJoinWithPassword;
```

---

### 2.11 `lib/constants/api_endpoints.dart`

**ELIMINAR** endpoints relacionados con share token si existen:
- `/exchanges/by-token/{token}`
- `/exchanges/{id}/join-by-link`

**AÑADIR** (si se usa el patrón de constantes):
```dart
static String joinWithPassword(String id) => '/exchanges/$id/join-with-password';
```

---

### 2.12 `android/app/src/main/AndroidManifest.xml`

**ELIMINAR** el intent-filter para deep links:

```xml
<!-- ELIMINAR este bloque completo -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="speakbuddy" android:host="exchange" />
</intent-filter>
```

---

### 2.13 `pubspec.yaml`

**ELIMINAR** dependencia `app_links` si ya no se usa para nada más:

```yaml
# ELIMINAR:
app_links: ^6.3.3
```

Ejecutar `flutter pub get` después.

---

## FASE 3: LIMPIEZA FINAL

### 3.1 Búsqueda global

Buscar en todo el proyecto referencias a estos términos y eliminar código muerto:

- `shareToken`
- `shareLink`
- `exchangeByLink`
- `joinByLink`
- `getExchangeByShareToken`
- `app_links`
- `getInitialLink`
- `uriLinkStream`

### 3.2 Verificación

1. Ejecutar `flutter analyze` y corregir errores
2. Ejecutar tests del backend
3. Compilar y probar manualmente:
   - Crear intercambio privado → debe mostrar contraseña
   - Ver lista de intercambios → los privados deben mostrar candado
   - Unirse a intercambio privado → debe pedir contraseña
   - Contraseña incorrecta → debe mostrar error
   - Contraseña correcta → debe unirse

---

## Notas Importantes

1. **Case-insensitive**: La contraseña debe validarse sin distinguir mayúsculas/minúsculas
2. **Caracteres legibles**: Usar solo `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (sin I, O, 0, 1)
3. **Visibilidad**: La contraseña solo es visible para el creador del intercambio
4. **Sin requisitos**: Los intercambios privados NO validan nivel/idioma del usuario
5. **Longitud**: 6 caracteres es suficiente (32^6 = ~1 billón de combinaciones)
