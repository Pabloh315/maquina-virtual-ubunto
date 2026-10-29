# Configuración web

## Componentes

- `resources/views/layouts/app.blade.php`: estructura reutilizable, metadatos, navegación y pie.
- `resources/views/home.blade.php`: portada técnica y enlaces a los endpoints.
- `resources/css/app.css`: Tailwind CSS 4, fuentes de contenido y tokens de color.
- `resources/js/app.js`: consulta real de salud y base, manejo de error y botón de recarga.
- `routes/web.php`: inyecta únicamente URLs generadas por Laravel.

El JavaScript usa `textContent`; no inserta respuestas remotas como HTML. La vista indica expresamente que es una base técnica local y no simula módulos de negocio aún inexistentes.

## Variables relevantes

```dotenv
APP_NAME="Sistema de Gestión de Mantenimiento de Vehículos"
APP_ENV=local
APP_URL=http://127.0.0.1:8000
API_SERVICE_NAME=mantenimiento-vehiculos-api
APP_LOCALE=es
APP_TIMEZONE=America/La_Paz
DB_CONNECTION=pgsql
```

Las credenciales se completan solo en `.env`. Para pruebas se copia `.env.testing.example` a `.env.testing` y se usa una base separada, por ejemplo `mantenimiento_vehiculos_test`.

## Dependencias frontend

```powershell
cd web
npm.cmd ci
npm.cmd run build
```

La compilación validada usa Vite 8.3.5. El aviso de `fontaine` es opcional y no afecta la salida; solo informa que no se generó un fallback tipográfico optimizado.

## Acceso

- Navegador local: `http://127.0.0.1:8000`
- Emulador Android: `http://10.0.2.2:8000`
- Dispositivo físico: iniciar con `-HostAddress 0.0.0.0`, usar la IP LAN del equipo y una red de confianza; detener al terminar.
