# Estrategia: Creación de intercambios públicos (Plan paso 5.1)

## Decisión: Ampliar `CreateExchangeScreen`

Se ha elegido **ampliar la pantalla existente** `CreateExchangeScreen` en lugar de crear una nueva `CreatePublicExchangeScreen`.

### Razones

1. **Formulario ya completo**: `CreateExchangeScreen` ya incluye todos los campos necesarios para intercambios públicos:
   - título, descripción
   - idioma ofrecido, idioma buscado
   - nivel requerido
   - fecha, hora, duración
   - máximo de participantes, temas (opcional)
   - isPublic (público/privado)

2. **Reutilización**: Evita duplicar UI y lógica de validación.

3. **Un solo punto de entrada**: La ruta `AppRoutes.createExchange` es usada desde `PublicExchangesScreen` ("Crear intercambio"). No hay otro flujo que requiera un formulario distinto.

### Implementación (pasos 5.2 y 5.3)

- Sustituir la llamada a `ApiExchangeRepository.create()` por `ApiPublicExchangesRepository.createExchange()`.
- Mapear los valores del formulario a los parámetros requeridos.
- Los códigos de idioma (`_nativeLanguageCode`, `_targetLanguageCode`) se convertirán a nombres con `AppLanguages.getName()` para el DTO de creación pública.

### Alternativa descartada

Crear `CreatePublicExchangeScreen` separada: innecesaria porque el formulario actual ya cubre el caso de uso.
