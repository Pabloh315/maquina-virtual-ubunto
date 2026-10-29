# Arquitectura de la API

## Flujo

```text
Cliente web / Flutter futuro
        │ HTTP + JSON
        ▼
routes/api.php → throttle:api → Controller → Form Request
                                      │             │
                                      │             └─ validación y normalización
                                      ▼
                               Eloquent + Resources
                                      │
                                      ▼
                               PostgreSQL 17
```

## Capas implementadas

- `routes/api.php`: contrato público, prefijo `v1`, nombres de ruta y limitación de 60 solicitudes por minuto por usuario o IP.
- `HealthController`: estado de proceso sin consultar la base.
- `DatabaseHealthController`: ejecuta `select 1`, devuelve 503 genérico ante fallos y nunca expone credenciales.
- `VehicleController`: listado paginado, creación validada y consulta por route model binding.
- `StoreVehicleRequest`: reglas, mensajes en español y normalización a mayúsculas de placa y VIN.
- `VehicleResource`: forma estable de salida, relaciones cargadas y exclusión de datos personales del propietario.
- Modelos y factories: `HasFactory` y relaciones reutilizadas desde la EDT 3.1.

## Decisiones

- La versión se expresa en la URL (`/api/v1`) para poder evolucionar el contrato sin romper clientes.
- El listado usa 15 elementos por página y orden estable por fecha descendente e ID descendente.
- Las relaciones `category` y `model.make` se cargan anticipadamente para evitar consultas N+1.
- Los errores de validación y excepciones de rutas API se devuelven como JSON.
- `/api/database` no se registra en producción.
- La API actual no autentica: es una base técnica del hito, no un cierre de seguridad de negocio.

## Seguridad incorporada

- No se serializan nombre, correo ni contraseña del propietario.
- VIN de 17 caracteres, excluyendo I, O y Q; placa y VIN únicos.
- IDs foráneos deben existir; año y kilometraje se acotan.
- Configuración sensible permanece en `.env` y `.env.testing`, ambos ignorados.
- Auditorías de dependencias y pruebas de error 503 forman parte de la verificación.
