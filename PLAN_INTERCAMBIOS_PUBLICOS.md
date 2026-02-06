# Plan de Implementación: Intercambios Públicos

Plan paso a paso para implementar la funcionalidad completa de la ventana **Intercambios Públicos**: listado, filtrado, unirse/abandonar y crear intercambios.

**Regla:** No avanzar al siguiente paso hasta confirmar que el actual está completado y probado.

---

## Fase 1: Backend – Modelo y creación

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **1.1** | Extender el modelo `Exchange` en el backend con: `isPublic`, `maxParticipants`, `description`, `nativeLanguageCode`, `targetLanguageCode`, `requiredLevel` | El modelo compila, la migración se aplica sin errores y los campos persisten correctamente |
| **1.2** | Extender `CreateExchangeRequestDTO` con los campos opcionales anteriores | El DTO acepta y valida los nuevos campos correctamente |
| **1.3** | Actualizar `ExchangeService.create()` para persistir estos campos cuando se envíen | Un intercambio creado con estos datos vía `POST /api/exchanges` se guarda correctamente en BD |
| **1.4** | Crear migración / actualizar esquema de base de datos si es necesario | La BD tiene las columnas correctas y la app arranca sin errores |

**Pausa:** Probar manualmente que `POST /api/exchanges` crea intercambios con todos los campos.

---

## Fase 2: Backend – Endpoints públicos

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **2.1** | Crear `PublicExchangeResponseDTO` (o extender `ExchangeResponseDTO`) con: `creatorId`, `creatorName`, `creatorAvatarUrl`, `creatorIsPro`, `currentParticipants`, `isEligible`, `unmetRequirements` | DTO listo para el listado público |
| **2.2** | Implementar `GET /api/exchanges/public` con query params: `q`, `page`, `pageSize`, `requiredLevel`, `minDate`, `maxDuration`, `nativeLang`, `targetLang` | El endpoint devuelve la lista filtrada y paginada de intercambios públicos |
| **2.3** | Implementar `POST /api/exchanges/{id}/join` | El usuario actual se une al intercambio; respetar `maxParticipants` |
| **2.4** | Implementar `DELETE /api/exchanges/{id}/leave` | El usuario actual se elimina como participante (no el creador) |

**Pausa:** Probar los 3 endpoints con Postman/curl o tests.

---

## Fase 3: Frontend – Repositorio API

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **3.1** | Implementar `PublicExchange.fromJson(Map<String, dynamic>)` en el modelo | Parsea correctamente la respuesta del backend |
| **3.2** | Añadir `joinExchange(id)` y `leaveExchange(id)` a la interfaz `PublicExchangesRepository` | La interfaz define estos métodos |
| **3.3** | Crear `ApiPublicExchangesRepository` con `searchExchanges` conectado a `GET /api/exchanges/public` | Obtener lista real desde el backend funciona |
| **3.4** | Implementar `joinExchange` y `leaveExchange` en `ApiPublicExchangesRepository` | Las llamadas a join/leave responden correctamente |
| **3.5** | Implementar `createExchange` en `ApiPublicExchangesRepository` (o reutilizar/extender el flujo actual de creación) | Crear intercambio público desde la app funciona contra el backend |

**Pausa:** Verificar que `ApiPublicExchangesRepository` cubre todo lo necesario para la pantalla.

---

## Fase 4: Frontend – Pantalla de Intercambios Públicos

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **4.1** | Sustituir `FakePublicExchangesRepository` por `ApiPublicExchangesRepository` en `PublicExchangesScreen` | La pantalla muestra intercambios reales del backend |
| **4.2** | Conectar `_onJoin` a `repository.joinExchange()` y recargar la lista tras unirse | El usuario se une de forma persistente y la UI se actualiza |
| **4.3** | Conectar `_onLeave` a `repository.leaveExchange()` y recargar la lista tras abandonar | El usuario abandona de forma persistente y la UI se actualiza |
| **4.4** | Eliminar o simplificar `_joinedExchangeIds` y `_additionalParticipants` (el estado real viene del backend) | La UI refleja correctamente el estado del backend sin estado local redundante |

**Pausa:** Probar crear intercambios, unirse, abandonar y filtros en la pantalla.

---

## Fase 5: Frontend – Creación de intercambios públicos

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **5.1** | Decidir estrategia: ampliar `CreateExchangeScreen` con modo "público" o crear `CreatePublicExchangeScreen` | Estrategia clara y documentada en código |
| **5.2** | Implementar el flujo de creación pública con: `description`, `nativeLanguage`, `targetLanguage`, `requiredLevel`, `maxParticipants`, `topics`, `isPublic` | El formulario envía todos los datos necesarios |
| **5.3** | Conectar el botón "Crear intercambio" en `PublicExchangesScreen` a este flujo y recargar la lista tras crear | Al crear un intercambio público, aparece correctamente en el listado |

**Pausa:** Crear intercambios públicos desde la app y comprobar que se ven en la lista.

---

## Fase 6: Limpieza

| Paso | Tarea | Criterio de completado |
|------|-------|------------------------|
| **6.1** | Eliminar `FakePublicExchangesRepository` si ya no se usa | No quedan referencias al fake |
| **6.2** | Revisar imports y linter | Sin errores ni warnings relevantes |

---

## Cómo usar este plan con el agente

1. Activar el **modo Agent** en Cursor.
2. Dar una instrucción como: *"Implementa el paso 1.1 del plan de Intercambios Públicos"*.
3. Tras cada paso, probar (manual o automático) y solo después pedir: *"Continúa con el paso 1.2"*.

---

## Estado actual (referencia)

| Funcionalidad | Estado | Depende de |
|---------------|--------|------------|
| Listar intercambios públicos | Solo mock | BE4, FE3.3, FE4.1 |
| Filtrar por idioma, nivel, fecha, duración | Solo mock | BE4 (query params), FE preparado |
| Buscar por texto | Solo mock | BE4 (param `q`), FE preparado |
| Unirse a intercambio | Solo estado local | BE5, FE3.2/3.4, FE4.2 |
| Abandonar intercambio | Solo estado local | BE6, FE3.2/3.4, FE4.3 |
| Crear intercambio público | No implementado | BE1-BE3, FE5.x |
