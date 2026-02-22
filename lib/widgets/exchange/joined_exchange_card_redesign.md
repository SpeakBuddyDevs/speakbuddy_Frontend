# Rediseño de Tarjeta de Intercambio - Home Screen

## Referencia de Diseño
Ver imagen de Figma en: `C:\Users\sergi\.cursor\projects\c-Users-sergi-AndroidStudioProjects-flutter-speakbuddy/assets/c__Users_sergi_AppData_Roaming_Cursor_User_workspaceStorage_7fcf03f2dc3fb4db71284ba3b7caa100_images_image-d8877f8b-e4da-4e98-a7c8-b05284f41382.png`

## Objetivo
Rediseñar `JoinedExchangeCard` para que coincida con el diseño de Figma, aplicando las siguientes modificaciones:

### Cambios respecto al diseño original de Figma:
1. **Tipo → Plataforma**: En lugar de mostrar "Tipo: Videollamada", mostrar "Plataforma: Zoom, Teams, Google Meet..." según las plataformas seleccionadas por el usuario.
2. **Idioma → Idiomas del intercambio**: En lugar de mostrar un solo idioma, mostrar los dos idiomas del intercambio (ej: "Español - Inglés").

---

## PARTE 1: CAMBIOS EN BACKEND (Java/Spring Boot)

### Paso 1.1: Actualizar ExchangeParticipantDTO ✅ COMPLETADO

**Archivo:** `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/ExchangeParticipantDTO.java`

Añadir los siguientes campos:
```java
private String avatarUrl;      // URL de la foto de perfil (User.profilePicture)
private Double rating;         // Puntuación del usuario (User.averageRating)
private String country;        // País del usuario (User.country)
private Boolean isPro;         // Si tiene suscripción PRO (User.role == ROLE_PREMIUM)
```

### Paso 1.2: Actualizar ExchangeResponseDTO ✅ COMPLETADO

**Archivo:** `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/dto/ExchangeResponseDTO.java`

Añadir los siguientes campos:
```java
/** Nombre del idioma nativo que el creador ofrece (ej: "Español") */
private String nativeLanguage;

/** Nombre del idioma que el creador quiere practicar (ej: "Inglés") */
private String targetLanguage;

/** Plataformas de videollamada (Zoom, Google Meet, etc.) */
private List<String> platforms;
```

### Paso 1.3: Actualizar el método toResponseDTO() en ExchangeService ✅ COMPLETADO

**Archivo:** `speakBuddy/src/main/java/com/speakBuddy/speackBuddy_backend/service/ExchangeService.java`

En el método `toResponseDTO()` (líneas 687-741), actualizar:

1. **Mapeo de participantes** - Añadir los nuevos campos al crear `ExchangeParticipantDTO`:
```java
.map(p -> {
    User u = p.getUser();
    ExchangeParticipantDTO dto = new ExchangeParticipantDTO();
    dto.setUserId(u.getId());
    dto.setUsername(u.getUsername());
    dto.setConfirmed(p.isConfirmed());
    dto.setRole(p.getRole());
    // Nuevos campos
    dto.setAvatarUrl(u.getProfilePicture());
    dto.setRating(u.getAverageRating());
    dto.setCountry(u.getCountry());
    dto.setIsPro(u.getRole() == Role.ROLE_PREMIUM);
    return dto;
})
```

2. **Builder de ExchangeResponseDTO** - Añadir los nuevos campos:
```java
.nativeLanguage(resolveLanguageName(exchange.getNativeLanguageCode()))
.targetLanguage(resolveLanguageName(exchange.getTargetLanguageCode()))
.platforms(exchange.getPlatforms() != null && !exchange.getPlatforms().isEmpty() 
           ? exchange.getPlatforms() : null)
```

**Nota:** El método `resolveLanguageName()` ya existe en el servicio (líneas 635-640).

---

## PARTE 2: CAMBIOS EN FLUTTER (Frontend)

### Paso 2.1: Actualizar modelo JoinedExchangeParticipant ✅ COMPLETADO

**Archivo:** `lib/models/joined_exchange.dart`

Añadir campos a `JoinedExchangeParticipant`:
```dart
final String? avatarUrl;
final double? rating;
final String? country;
final bool isPro;
```

Actualizar el constructor y `fromJson`:
```dart
const JoinedExchangeParticipant({
  required this.userId,
  required this.username,
  required this.confirmed,
  required this.role,
  this.avatarUrl,
  this.rating,
  this.country,
  this.isPro = false,
});

factory JoinedExchangeParticipant.fromJson(Map<String, dynamic> json) {
  return JoinedExchangeParticipant(
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    username: json['username'] as String? ?? '',
    confirmed: json['confirmed'] == true,
    role: json['role'] as String? ?? 'participant',
    avatarUrl: json['avatarUrl'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    country: json['country'] as String?,
    isPro: json['isPro'] == true,
  );
}
```

### Paso 2.2: Actualizar modelo JoinedExchange ✅ COMPLETADO

**Archivo:** `lib/models/joined_exchange.dart`

Añadir campos a `JoinedExchange`:
```dart
final String? nativeLanguage;
final String? targetLanguage;
final List<String> platforms;
```

Actualizar el constructor:
```dart
const JoinedExchange({
  // ... campos existentes ...
  this.nativeLanguage,
  this.targetLanguage,
  this.platforms = const [],
});
```

Actualizar `fromJson`:
```dart
nativeLanguage: json['nativeLanguage'] as String?,
targetLanguage: json['targetLanguage'] as String?,
platforms: (json['platforms'] as List<dynamic>?)
    ?.map((e) => e.toString())
    .toList() ?? [],
```

### Paso 2.3: Rediseñar JoinedExchangeCard ✅ COMPLETADO

**Archivo:** `lib/widgets/exchange/joined_exchange_card.dart`

#### Estructura visual del nuevo diseño:

```
┌─────────────────────────────────────────────┐
│                                         [X] │  <- Botón abandonar (si aplica)
│  ┌──────┐                                   │
│  │ FOTO │  Nombre Usuario  [PRO]    ★ 4.9  │
│  │      │  País                             │
│  └──────┘                                   │
│                                             │
│  📅 Fecha y hora                            │
│     Hoy • 16:30                             │
│                                             │
│  🖥️ Plataforma                              │
│     Zoom, Google Meet                       │
│                                             │
│  🌐 Idioma y duración                       │
│     Español - Inglés • 60 min               │
│                                             │
│  📝 Tema                                    │
│     Business English - Presentaciones       │
│                                             │
└─────────────────────────────────────────────┘
   ◀ Anterior    • • •        Siguiente ▶     <- Ya implementado en home_screen.dart
```

#### Componentes a implementar:

**3.3.1 Header con avatar y datos del participante**

Obtener el participante principal a mostrar (el "otro" usuario, no el usuario actual):
```dart
// Obtener el otro participante (no el usuario actual)
JoinedExchangeParticipant? getOtherParticipant() {
  // Lógica para obtener el participante que NO es el usuario actual
  // Puede usar CurrentUserService para comparar IDs
}
```

Estructura del header:
- `CircleAvatar` de 48-56px con imagen de `avatarUrl` o iniciales como fallback
- Nombre del usuario
- Badge PRO (si `isPro == true`): Container con fondo accent, texto "PRO" blanco
- Rating con icono de estrella amarilla (★) y valor (ej: "4.9")
- País del usuario debajo del nombre

**3.3.2 Filas de información con nuevo estilo**

Cada fila debe tener:
- Icono dentro de contenedor circular con fondo `AppTheme.accent.withOpacity(0.15)`
- Layout vertical: label arriba en gris (subtle), valor abajo en blanco (text) con fontWeight

**Filas a mostrar:**

1. **Fecha y hora**
   - Icono: `Icons.calendar_today_outlined`
   - Label: "Fecha y hora"
   - Valor: Formato "Hoy • 16:30" o "Lun 24 Feb • 16:30"

2. **Plataforma**
   - Icono: `Icons.videocam_outlined` o `Icons.laptop_outlined`
   - Label: "Plataforma"
   - Valor: `exchange.platforms.join(', ')` o "No especificada" si está vacío

3. **Idioma y duración**
   - Icono: `Icons.language_outlined` o `Icons.translate_outlined`
   - Label: "Idioma y duración"
   - Valor: `"${exchange.nativeLanguage} - ${exchange.targetLanguage} • ${exchange.durationMinutes} min"`

4. **Tema**
   - Icono: `Icons.topic_outlined` o `Icons.description_outlined`
   - Label: "Tema"
   - Valor: `exchange.title ?? 'Sin tema'`

**3.3.3 Mantener funcionalidad existente**
- Botón "Abrir chat" (si aplica)
- Botón "Confirmar intercambio" (si `canConfirm`)
- Badge "Nuevos" mensajes
- Botón abandonar (X) en esquina superior derecha

### Paso 2.4: Crear widget reutilizable _NewInfoRow ✅ COMPLETADO (incluido en Paso 2.3)

Reemplazar el widget `_InfoRow` actual con uno que tenga el nuevo estilo:

```dart
class _NewInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono con fondo circular
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        // Textos verticales
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Paso 2.5: Crear widget _ProBadge ✅ COMPLETADO (incluido en Paso 2.3)

```dart
class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### Paso 2.6: Ajustar altura del carrusel ✅ COMPLETADO

**Archivo:** `lib/screens/home_screen.dart`

En `_ExchangesCarousel`, ajustar la altura del `SizedBox` si es necesario para acomodar el nuevo diseño (actualmente es 320):
```dart
SizedBox(
  height: 380, // Ajustar según necesidad
  child: PageView.builder(...),
),
```

---

## PARTE 3: TESTING

1. **Backend**: Verificar que el endpoint `GET /api/exchanges/joined` devuelve los nuevos campos correctamente
2. **Flutter**: Verificar que el modelo parsea correctamente los nuevos campos
3. **UI**: Verificar que la tarjeta se renderiza correctamente en todos los estados:
   - SCHEDULED
   - ENDED_PENDING_CONFIRMATION (con botón confirmar)
   - Con mensajes nuevos
   - Sin participantes (edge case)
4. **Carrusel**: Verificar que funciona correctamente con el nuevo tamaño
5. **Responsividad**: Probar en diferentes tamaños de pantalla

---

## Resumen de archivos a modificar

### Backend (Java):
1. `dto/ExchangeParticipantDTO.java` - Añadir 4 campos
2. `dto/ExchangeResponseDTO.java` - Añadir 3 campos
3. `service/ExchangeService.java` - Actualizar método `toResponseDTO()`

### Frontend (Flutter):
1. `lib/models/joined_exchange.dart` - Actualizar ambos modelos
2. `lib/widgets/exchange/joined_exchange_card.dart` - Rediseñar completamente
3. `lib/screens/home_screen.dart` - Ajustar altura del carrusel si necesario

---

## Orden de implementación recomendado

1. ✅ **Primero Backend**: Actualizar DTOs y ExchangeService
2. ✅ **Probar Backend**: Verificar respuesta del endpoint con los nuevos campos
3. ✅ **Después Frontend**: Actualizar modelos Flutter
4. ✅ **Finalmente UI**: Rediseñar JoinedExchangeCard
