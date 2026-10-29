# Pruebas

## Resultado consolidado

- 16 pruebas aprobadas.
- 77 aserciones.
- PostgreSQL real en una base de pruebas separada.
- Auditorías Composer y npm sin vulnerabilidades conocidas.
- Frontend compilado con Vite.

## Cobertura funcional

- `/api/health`: forma y valores de la respuesta.
- `/api/database`: respuesta 200 con PostgreSQL y error 503 genérico.
- Vehículos: listado paginado, relaciones, consulta individual, 404, creación, normalización, validación y ausencia de datos personales.
- Portada: render, contenido principal y URLs.
- Persistencia y claves foráneas de PostgreSQL heredadas de la EDT 3.1.

## Aislamiento

`phpunit.xml` usa `mantenimiento_vehiculos_test` por defecto en el puerto local 5433; CI sobrescribe host, puerto y credenciales mediante variables de entorno. Las pruebas de base emplean `LazilyRefreshDatabase` y factories, por lo que no dependen de IDs ni registros de desarrollo.

## Comandos

```powershell
cd web
.\.runtime\php\php.exe vendor\bin\pint --dirty --format agent
.\.runtime\php\php.exe artisan test --compact
composer validate --strict --no-check-publish
composer audit --locked
npm.cmd ci
npm.cmd run build
npm.cmd audit --audit-level=moderate
```

## Límites

La evidencia cubre ejecución local. No se ejecutó GitHub Actions en remoto ni se probó con un dispositivo Android físico. Esos dos controles quedan como validación operativa al publicar la rama o iniciar la EDT 3.4.
