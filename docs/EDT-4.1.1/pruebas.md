# Pruebas

## Ejecutadas

- `php vendor/bin/phpunit --configuration phpunit.auth.xml`: **9 pruebas, 30 aserciones, exitosas**. Cubre login válido, credenciales inválidas/no enumeración, hash, 401 sin o con token inválido, 403, permiso autorizado, logout/revocación, 422 y 429.
- Pruebas de vehículos protegidos: **7 pruebas, 50 aserciones, exitosas** con la misma configuración aislada.

## Limitación PostgreSQL

La ejecución con `php artisan test --filter=AuthControllerTest` fue intentada con la configuración normal PostgreSQL y falló antes de las pruebas: el ejecutable PHP local no tiene `pdo_pgsql` (`php -m` muestra PDO, pdo_mysql, pdo_sqlite y sqlite3). Por ello no se ejecutaron migraciones ni pruebas contra PostgreSQL en este entorno. Instalar/habilitar `pdo_pgsql` y repetir `php artisan test` es pendiente local.
