# Pruebas y evidencias

## Comprobaciones realizadas

- PHP 8.5.0, Composer 2.8.12, Git 2.55.0 y Laravel 13.39.0 detectados.
- Autocarga de Composer y arranque de Laravel comprobados con `php artisan --version`.
- `tests/Unit/Edt31ModelRelationsTest.php` valida metadatos de relaciones principales sin requerir una BD.

## Impedimento registrado

En la máquina de implementación no se detectaron `psql`, servicio PostgreSQL ni extensiones `pgsql`/`pdo_pgsql`. Por seguridad, no se creó una base ni se ejecutaron migraciones. Tras instalar PostgreSQL y habilitar la extensión, ejecute los comandos de `migraciones.md` y después:

```powershell
php artisan test
```

Las pruebas de persistencia (guardar, recuperar, claves foráneas y unicidad) quedan pendientes hasta disponer de esa conexión local.
