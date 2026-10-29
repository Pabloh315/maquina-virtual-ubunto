# Informe EDT 3.3 — API, web e integración continua

Fecha de cierre local: 28 de octubre de 2026<br>
Rama: `feature/3.3-api-web-ci`<br>
Commit de implementación: `f60b7e4`

## Objetivo alcanzado

Se completó la base técnica Laravel solicitada para el hito M02: API REST conectada a PostgreSQL, interfaz web local, automatización de pruebas y construcción, flujo de CI y entorno demostrable. No se realizó despliegue ni integración Flutter.

## Entregables

1. API REST versionada con salud, conectividad de base y operaciones iniciales de vehículos.
2. Validación, normalización, recursos JSON, paginación y manejo seguro de errores.
3. Portada Blade responsive que consulta estados reales.
4. Factories y semilla ficticia idempotente.
5. Suite con PostgreSQL aislado: 16 pruebas y 77 aserciones.
6. GitHub Actions con PHP 8.5, PostgreSQL 17, Node.js 24, auditorías y build.
7. Instalador de PHP local con hash fijo y script de ciclo completo de demo.
8. Documentación técnica y evidencias en `docs/EDT-3.3`.

## Versiones verificadas

| Componente | Versión |
|---|---:|
| PHP local | 8.5.12 NTS x64 |
| Laravel | 13.39.0 |
| Composer | 2.8.12 |
| PostgreSQL | 17.11 |
| Node.js | 24.19.0 |
| npm | 11.17.0 |
| Vite | 8.3.5 |

## Criterios de aceptación

| Criterio | Estado | Evidencia |
|---|---|---|
| API conectada a PostgreSQL | Cumplido | HTTP 200 en salud, base y vehículos |
| Endpoints iniciales | Cumplido | Cinco rutas registradas |
| Web local funcional | Cumplido | Portada HTTP 200 y build Vite |
| Datos demo ficticios | Cumplido | Seeder idempotente `DEMO-001` |
| Pruebas automatizadas | Cumplido | 16/16; 77 aserciones |
| Seguridad de dependencias | Cumplido | Composer y npm sin avisos |
| CI configurada | Cumplido localmente | YAML válido y pasos equivalentes aprobados |
| CI ejecutada en GitHub | Pendiente operativo | No hubo push ni PR |
| Acceso desde emulador | Documentado | URL `10.0.2.2`; no se implementó Flutter |
| Dispositivo físico | Pendiente operativo | Requiere red/firewall del lugar de demo |

## Hallazgos y decisiones

- El PHP global carecía de `pdo_pgsql`; se añadió un runtime local reproducible e ignorado por Git.
- El bloqueo de Composer contenía `symfony/mime` 8.1.7 con un aviso de seguridad; se actualizó a 8.1.10 y la auditoría quedó limpia.
- No se encontró el contrato aprobado de la EDT 2.4. El contrato de vehículos se considera provisional y debe conciliarse antes de la EDT 3.4.
- Se conservó la información existente en la base de desarrollo. La semilla solo crea o actualiza sus registros ficticios identificables.
- La base de pruebas está separada para no volver a contaminar desarrollo.

## Restricciones respetadas

No se ejecutó `push`, `pull`, `fetch`, `merge`, despliegue ni creación de PR. Las credenciales y `APP_KEY` permanecen en archivos ignorados. La carpeta preexistente `tmp/` no fue modificada ni incluida en commits.

## Conclusión

La EDT 3.3 queda lista para demostración local y como punto de partida técnico de la integración móvil. El único estado no verificable sin publicar es la ejecución remota de GitHub Actions; no se presenta como realizada.
