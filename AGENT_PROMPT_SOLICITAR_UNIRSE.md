# Prompt para Agente: Implementar "Solicitar unirse" en intercambios públicos

Este documento define el plan paso a paso para implementar la funcionalidad de solicitud de unión a intercambios públicos cuando el usuario **no cumple los requisitos de nivel** (NO ELEGIBLE). El botón "Solicitar unirse" debe crear una solicitud que el creador del intercambio puede aceptar o rechazar desde la campana de notificaciones.

---

## Resumen del flujo

1. Usuario no elegible pulsa "Solicitar unirse" → se crea una solicitud y el creador recibe notificación en la campana.
2. El creador abre la notificación → ve la solicitud con opciones Aceptar / Rechazar.
3. Si acepta → el usuario pasa a ser participante aunque no cumpla nivel.
4. Si rechaza → la solicitud queda rechazada (opcional: notificar al solicitante).

---

## PASO 1: Backend - Entidad y base de datos

**Objetivo:** Crear la entidad `ExchangeJoinRequest` y la tabla correspondiente.

- [x] Crear entidad JPA `ExchangeJoinRequest` en `models/`:
  - `id` (Long, PK, auto)
  - `exchange` (Exchange, ManyToOne)
  - `user` (User, ManyToOne)
  - `status` (String o Enum: PENDING, ACCEPTED, REJECTED)
  - `createdAt` (LocalDateTime)
  - `respondedAt` (LocalDateTime, nullable)
  - `respondedBy` (User, ManyToOne, nullable)
- [x] Crear script Flyway/Liquibase `V1.5__exchange_join_requests.sql`:
  - Tabla `exchange_join_requests` con las columnas equivalentes.
  - Índice único `(exchange_id, user_id)` donde status = 'PENDING' (o constraint que evite duplicados pendientes).
- [x] Crear `ExchangeJoinRequestRepository` con métodos:
  - `findByExchangeAndUserAndStatus`
  - `findByExchangeIdAndStatus`
  - `existsByExchangeAndUserAndStatus`

**Validación:** La aplicación arranca sin errores y la tabla existe en la BD.

---

## PASO 2: Backend - Extender modelo de Notificaciones

**Objetivo:** Añadir soporte para notificaciones de tipo solicitud de unión.

- [x] Añadir constante `TYPE_EXCHANGE_JOIN_REQUEST = "EXCHANGE_JOIN_REQUEST"` en `Notification.java`.
- [x] Añadir columna `requester_user_id` (nullable, FK a users) en la tabla `notifications`.
- [x] Crear script de migración `V1.6__notification_requester_user.sql` (o incluir en el anterior según convención).
- [x] Actualizar entidad `Notification` con campo `requesterUserId` (Long) o `requester` (User, ManyToOne).
- [x] Actualizar `NotificationResponseDTO` con campo `requesterUserId` (Long, opcional).
- [x] Actualizar `NotificationService.toDto` para mapear el nuevo campo.

**Validación:** Las notificaciones existentes siguen funcionando; el DTO puede incluir `requesterUserId`.

---

## PASO 3: Backend - Lógica de negocio y endpoints de solicitud

**Objetivo:** Implementar crear solicitud y listar solicitudes pendientes.

- [x] En `ExchangeService` (o crear `ExchangeJoinRequestService`):
  - Método `requestToJoin(exchangeId, userId)`:
    - Validar: intercambio público, SCHEDULED, no es participante, hay plazas.
    - Validar: no existe solicitud PENDING del mismo usuario.
    - (Opcional) Validar en backend que el usuario NO es elegible (réplica de `computeEligibility`).
    - Crear `ExchangeJoinRequest` con status PENDING.
    - Crear `Notification` tipo `EXCHANGE_JOIN_REQUEST` para el creador con `exchangeId` y `requesterUserId`.
- [x] En `ExchangeController`:
  - `POST /api/exchanges/{id}/join-request` → llama a `requestToJoin`.
- [x] En `ExchangeController` o en un controlador dedicado:
  - `GET /api/exchanges/{id}/join-requests` → lista solicitudes PENDING del intercambio (solo creador).
  - DTO de respuesta: `id`, `userId`, `username`, `createdAt`, `unmetRequirements` (opcional).

**Validación:** POST con usuario no elegible crea la solicitud y la notificación; GET devuelve las pendientes.

---

## PASO 4: Backend - Endpoints aceptar y rechazar

**Objetivo:** Permitir al creador aceptar o rechazar solicitudes.

- [x] En `ExchangeService` (o `ExchangeJoinRequestService`):
  - Método `acceptJoinRequest(exchangeId, requestId, creatorUserId)`:
    - Validar que el usuario es el creador del intercambio.
    - Validar que la solicitud existe y está PENDING.
    - Validar que aún hay plazas.
    - Crear `ExchangeParticipant` (participant).
    - Actualizar solicitud a ACCEPTED, `respondedAt`, `respondedBy`.
    - (Opcional) Crear notificación al solicitante: "Tu solicitud ha sido aceptada".
  - Método `rejectJoinRequest(exchangeId, requestId, creatorUserId)`:
    - Mismas validaciones de creador y PENDING.
    - Actualizar a REJECTED, `respondedAt`, `respondedBy`.
- [x] Endpoints:
  - `POST /api/exchanges/{id}/join-requests/{requestId}/accept`
  - `POST /api/exchanges/{id}/join-requests/{requestId}/reject`

**Validación:** Aceptar añade al participante; rechazar deja la solicitud rechazada.

---

## PASO 5: Frontend - Endpoints y repositorio

**Objetivo:** Conectar Flutter con los nuevos endpoints.

- [x] En `api_endpoints.dart` añadir:
  - `exchangeJoinRequest(String id)` → POST `/api/exchanges/{id}/join-request`
  - `exchangeJoinRequests(String id)` → GET `/api/exchanges/{id}/join-requests`
  - `exchangeJoinRequestAccept(String exchangeId, String requestId)`
  - `exchangeJoinRequestReject(String exchangeId, String requestId)`
- [x] En `ApiPublicExchangesRepository` (o crear `ApiExchangeJoinRequestRepository`):
  - `Future<void> requestToJoin(String exchangeId)`
  - `Future<List<JoinRequest>> getJoinRequests(String exchangeId)`
  - `Future<void> acceptJoinRequest(String exchangeId, String requestId)`
  - `Future<void> rejectJoinRequest(String exchangeId, String requestId)`
- [x] Crear modelo `JoinRequest` (id, userId, username, createdAt, etc.) si hace falta.

**Validación:** Las llamadas HTTP a los endpoints funcionan desde Flutter (puedes probar con botones temporales).

---

## PASO 6: Frontend - Botón "Solicitar unirse"

**Objetivo:** Hacer que el botón "Solicitar unirse" llame al backend en lugar de mostrar solo un SnackBar.

- [x] En `PublicExchangesScreen._onJoin`:
  - Si `!exchange.isEligible`: llamar a `_repository.requestToJoin(exchange.id)`.
  - Mostrar SnackBar de éxito: "Solicitud enviada. El creador te notificará si la acepta."
  - Manejar errores (ej. "Ya has enviado una solicitud").
  - Recargar la lista si procede (o actualizar estado local para mostrar "Solicitud enviada").
- [x] (Opcional) Estado en la tarjeta: si el usuario ya tiene solicitud PENDING, mostrar "Solicitud enviada" y deshabilitar el botón. Requiere que el backend devuelva esta información en `PublicExchangeResponseDTO` o en un endpoint aparte.

**Validación:** Usuario no elegible puede enviar solicitud y ve mensaje de confirmación.

---

## PASO 7: Frontend - Modelo y manejo de notificaciones de solicitud

**Objetivo:** Reconocer y mostrar las notificaciones de tipo solicitud de unión.

- [x] En `NotificationModel`:
  - Añadir getter `isJoinRequest => type == 'EXCHANGE_JOIN_REQUEST'`.
  - Añadir campo `requesterUserId` (int?) y mapearlo desde `fromJson` (ej. `requesterUserId` o `requester_user_id`).
- [x] Actualizar `ApiNotificationsRepository` / parsing si el backend devuelve el nuevo campo.

**Validación:** Las notificaciones de tipo `EXCHANGE_JOIN_REQUEST` se reconocen correctamente en el modelo.

---

## PASO 8: Frontend - Pantalla/diálogo para aceptar o rechazar

**Objetivo:** Permitir al creador gestionar la solicitud desde la notificación.

- [x] Definir flujo al pulsar notificación `EXCHANGE_JOIN_REQUEST`:
  - Navegar a una pantalla o mostrar diálogo/bottom sheet con la solicitud.
- [x] Crear pantalla o diálogo que muestre:
  - Nombre del solicitante (y perfil si está disponible).
  - Intercambio al que aplica.
  - Botones "Aceptar" y "Rechazar".
- [x] Implementar llamadas a `acceptJoinRequest` y `rejectJoinRequest`.
- [x] Tras aceptar/rechazar: recargar notificaciones, volver atrás o mostrar confirmación.

**Validación:** El creador puede aceptar o rechazar desde la notificación.

---

## PASO 9: Frontend - Integrar notificación con la pantalla de solicitudes

**Objetivo:** Conectar la campana con la acción de aceptar/rechazar.

- [x] En `NotificationsScreen._onNotificationTap`:
  - Si `notification.isJoinRequest` y tiene `exchangeId` y `requesterUserId` (o `requestId` si lo usas):
    - Navegar a la pantalla/diálogo de solicitudes del intercambio, o mostrar un diálogo con la solicitud específica.
  - Si la lista de solicitudes viene de `GET /join-requests`, cargarla al abrir.
- [x] Asegurar que al marcar la notificación como leída y al aceptar/rechazar se actualiza el contador de no leídas (`UnreadNotificationsService`).

**Validación:** Al pulsar la notificación en la campana se abre la interfaz para aceptar o rechazar.

---

## PASO 10: Refinamientos y pruebas

**Objetivo:** Cubrir casos límite y mejorar UX.

- [x] Evitar solicitudes duplicadas: backend rechaza si ya existe PENDING.
- [x] Intercambio lleno: al aceptar, validar que sigue habiendo plazas.
- [x] Mensajes de error claros: "Ya has enviado una solicitud", "El intercambio está completo", etc.
- [x] (Opcional) Notificación al solicitante cuando es aceptado o rechazado.
- [ ] Pruebas manuales del flujo completo: solicitar → notificación → aceptar/rechazar.

---

## Instrucciones para el agente

- Avanzar **un paso a la vez** según indique el usuario.
- Al completar un paso, marcar los checkboxes y confirmar la validación.
- No saltar pasos sin que el usuario lo indique.
- Si un paso requiere decisiones de diseño no especificadas, preguntar antes de implementar.