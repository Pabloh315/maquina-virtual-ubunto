# Migraciones

Las migraciones se ordenan por dependencias: usuarios base, identidad/vehÃ­culos, mantenimiento, talleres/citas y operaciÃ³n/inspecciÃ³n. Todas implementan `down()` en orden inverso.

Ejecutar desde `web/`:

```powershell
php artisan migrate
php artisan migrate:status
php artisan db:seed --class=Edt31DemoSeeder
```

Se ejecutaron con exito contra la base local aislada `mantenimiento_vehiculos` en el puerto 5433. No use `migrate:fresh` contra datos existentes.