# Endpoints

Base local: `http://127.0.0.1:8000/api`<br>
Emulador Android: `http://10.0.2.2:8000/api`

Todos los endpoints responden JSON y usan el limitador `throttle:api`.

| Método | Ruta | Resultado | Códigos principales |
|---|---|---|---|
| GET | `/health` | Estado del servicio | 200 |
| GET | `/database` | Conectividad PostgreSQL; solo local/testing | 200, 503 |
| GET | `/v1/vehicles` | Colección paginada | 200 |
| POST | `/v1/vehicles` | Crea un vehículo | 201, 422 |
| GET | `/v1/vehicles/{id}` | Vehículo por ID | 200, 404 |

## Salud

```json
{
  "status": "ok",
  "service": "mantenimiento-vehiculos-api"
}
```

La respuesta de base disponible es:

```json
{
  "status": "ok",
  "database": "reachable",
  "driver": "pgsql"
}
```

Ante una indisponibilidad se responde HTTP 503 con `{"status":"error","database":"unavailable"}` y el detalle se registra solo en el log del servidor.

## Crear vehículo

Ejemplo de cuerpo; los tres IDs deben existir:

```json
{
  "owner_id": 1,
  "vehicle_category_id": 1,
  "vehicle_model_id": 1,
  "license_plate": "ABC-1234",
  "vin": "1HGCM82633A004352",
  "year": 2024,
  "color": "Azul",
  "fuel_type": "gasolina",
  "current_mileage": 12500,
  "is_active": true
}
```

Obligatorios: `owner_id`, `vehicle_category_id`, `vehicle_model_id`, `license_plate` y `year`. El VIN es opcional, pero si existe debe ser válido y único. `current_mileage` no admite negativos. La placa y el VIN se almacenan en mayúsculas.

## Recurso de salida

El recurso incluye ID, `owner_id`, placa, VIN, año, color, combustible, kilometraje, estado, categoría, modelo, marca y fechas ISO 8601. No devuelve atributos personales del propietario. Los listados añaden `links` y `meta` de paginación.

## Estado del contrato

Este contrato es provisional porque el repositorio no contiene el entregable o especificación aprobada de la EDT 2.4. Antes de integrar Flutter se debe comparar nombres, autenticación, paginación y errores con ese contrato oficial.
