# Pruebas y evidencias

## Entorno verificado

- PostgreSQL 17.11 local, base `mantenimiento_vehiculos` en `127.0.0.1:5433`.
- PHP 8.5.12 NTS con `pdo_pgsql`, `pgsql`, `mbstring` y `openssl` habilitados para el proyecto.
- Laravel 13.39.0 y Composer 2.8.12.

## Comandos ejecutados y resultado

- `php artisan migrate --force`: 7 migraciones ejecutadas correctamente.
- `php artisan db:seed --class=Edt31DemoSeeder --force`: seeder ficticio ejecutado correctamente.
- `php artisan migrate:status`: las 7 migraciones figuran como `Ran` en el lote 1.
- `php artisan test`: 5 pruebas exitosas y 10 aserciones.

Las pruebas `PostgresPersistenceTest` y `PostgresForeignKeyTest` insertan datos ficticios, comprueban recuperación mediante relaciones Eloquent, y verifican restricciones de unicidad y claves foráneas sobre PostgreSQL real.

## Seguridad local

La credencial y la clave de aplicación sólo existen en `web/.env`, archivo ignorado por Git. No hay contraseñas en migraciones, modelos, documentación ni commits.