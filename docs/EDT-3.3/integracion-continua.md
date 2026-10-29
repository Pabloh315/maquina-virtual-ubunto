# Integración continua

El archivo `.github/workflows/ci.yml` define un único trabajo reproducible, sin despliegue y con permisos `contents: read`.

## Disparadores

- `push`
- `pull_request`
- `workflow_dispatch`

## Entorno

- Ubuntu 24.04
- PHP 8.5 con `mbstring`, `pdo_pgsql` y `pgsql`
- Composer 2
- Node.js 24 con caché npm
- PostgreSQL 17 como servicio saludable
- Base aislada `mantenimiento_vehiculos_test`

## Pasos

1. Obtener el código.
2. Preparar PHP y Node.js.
3. Copiar `.env.example`.
4. Validar e instalar dependencias PHP.
5. Generar `APP_KEY`.
6. Auditar Composer.
7. Ejecutar migraciones.
8. Instalar y compilar el frontend con `npm ci`.
9. Verificar rutas API.
10. Ejecutar toda la suite.

El orden instala `vendor` antes de invocar Artisan. Las variables del servicio PostgreSQL se proporcionan como valores efímeros del job y no representan credenciales de producción.

## Estado de validación

El YAML fue parseado localmente y todos los comandos equivalentes se ejecutaron con éxito. No se afirma una ejecución remota verde: por restricción del hito no se hizo `push`, no se creó PR y no se desplegó. La primera ejecución real en GitHub deberá confirmarse cuando el equipo decida publicar la rama.
