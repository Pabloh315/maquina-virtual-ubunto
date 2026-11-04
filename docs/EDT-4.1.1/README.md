# EDT 4.1.1 — Autenticación y control de acceso

Implementa CU-01/HU-01 con Laravel 13, PostgreSQL y Laravel Sanctum. Reutiliza `users`, `roles`, `permissions`, `role_user` y `permission_role` de EDT 3.1.

## Componentes

- `POST /api/login`, `GET /api/me`, `POST /api/logout`.
- Tokens personales de Sanctum, revocables al cerrar sesión.
- Middleware `auth:sanctum` y `permission`.
- Permisos iniciales: `vehicles.view`, `vehicles.create`.
- Vehículos ahora requieren token y permiso.

Ejecutar migraciones locales: `php artisan migrate`; datos demo: `php artisan db:seed`.

La verificación funcional aislada se ejecuta con `php vendor/bin/phpunit --configuration phpunit.auth.xml`. La configuración normal mantiene PostgreSQL en `phpunit.xml`.
