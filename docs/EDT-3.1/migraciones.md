# Migraciones

Las migraciones se ordenan por dependencias: usuarios base, identidad/vehículos, mantenimiento, talleres/citas y operación/inspección. Todas implementan `down()` en orden inverso.

Ejecutar desde `web/`:

```powershell
php artisan migrate
php artisan migrate:status
php artisan db:seed --class=Edt31DemoSeeder
```

Sólo ejecute estos comandos sobre la base local de desarrollo `mantenimiento_vehiculos`. No use `migrate:fresh` contra datos existentes.
