# EDT 3.1 — Base técnica integrada

## Objetivo

Establecer la persistencia inicial del Sistema de Gestión de Mantenimiento de Vehículos: Laravel, migraciones, modelos Eloquent y configuración local para PostgreSQL. No incluye API, interfaces web ni Flutter.

## Requisitos locales

- PHP 8.3 o superior y Composer.
- PostgreSQL con la extensión `pdo_pgsql` habilitada en PHP.
- Base local `mantenimiento_vehiculos` y un usuario local con permisos sobre ella.

## Configuración

1. Copiar `web/.env.pgsql.example` a `web/.env` o trasladar sus variables a ese archivo.
2. Completar únicamente en el archivo local ignorado por Git `DB_USERNAME` y `DB_PASSWORD`.
3. Desde `web/`, ejecutar `php artisan key:generate`, `php artisan migrate --seed` y `php artisan migrate:status`.

No se almacenan credenciales en el repositorio. El seeder `Edt31DemoSeeder` contiene sólo catálogo ficticio.

## Estado de validación local

El entorno detectado al implementar esta EDT no tenía PostgreSQL, `psql` ni `pdo_pgsql`; por ello no se ejecutaron migraciones ni pruebas de persistencia contra una base real. La validación de sintaxis y de relaciones de modelos sí puede ejecutarse sin ese servicio. Consulte `pruebas.md`.
