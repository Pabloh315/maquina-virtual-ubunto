# Informe EDT 4.1.1 — Autenticación y control de acceso

## Resumen y estado inicial

Se trabajó en `feature/4.1.1-autenticacion-control-acceso`, creada desde `origin/develop`. Laravel 13.17 ya tenía modelos, tablas y relaciones de usuarios/roles/permisos, PostgreSQL configurado y API de vehículos pública; no tenía Sanctum, login ni middleware de autorización.

## Implementación

Se añadió `laravel/sanctum`, `HasApiTokens`, la migración aditiva `personal_access_tokens`, `AuthController`, middleware `RequirePermission`, limitadores `api` y `login`, rutas protegidas y permisos demo. Los endpoints son `/api/login`, `/api/me`, `/api/logout` y `/api/access-check`; vehículos exigen permisos. Las contraseñas se verifican con hash, no se serializan, y login no revela si un correo existe.

## Base de datos y Flutter

Se reutilizan las tablas de EDT 3.1 más `personal_access_tokens`. Flutter debe usar Bearer token, consultar `/api/me` y revocarlo con `/api/logout`; la guía está en `docs/EDT-4.1.1/integracion-flutter.md`.

## Pruebas y seguridad

La batería aislada pasó 9 pruebas/30 aserciones y vehículos pasó 7/50. La ejecución PostgreSQL real no pudo iniciarse porque falta `pdo_pgsql`; se registró en `pruebas.md`. Hay 401, 403, 422 y 429, límite de login, token revocable y autorización centralizada.

## Criterios

| Criterio | Estado | Evidencia |
|---|---|---|
| Login, me y logout | Cumplido | AuthControllerTest |
| Roles/endpoints protegidos | Cumplido | middleware y pruebas |
| Hash, validación y límites | Cumplido | modelo, pruebas |
| PostgreSQL local ejecutado | Pendiente entorno | falta pdo_pgsql |
| Documentación y guía Flutter | Cumplido | docs/EDT-4.1.1 |
| Push, PR, revisión y merge | Pendiente | prohibidos por alcance |

## Git local

No hubo push, pull ni merge. La rama queda preparada para revisión de Julio Guzmán. Pendientes: habilitar PDO PostgreSQL, revisión del compañero, publicación de la rama, Pull Request, aprobación y merge a develop.
