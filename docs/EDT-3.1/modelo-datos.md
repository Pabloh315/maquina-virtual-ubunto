# Modelo de datos inicial

## Áreas y entidades

- Identidad: `users`, `roles`, `permissions`, `role_user`, `permission_role`.
- Vehículos: `vehicle_categories`, `makes`, `vehicle_models`, `vehicles`, `mileage_readings`.
- Mantenimiento: `service_catalogs`, `maintenance_plans`, `maintenance_plan_services`, `alerts`.
- Talleres y citas: `workshops`, `workshop_specialties`, `workshop_services`, `workshop_brand_authorizations`, `workshop_hours`, `appointments`.
- Operación: `service_orders`, `inspections`, `inspection_items`, `inspection_results`, `service_jobs`, `maintenance_histories`.

## Integridad

Las claves foráneas usan `restrict` cuando la entidad es histórica o de referencia; los detalles dependientes usan `cascade`; referencias opcionales usan `set null`. Hay claves únicas para placa, VIN, catálogos, asignaciones de roles/permisos, servicio-plan, autorización de marca y resultados de inspección.

La autorización oficial de una marca es explícita mediante `is_officially_authorized`; ofrecer servicio a una marca no concede esa condición. Los cupos se controlan con `appointment_capacity` y la consulta de citas activas por taller y horario, que deberá aplicar la EDT de reglas/endpoints.

## Decisiones por validar

No se encontró DER, requisitos ni casos de uso del M01 en el repositorio vacío. Este esquema es una propuesta inicial basada en el alcance recibido; deben validarse estados permitidos, política de cupos solapados y el catálogo definitivo de roles/permisos.
