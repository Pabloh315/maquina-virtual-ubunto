# EDT 3.1 â€” Base tÃ©cnica integrada

## Objetivo

Establecer la persistencia inicial del Sistema de GestiÃ³n de Mantenimiento de VehÃ­culos: Laravel, migraciones, modelos Eloquent y configuraciÃ³n local para PostgreSQL. No incluye API, interfaces web ni Flutter.

## Requisitos locales

- PHP 8.3 o superior y Composer.
- PostgreSQL con la extensiÃ³n `pdo_pgsql` habilitada en PHP.
- Base local `mantenimiento_vehiculos` y un usuario local con permisos sobre ella.

## ConfiguraciÃ³n

1. Copiar `web/.env.pgsql.example` a `web/.env` o trasladar sus variables a ese archivo.
2. Completar Ãºnicamente en el archivo local ignorado por Git `DB_USERNAME` y `DB_PASSWORD`.
3. Desde `web/`, ejecutar `php artisan key:generate`, `php artisan migrate --seed` y `php artisan migrate:status`.

No se almacenan credenciales en el repositorio. El seeder `Edt31DemoSeeder` contiene sÃ³lo catÃ¡logo ficticio.

## Estado de validaciÃ³n local

El entorno detectado al implementar esta EDT no tenÃ­a PostgreSQL, `psql` ni `pdo_pgsql`; por ello no se ejecutaron migraciones ni pruebas de persistencia contra una base real. La validaciÃ³n de sintaxis y de relaciones de modelos sÃ­ puede ejecutarse sin ese servicio. Consulte `pruebas.md`.
