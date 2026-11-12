# EDT 4.3.1 — Antecedentes y planes de mantenimiento

## Datos y relaciones

`vehicles` tiene antecedentes (`maintenance_histories`) y planes (`maintenance_plans`). Cada plan conserva su fuente y referencia; sus servicios viven en `maintenance_plan_services` y exigen al menos un intervalo: kilómetros o meses. Los antecedentes permiten `performed_on` y `mileage` nulos para representar información histórica desconocida sin valores ficticios.

## API autenticada

- `GET/POST /api/v1/vehicles/{vehicle}/maintenance-histories`
- `GET /api/v1/vehicles/{vehicle}/maintenance-histories/{maintenanceHistory}`
- `GET/POST /api/v1/vehicles/{vehicle}/maintenance-plans`
- `GET /api/v1/vehicles/{vehicle}/maintenance-plans/{maintenancePlan}`

Las consultas requieren `vehicles.view` y los registros `vehicles.create`, coherentes con los permisos existentes.

## Cálculo

`MaintenanceDueCalculator` devuelve el próximo kilometraje y/o fecha solo si existen los datos históricos necesarios. Un servicio combinado vence con `vencido_por_kilometraje OR vencido_por_tiempo`; no necesita alcanzar ambos límites. Si falta el último kilometraje o fecha, el criterio informa `informacion_historica_insuficiente`.

## Pruebas

La prueba unitaria cubre los cálculos por kilómetros y tiempo, el vencimiento por cualquiera de ambos límites y el manejo de antecedentes incompletos. Las validaciones HTTP permiten antecedentes sin fecha o kilometraje y exigen un intervalo positivo para cada servicio del plan.