# EDT 3.3 — API, web, integración continua y demo local

Implementación completa del hito técnico sobre la base Laravel y PostgreSQL de la EDT 3.1. El entregable incorpora una API REST versionada, una portada web reutilizable, pruebas automatizadas, un flujo de CI sin despliegue y scripts reproducibles para la demostración local.

## Resultado

- API bajo `/api/v1` con listado, consulta y creación de vehículos.
- Comprobaciones `/api/health` y `/api/database`; la segunda solo existe en `local` y `testing`.
- Portada Blade responsive con estados reales de API y PostgreSQL.
- Base de demostración idempotente con datos exclusivamente ficticios.
- CI para PHP 8.5, PostgreSQL 17 y Node.js 24.
- 16 pruebas aprobadas con 77 aserciones.
- Auditorías de Composer y npm sin vulnerabilidades conocidas.
- Demo validada en `127.0.0.1` y detenida sin dejar el puerto abierto.

## Inicio rápido

Desde la raíz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Install-LocalPhp.ps1
cd web
composer install
Copy-Item .env.example .env
.\.runtime\php\php.exe artisan key:generate
# Ajustar DB_* en .env para PostgreSQL local.
.\.runtime\php\php.exe artisan migrate --seed
npm.cmd ci
npm.cmd run build
cd ..
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action start
```

Comprobar o detener:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action stop
```

## Documentos

- [Arquitectura de la API](arquitectura-api.md)
- [Contrato de endpoints](endpoints.md)
- [Configuración web](configuracion-web.md)
- [Integración continua](integracion-continua.md)
- [Entorno de demostración](entorno-demo.md)
- [Pruebas](pruebas.md)
- [Evidencias](evidencias/)
- [Informe consolidado](../../Informe_EDT_3.3_API_Web_CI.md)

## Alcance declarado

No se encontró en el repositorio un contrato aprobado de la EDT 2.4; por ello, los endpoints de vehículos se documentan como contrato técnico provisional para la EDT 3.4. No se implementó Flutter, autenticación avanzada, despliegue externo ni módulos de negocio posteriores. El flujo de GitHub Actions quedó preparado y su equivalente local fue validado, pero no se ejecutó remotamente porque este trabajo no hace `push` ni crea PR.
