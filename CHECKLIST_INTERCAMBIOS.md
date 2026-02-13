# Checklist: Flujo de Intercambios con Confirmación (tipo Playtomic)

## ✅ IMPLEMENTADO

### Paso 1: Campo completed_exchanges
- [x] **Backend** User: campo `completed_exchanges` (INT)
- [x] **Backend** UserSummaryDTO / UserProfileDTO: exponen `exchanges` desde completedExchanges
- [x] **Frontend** ApiFindUsersRepository: lee `exchanges` del JSON

### Paso 2: Entidades Exchange y ExchangeParticipant
- [x] **Backend** ExchangeStatus enum (SCHEDULED, ENDED_PENDING_CONFIRMATION, COMPLETED, CANCELLED)
- [x] **Backend** Exchange entity (scheduledAt, durationMinutes, status, type, title)
- [x] **Backend** ExchangeParticipant entity (exchange, user, confirmed, confirmedAt, role)
- [x] **Backend** ExchangeRepository
- [x] **Backend** ExchangeParticipantRepository

### Paso 3: Servicios, controlador y job
- [x] **Backend** ExchangeService: create, getJoinedExchanges, getById, confirm, processEndedExchanges
- [x] **Backend** ExchangeController: POST /api/exchanges, GET /api/exchanges/joined, GET /api/exchanges/{id}, POST /api/exchanges/{id}/confirm
- [x] **Backend** ExchangeScheduler: job cada 5 min para pasar SCHEDULED → ENDED_PENDING_CONFIRMATION
- [x] **Backend** DTOs: CreateExchangeRequestDTO, ExchangeResponseDTO, ExchangeParticipantDTO

---

## ✅ Paso 4 (parcial – UI conectada)

### Flutter UI – Repositorio y modelo
- [x] **Frontend** Modelo JoinedExchange (mapea ExchangeResponseDTO)
- [x] **Frontend** ApiUserExchangesRepository: GET /api/exchanges/joined
- [x] **Frontend** ApiExchangeRepository: POST create, GET by id, POST confirm
- [x] **Frontend** Endpoints en api_endpoints.dart para /api/exchanges

### Flutter UI – Pantalla Home
- [x] **Frontend** Sustituir FakeUserExchangesRepository por ApiUserExchangesRepository
- [x] **Frontend** _JoinedExchangeCard con título, fecha/hora, duración, estado, participantes
- [x] **Frontend** Botón "Confirmar intercambio" cuando canConfirm == true

### Flutter UI – Crear intercambio
- [x] **Frontend** CreateExchangeScreen conectado a POST /api/exchanges

### Backend – Stub de notificaciones
- [x] **Backend** TODO en processEndedExchanges para futuro envío de notificaciones push

---

## ❌ PENDIENTE

### Notificaciones push
- [ ] **Backend** Campo `fcm_token` en User para almacenar token FCM
- [ ] **Backend** Endpoint para registrar FCM token
- [ ] **Backend** Integración Firebase Admin SDK para enviar pushes
- [ ] **Frontend** firebase_messaging
- [ ] **Frontend** Obtener y registrar FCM token
- [ ] **Frontend** Manejar notificaciones y navegar a confirmación

### Notificaciones in-app (Opción A)
- [x] **Frontend** Banner en Home cuando hay intercambios con canConfirm
- [x] **Frontend** Botón "Ver" que hace scroll a la sección de intercambios

### Opcional
- [ ] **Frontend** Pantalla de detalle de intercambio (GET /api/exchanges/{id})

---

## NOTAS

- **PublicExchange vs Exchange**: El modelo PublicExchange (catálogo de intercambios públicos con creatorId, maxParticipants, etc.) es distinto del Exchange que implementamos (sesiones programadas con confirmación). El home actual usa PublicExchange; al conectar con GET /api/exchanges/joined usaremos JoinedExchange.
- **Notificaciones**: Push requiere Firebase/FCM. Alternativa más simple: notificaciones in-app (banner o badge cuando hay intercambios pendientes de confirmar).
